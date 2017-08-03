require 'rails_helper'

describe User do
  let(:klass) { User }
  let(:user) { klass.new}

  it "#roles defaults to []" do
    expect(klass.new.roles).to eq([])
  end

  describe "#has_role?" do
    it "false" do
      expect(user).to_not have_role("foo")
    end

    it "true" do
      allow(user).to receive(:roles) { ["foo"] }
      expect(user).to have_role("foo")
    end

    it "admin true" do
      user.superuser_flag = true
      expect(user).to have_role("foo")
    end
  end

  it 'full_name' do
    expect(klass.create!(ldap_uid: 1).full_name).to be_nil
    expect(klass.create!(ldap_uid: 2, first_name: 'Art').full_name).to eq('Art')
    expect(klass.create!(ldap_uid: 3, last_name: 'Andrews').full_name).to eq('Andrews')
    expect(klass.create!(ldap_uid: 4, first_name: 'Art', last_name: 'Andrews').full_name).to eq('Art Andrews')
  end

  it '#superuser!' do
    user = User.create!(ldap_uid: 1)
    expect(user).not_to be_superuser

    user.superuser!
    expect(user).to be_superuser

    user.superuser!(false)
    expect(user).not_to be_superuser
  end

  it "active?" do
    user = User.create!(ldap_uid: 1)
    expect(user).not_to be_inactive
    expect(user).to be_active
  end

  it '#inactive!' do
    user = User.create!(ldap_uid: 1)
    expect(user).not_to be_inactive

    user.inactive!
    expect(user).to be_inactive

    user.inactive!(false)
    expect(user).not_to be_inactive
  end

  it '.active' do
    active = User.create(ldap_uid: 1)
    inactive = User.create(ldap_uid: 2, inactive_flag: true)
    expect(User.active).to eq([active])
  end

  it '.superuser' do
    superuser = User.create(ldap_uid: 1, superuser_flag: true)
    not_superuser = User.create(ldap_uid: 2)
    expect(User.superuser).to eq([superuser])
  end
end
