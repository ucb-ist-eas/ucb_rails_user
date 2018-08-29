#
# Session manager designed to be used in tests. This bypasses the usual LDAP lookup when
# given a uid, and instead simply looks up the user in the current database.
#
# This assumes that the user already exists in the database, so your test scenario should
# set that up before attempting a login
#
module UcbRailsUser
  module UserSessionManager
    class TestSessionManager < ActiveInUserTable

      def login(uid)
        User.find_by_ldap_uid(uid)
      end

    end
  end
end
