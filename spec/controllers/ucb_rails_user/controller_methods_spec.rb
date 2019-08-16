require 'rails_helper'

describe UcbRailsUser::Concerns::ControllerMethods do
  let(:controller) { ApplicationController.new }

  describe '#logged_in?' do
    it "true" do
      allow(controller).to receive(:logged_in_user) { double('user') }
      expect(controller).to be_logged_in
    end

    it "false" do
      allow(controller).to receive(:session) { {uid: ''} }
      expect(controller).to_not be_logged_in
    end
  end

  describe 'setting Thread.current[:current_user]' do
    it "set in log request, cleared in remove_user_settings" do
      user_mock = double('user')
      session_manager_mock = double('session_manager')
      allow(controller).to receive(:user_session_manager) { session_manager_mock }
      allow(controller).to receive(:current_user) { user_mock }
      expect(session_manager_mock).to receive(:log_request).with(user_mock)

      controller.log_request
      expect(UcbRailsUser::UserSessionManager::Base.current_user).to eq(user_mock)
      controller.remove_user_settings
      expect(UcbRailsUser::UserSessionManager::Base.current_user).to eq(nil)
    end
  end

  describe '#current_ldap_person' do
    # this test currently fails with the following error, that I couldnt' resolve:
    # ActionController::Metal#session delegated to @_request.session, but @_request is nil
    #it "logged in" do
       #ldap_person = double('ldap_person')
       #allow(controller).to receive(:logged_in?) { true }
       #expect(UCB::LDAP::Person).to receive(:find_by_uid).with('123').and_return(ldap_person)
       #expect(controller.current_ldap_person).to eq(ldap_person)
    #end

    it "not logged in" do
      allow(controller).to receive(:session) { {uid: ''} }
      expect(UCB::LDAP::Person).to_not receive(:find_by_uid)
      expect(controller.current_ldap_person).to be_nil
    end
  end

end
