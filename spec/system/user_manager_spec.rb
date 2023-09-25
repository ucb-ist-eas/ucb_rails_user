require "rails_helper"

RSpec.describe "managing users" do

  let!(:users) { (0..2).map { create(:user) } }
  let(:superuser) { create(:superuser) }
  before(:each) { system_login_user(superuser) }

  it "only allows superuser to edit users" do
    system_login_user(users.first)
    visit admin_users_path
    expect(page).to have_content("Not Authorized")
  end

  it "shows a list of current users, including superuser" do
    visit admin_users_path()
    expect(find_all("tr.user").count).to eq(4)
    users.push(superuser).each do |user|
      expect(page).to have_content(user.first_name)
      expect(page).to have_content(user.last_name)
    end
  end

  it "can edit a user" do
    user = users.first
    alt_email = "dummy@dummy.com"

    visit admin_users_path()
    click_on "edit", id: "edit_user_#{user.id}"
    fill_in "Alternate email", with: alt_email
    click_on "Submit"
    expect(page).to have_css("h1", text: "Users")
    expect(user.reload.alternate_email).to eq(alt_email)
  end

  it "can delete a user" do
    user = users.first

    visit admin_users_path()
    within("tr#user_#{user.id}") do
      click_on "delete"
    end
    expect(page).to have_css("h1", text: "Users")
    expect(UcbRailsUser.user_class.find_by(id: user.id)).to be_nil
  end

end
