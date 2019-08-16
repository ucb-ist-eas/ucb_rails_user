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

  describe "impersonating" do
    let(:superuser) { create(:superuser) }
    let(:user) { create(:user) }

    it "only allows superusers to impersonate by default" do
      expect(superuser.can_impersonate?).to be true
      expect(user.can_impersonate?).to be false
    end

    it "can impersonate another user with a user id" do
      UcbRailsUser::Impersonation.delete_all
      expect(superuser.impersonate!(user.id)).to be true
      expect(UcbRailsUser::Impersonation.count).to eq(1)
    end

    it "can impersonate another user with a User object" do
      UcbRailsUser::Impersonation.delete_all
      expect(superuser.impersonate!(user)).to be true
      expect(UcbRailsUser::Impersonation.count).to eq(1)
    end

    it "prevents impersonating non-existent users" do
      expect(superuser.impersonate!(-1)).to be false
      expect(superuser.impersonate!(nil)).to be false
    end

    it "prevents impersonating yourself" do
      expect(superuser.impersonate!(superuser.id)).to be false
    end

    it "prevents unauthorized users from calling impersonate! directly" do
      expect(user.impersonate!(superuser.id)).to be false
    end

    it "sets any existing impersonations to inactive when a new impersonation is created" do
      old_impersonation = create(:impersonation, user: superuser, target: user, active: true)
      superuser.impersonate!(create(:user))
      expect(old_impersonation.reload).not_to be_active
    end

    it "returns the current impersonation" do
      expect(superuser.current_impersonation()).to be_nil
      superuser.impersonate!(user)
      expect(superuser.current_impersonation).not_to be_nil
      expect(superuser.current_impersonation.target).to eq(user)
    end

    it "provides a shortcut to the impersonation target" do
      expect(superuser.impersonation_target).to be_nil
      superuser.impersonate!(user)
      expect(superuser.impersonation_target).to eq(user)
    end

    it "can stop impersonating" do
      superuser.impersonate!(user)
      expect(superuser.current_impersonation.target).to eq(user)
      superuser.stop_impersonation!
      expect(superuser.impersonating?).to be false
      expect(superuser.current_impersonation).to be_nil
    end
  end
end
