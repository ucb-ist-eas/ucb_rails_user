require "rails_helper"

describe UcbRailsUser::UserSessionManager::InUcPathAddToUsersTable do
  let(:manager) { UcbRailsUser::UserSessionManager::InUcPathAddToUsersTable.new }
  let!(:user) { User.create!(ldap_uid: 1) }

  describe "#login" do

    it "pulls the existing user record if the user is in the database" do
      expect(manager.login("1")).to eq(user)
    end

    it "pulls the record from UCPath if the user is not in the database, and stores the lived name" do
      ucpath_client = instance_double("UcbRailsUser::UserUcPathService::UcPathClient")
      allow(ucpath_client).to receive(:fetch_employee_data_with_ldap_uid).and_return(mock_ucpath_response["response"].first)
      expect(UcbRailsUser::UserUcPathService).to receive(:ucpath_client).and_return(ucpath_client)
      expect(UcbRailsUser::UserLdapService).not_to receive(:create_or_update_user_from_entry)
      user = manager.login("1234")
      expect(user.email).to eq("tony_ucpath@stark.com")
      expect(user.first_name).to eq("Iron")
      expect(user.last_name).to eq("Man")
    end

    it "pulls the record from LDAP if the user is not in the database or UCPath" do
      expect(UcbRailsUser::UserUcPathService).to receive(:create_or_update_user_from_ldap_uid).and_return(nil)
      expect(manager).to receive(:people_ou_entry).and_return(mock_ldap_response())
      user = manager.login("1234")
      expect(user.email).to eq("tony_ldap@stark.com")
    end

    it "pulls the record from LDAP if UCPath returns a missing or invalid result" do
      expect(UcbRailsUser::UserUcPathService).to receive(:create_or_update_user_from_ldap_uid).and_raise(StandardError)
      expect(manager).to receive(:people_ou_entry).and_return(mock_ldap_response())
      user = manager.login("1234")
      expect(user.email).to eq("tony_ldap@stark.com")
    end

  end

end

def mock_ldap_response
  UcbRailsUser::LdapPerson::Entry.new.tap do |entry|
    entry.first_name = "Tony"
    entry.last_name = "Stark"
    entry.email = "tony_ldap@stark.com"
    entry.uid = "1234"
    entry.employee_id = "12345678"
    entry.inactive = false
  end
end

def mock_ucpath_response
{
    "response" => [
    {
        "identifiers" => [
        {
            "type" => "hr-employee-id",
            "id" => "12345678"
          },
        {
            "type" => "campus-uid",
            "id" => "1234"
          },
        ],
        "names" => [
        {
            "type" => {
              "code" => "PRI",
              "description" => "Primary"
            },
            "familyName" => "Stark",
            "givenName" => "Tony",
            "lastChangedBy" => {
              "id" => "UC_CONV_ARO"
            },
            "fromDate" => "1989-06-19"
          },
        {
            "type" => {
              "code" => "PRF",
              "description" => "Preferred"
            },
            "familyName" => "Man",
            "givenName" => "Iron",
            "lastChangedBy" => {
              "id" => "UC_CONV_ARO"
            },
            "fromDate" => "1989-06-19"
          }
        ],
        "emails" => [
        {
            "type" => {
              "code" => "BUSN",
              "description" => "Business"
            },
            "emailAddress" => "tony_ucpath@stark.com",
            "primary" => true
          }
        ],
      }
    ]
  }
end
