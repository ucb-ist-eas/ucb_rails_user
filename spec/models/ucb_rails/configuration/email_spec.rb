require 'rails_helper'

describe UcbRailsUser::Configuration::Email do
  # let(:test_config_file) { UcbRailsUser::Engine.root.join('spec/fixtures/config.yml')}
  let(:klass) { UcbRailsUser::Configuration::Email }
  let(:amb) { ActionMailer::Base }

  after(:all) do
    ActionMailer::Base.delivery_method = :test
  end

  describe '.new' do
    it "sets config" do
      expect(klass.new({'foo' => 'bar'}).hash).to eq({'foo' => 'bar'})
    end

    it "requires a hash" do
      expect { klass.new('foo') }
        .to raise_error(UcbRailsUser::Configuration::Email::ArgumentError)
    end
  end

  describe 'delivery_method' do
    it "defaults to smtp" do
      klass.new({})
      expect(amb.delivery_method).to eq(:smtp)
    end

    it "can be set" do
      klass.new({'delivery_method' => 'sendmail'})
      expect(amb.delivery_method).to eq(:sendmail)
    end
  end

  describe 'default' do
    it "adds to default" do
      klass.new({'default' => {'foo' => 'bar'}})
      expect(amb.default['foo']).to eq('bar')
    end
  end

  describe 'default_url_options' do
    it "sets default_url_options" do
      config = {'default_url_options' => { :host => 'localhost' } }
      klass.new(config)
      expect(amb.default_url_options).to eq(config['default_url_options'])
    end
  end

  describe 'raise_delivery_errors' do
    it "defaults to true" do
      klass.new({})
      expect(amb.raise_delivery_errors).to be_truthy
    end

    it "can be set" do
      config = { 'raise_delivery_errors' => false}
      klass.new(config)
      expect(amb.raise_delivery_errors).to be_falsey
    end
  end

  describe 'sendmail_settings' do
    it "sets send_settings, symbolizes keys" do
      config = {'sendmail_settings' => { 'location' => '/app/bin/sendmail'} }
      klass.new(config)
      expect(amb.sendmail_settings).to eq({ location: '/app/bin/sendmail'})
    end
  end

  describe 'smtp_settings' do
    it "sets smtp_settings, symbolizes keys" do
      config = {'smtp_settings' => { 'port' => 587, 'domain' => 'gmail.com'}}
      klass.new(config)
      expect(amb.smtp_settings).to eq({ port: 587, domain: 'gmail.com'})
    end
  end

  describe 'subject_prefix' do
    it "defaults to ''" do
      klass.new({})
      expect(UcbRailsUser[:email_subject_prefix]).to eq('')
    end

    it "can be set" do
      config = {'subject_prefix' => '[MyApp]'}
      klass.new(config)
      expect(UcbRailsUser[:email_subject_prefix]).to eq('[MyApp]')
    end

    it "substitues Rails env" do
      config = {'subject_prefix' => '[MyApp {env}]'}
      klass.new(config)
      expect(UcbRailsUser[:email_subject_prefix]).to eq('[MyApp test]')
    end
  end
end
