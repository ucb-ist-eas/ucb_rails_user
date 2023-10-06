require 'rails_helper'

describe UcbRailsUser::UserSessionManager::InPeopleOuAddToUsersTable do
  let(:manager) { UcbRailsUser::UserSessionManager::InPeopleOuAddToUsersTable.new }
  let(:user) { UcbRailsUser.user_class.create!(ldap_uid: 1) }

  describe '#login' do

    describe 'in People OU' do
      it "in User table" do
        user
        expect(manager.login("1")).to eq(UcbRailsUser.user_class.last)
      end

      it 'not in User table' do
        expect(manager.login("1")).to eq(UcbRailsUser.user_class.last)
      end
    end

    describe 'not in People OU' do
      it "always false" do
        UcbRailsUser.user_class.create!(ldap_uid: 100)
        expect(manager.login("100")).to be_falsey
      end
    end

  end

  describe '#current_user' do
    it "returns user" do
      user
      expect(manager.current_user("1")).to eq(user)
    end

    it "handles nil" do
      expect(manager.current_user(nil)).to be_nil
    end
  end

end
