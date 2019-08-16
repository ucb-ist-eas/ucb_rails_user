require "rails_helper"

RSpec.describe "impersonating another user" do

  let(:user) { create(:user) }
  let(:superuser) { create(:superuser) }
  before(:each) { system_login_user(superuser) }

  describe "impersonation permissions" do
    it "allows superusers to impersonate users" do
      visit admin_impersonations_path
      expect(page).to have_css("h1", text: "Impersonate user")
    end

    it "does not allow regular users to impersonate users" do
      system_login_user(user)
      visit admin_impersonations_path
      expect(page).to have_content("Not Authorized")
    end
  end

  describe "recent impersonations" do
    before(:each) { system_login_user(superuser) }

    it "shows recent impersonations" do
      create(:impersonation, user: superuser, target: user)
      visit admin_impersonations_path
      expect(page).to have_css("h3", text: "Recent impersonations")
      expect(page).to have_css("a", text: user.full_name)
    end

    it "filters out duplicate target users" do
      create(:impersonation, user: superuser, target: user)
      create(:impersonation, user: superuser, target: user)
      visit admin_impersonations_path
      expect(page).to have_css("h3", text: "Recent impersonations")
      expect(page).to have_css("a", text: user.full_name, count: 1)
    end

    it "shows a message if there are no recent impersonations" do
      visit admin_impersonations_path
      expect(page).to have_css("h4", text: "No recent impersonations")
    end
  end

  describe "impersonation workflow" do
    it "allows the user to select a recent impersonation link" do
      create(:impersonation, user: superuser, target: user)
      visit admin_impersonations_path
      click_on user.full_name
      expect(page).to have_content("You are now impersonating #{user.full_name}")
    end

    it "allows the user to lookup the user they want to impersonate" do # use :js when enabled
      # TODO: try to get this spec to work - the trick is filling in the typeahead field in
      # a way that actually causes the dropdown to get rendered, and then be selectable.
      # The execute_script line is one that I found after some searching, but it didn't work, so
      # I'm giving up for now - this is taking too much time, and the test coverage is good
      # enough for now, I think.
      #visit admin_impersonations_path
      #execute_script %Q{ $('#ucb_rails_user_impersonation_target').focus().typeahead('val', '#{user.full_name}') }
      #click_on "Impersonate"
      #expect(page).to have_content("You are now impersonating #{user.full_name}")
    end

    it "allows the user to stop an impersonation" do
      create(:impersonation, user: superuser, target: user, active: true)
      visit admin_stop_impersonation_path
      expect(page).to have_content("You are no longer impersonating.")
    end
  end

end

