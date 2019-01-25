require 'rails_helper'

describe UcbRailsUser::Configuration::Ldap do
  let(:klass) { UcbRailsUser::Configuration::Ldap }
  let(:ldap) { UCB::LDAP }

  context 'no configuration passed' do
    let(:config) { nil }

    it "does not attempt to authenticate" do
      expect(ldap).to_not receive(:authenticate)
      klass.configure(config)
    end

  end

  context 'configuration passed' do
    let(:config) { {'host' => 'HOST', 'username' => 'USERNAME', 'password' => 'PASSWORD', 'include_test_entries' => true } }
    before { allow(ldap).to receive(:authenticate) }

    context 'not production' do
      it "sets test host" do
        klass.configure(config)
        expect(ldap.host).to eq('HOST')
        expect(UCB::LDAP::Person.include_test_entries?).to be_truthy
      end
    end

    context 'production' do
      before {
        allow(Rails).to receive(:env) {
          ActiveSupport::StringInquirer.new("production")
        }
      }

      it "sets production host" do
        klass.configure(config)
        expect(ldap.host).to eq('HOST')
        expect(UCB::LDAP::Person.include_test_entries?).to be_truthy
      end
    end

  end

end
