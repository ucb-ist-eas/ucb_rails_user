module UcbRailsUser::Concerns::UsersController
  extend ActiveSupport::Concern

  included do
    before_action :find_user, :only => [:edit, :update, :destroy]
    before_action :ensure_admin_user
    skip_before_action :ensure_admin_user, if: ->{ action_name == "toggle_superuser" && Rails.env.development? }, raise: false
  end

  def index
    @users = User.all
    respond_to do |format|
      format.html { @users = User.all }
      format.json { render json: UcbRails::UsersDatatable.new(view_context).as_json }
    end
  end

  def search
    @results = UcbRailsUser::LdapPerson::Finder.find_by_attributes(
      {
        givenname: params.fetch(:first_name),
        sn: params.fetch(:last_name),
        employeenumber: params.fetch(:employee_id)
      },
      sort: :last_first_downcase
    )
  end

  def impersonate_search
    result = UcbRailsUser::UserSearch.find_users_by_name(params[:q])
    render json: result.map { |u| { name: u.full_name, id: u.id, uid: u.ldap_uid } }
  end

  def edit
  end

  def new
  end

  def create
    uid = params.fetch(:ldap_uid)
    user = nil
    if user = User.find_by_ldap_uid(uid)
      flash[:warning] = "User already exists"
    else
      begin
        user = UcbRailsUser::UserLdapService.create_user_from_uid(uid)
        flash[:notice] = "Record created"
      rescue Exception => e
        raise e
        flash[:danger] = "Unable to create new user - please try again"
        return redirect_to new_admin_user_path()
      end
    end
    redirect_to edit_admin_user_path(user)
  end

  def update
    if @user.update(user_params)
      redirect_to(admin_users_path, notice: 'Record updated')
    else
      render("edit")
    end
  end

  def destroy
    if @user.destroy
      flash[:notice] = 'Record deleted'
    else
      flash[:error] = @user.errors[:base].first
    end

    redirect_to(admin_users_path)
  end

  def ldap_search
    # FIXME: this was retrofitted to support typeahead ajax json queries
    if(query = params[:query])
      @lps_entries = UcbRailsUser::OmniUserTypeahead.new.ldap_results(query)
      @lps_entries.map!{|entry|
        attrs = entry.attributes.tap{|attrs| attrs["first_last_name"] = "#{attrs['first_name']} #{attrs['last_name']}" }
        attrs.as_json
      }

      render json: @lps_entries

    else
      @lps_entries = UcbRailsUser::LdapPerson::Finder.find_by_first_last(
        params.fetch(:first_name),
        params.fetch(:last_name),
        :sort => :last_first_downcase
      )
      @lps_existing_uids = User.where(ldap_uid: @lps_entries.map(&:uid)).pluck(:uid)
      render 'ucb_rails_user/lps/search'
    end

  end

  def typeahead_search
    uta = UcbRails::UserTypeahead.new
    render json: uta.results(params.fetch(:query))
  end

  def omni_typeahead_search
    uta = UcbRails::OmniUserTypeahead.new
    render json: uta.results(params.fetch(:query))
  end

  def toggle_superuser
    current_user.try(:superuser!, !superuser?)
    redirect_to root_path
  end

  private

  def user_params(extra_params = [])
    params.require(:user).permit([
      :superuser_flag,
      :inactive_flag,
      :first_name,
      :last_name,
      :email,
      :alternate_email,
      :phone,
      :last_request_at,
      :last_logout_at,
      :last_login_at,
      :uid] + extra_params
    )
  end

  def find_user
    @user ||= User.find(params.fetch(:id))
  end

end

