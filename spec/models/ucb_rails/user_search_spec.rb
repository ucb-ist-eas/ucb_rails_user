require 'rails_helper'

RSpec.describe UcbRailsUser::UserSearch do

  let!(:ricardo) { create(:user, first_name: "Ricardo", last_name: "Montalban") }

  it "finds user by last name" do
    result = UcbRailsUser::UserSearch.find_users_by_name("Montalban")
    expect(result).to eq([ricardo])
  end

  it "finds user by first name" do
    result = UcbRailsUser::UserSearch.find_users_by_name("Ricardo")
    expect(result).to eq([ricardo])
  end

  it "finds user by first name substring" do
    result = UcbRailsUser::UserSearch.find_users_by_name("Rica")
    expect(result).to eq([ricardo])
  end

  it "finds user by last name substring" do
    result = UcbRailsUser::UserSearch.find_users_by_name("monta")
    expect(result).to eq([ricardo])
  end

  it "is case-insenstive" do
    result = UcbRailsUser::UserSearch.find_users_by_name("montalban")
    expect(result).to eq([ricardo])
  end

  it "finds user by first and last name" do
    result = UcbRailsUser::UserSearch.find_users_by_name("ricardo montalban")
    expect(result).to eq([ricardo])
  end

  it "finds user by first and last name when reversed" do
    result = UcbRailsUser::UserSearch.find_users_by_name("montalban ricardo")
    expect(result).to eq([ricardo])
  end

  it "can find multiple matches" do
    alice = create(:user, first_name: "Alice", last_name: "Montalban")
    result = UcbRailsUser::UserSearch.find_users_by_name("montalban")
    expect(result).to match_array([ricardo, alice])
  end

  it "sorts by last name" do
    ricky = create(:user, first_name: "Ricky", last_name: "Ricardo")
    result = UcbRailsUser::UserSearch.find_users_by_name("ricardo")
    expect(result).to eq([ricardo, ricky])
  end

  it "sorts by last name, then first name" do
    alice = create(:user, first_name: "Alice", last_name: "Montalban")
    result = UcbRailsUser::UserSearch.find_users_by_name("montalban")
    expect(result).to eq([alice, ricardo])
  end
end
