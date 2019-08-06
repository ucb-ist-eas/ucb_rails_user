require 'rails_helper'

describe UcbRailsUser::Configuration::Configuration do
  let(:test_config_file) { UcbRailsUser::Engine.root.join('spec/config.yml')}
  let(:config) { UcbRailsUser::Configuration::Configuration.new(test_config_file) }

  describe '.initialize' do
    it "defaults to 'config/config.yml" do
      expect { UcbRailsUser::Configuration::Configuration.new }
        .to raise_error(UcbRailsUser::Configuration::Configuration::FileNotFound, %r{config/config.yml})
    end

    it "loads config file" do
      expect(config.config_yaml).to eq(YAML.load_file(test_config_file))
    end
  end

  describe '.for' do
    it "finds top" do
      allow(Rails).to receive(:env) { 'development' }
      expect(config.for('foo')).to eq({ 'username' => 'top_username', "password"=>"top_password"})
    end

    it "prefers environment" do
      expect(config.for('foo')).to eq({ 'username' => 'test_username', "password"=>"test_password"})
    end

    it "not found okay if allow_nil" do
      expect(config.for('not_found')).to eq(nil)
    end
  end

  describe '.for!' do
    it "finds" do
      expect(config.for!('foo')).to eq({ 'username' => 'test_username', "password"=>"test_password"})
    end

    it "raises if key not found" do
      expect { config.for!('not_found') }
        .to raise_error(UcbRailsUser::Configuration::Configuration::KeyNotFound, %r{not_found})
    end

  end
end
