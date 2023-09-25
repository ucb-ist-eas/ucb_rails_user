require 'rails_helper'

describe UcbRailsUser::UserSessionManager::AdminInUserTable do
  let(:manager) { UcbRailsUser::UserSessionManager::AdminInUserTable.new }
  let(:user) { UcbRailsUser.user_class.create!(ldap_uid: 1) }

  describe "login" do

    context 'in ldap' do
      it "superuser in User table" do
        user
        user.update_attribute(:superuser_flag, true)
        expect(manager.login("1")).to eq(user)
        expect(user.reload.last_login_at).to be_within(1).of(Time.now)
      end

      it "not superuser in User table" do
        user.update_attribute(:superuser_flag, false)
        expect(manager.login("1")).to be_falsey
      end

      it "inactive in User table" do
        user.update_attribute(:inactive_flag, true)
        expect(manager.login("1")).to be_falsey
      end

      it "not in User table" do
        expect(manager.login("1")).to be_falsey
      end
    end

    context 'not in ldap' do
      it "always false" do
        user
        user.update_attribute(:superuser_flag, true)
        expect(manager.login("100")).to be_falsey
      end
    end

  end

end
