require "rails_helper"

RSpec.describe "logging in and out" do

  it "shows the not-logged-in page if the user is not logged in" do
    visit root_path
    expect(page).to have_content("You are not logged in")
  end

  it "shows the logged-in page if the user is logged in" do
    user = create(:user)
    system_login_user(user)
    expect(page).to have_content("You are logged in as #{user.full_name}")
  end

  it "allows the user user to logout", :js do
    user = create(:user)
    system_login_user(user)
    expect(page).to have_content("You are logged in as #{user.full_name}")
    visit "/logout"
    expect(page).to have_content("You are not logged in")
  end

end

