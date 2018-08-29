module UcbRailsUser
  module SpecHelpers

    def login_user(user)
      OmniAuth.config.test_mode = true
      auth_mock(user.ldap_uid)
      get "/login"
      follow_redirect!
      follow_redirect!
    end

    def auth_mock(uid)
      OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new(
        provider: "cas",
        uid: uid,
        user_info: {
          name: "mockuser"
        },
        credentials: {
          token: "mock_token",
          secret: "mock_secret"
        }
      )
    end

  end
end
