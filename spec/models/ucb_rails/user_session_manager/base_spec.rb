require 'rails_helper'

describe UcbRailsUser::UserSessionManager::Base do
  let(:klass) { UcbRailsUser::UserSessionManager::Base }
  let(:manager) { klass.new }

  it "#login" do
    expect { manager.login("anything") }.to raise_error(NotImplementedError)
  end

  it '#current_user' do
    expect { manager.current_user("anything") }.to raise_error(NotImplementedError)
  end

  it '#log_request' do
    expect(manager.log_request('anything')).to be_nil
  end

  it '#logout' do
    expect(manager.logout('anything')).to be_nil
  end

  describe '.current_user, .current_user=' do
    it "set / get" do
      klass.current_user = 'foo'
      expect(klass.current_user).to eq('foo')
    end
  end
end
