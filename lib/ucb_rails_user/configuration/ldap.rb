module UcbRailsUser
  module Configuration

    class Ldap
      attr_accessor :config

      def initialize(config)
        self.config = config.presence || {}
      end

      def configure
        configure_host
        initialize_ldap
        test_entries
      end

      private

      def configure_host
        UCB::LDAP.host = config.fetch("host", default_host)
      end

      def initialize_ldap
        username = config.fetch("username", "")
        password = config.fetch("password", "")
        host = config.fetch("host", "")
        UCB::LDAP.initialize username, password, host
      end

      def test_entries
        UCB::LDAP::Person.include_test_entries = config.fetch("include_test_entries", default_include_test_entries)
      end

      def default_host
        "nds.berkeley.edu"
      end

      def default_include_test_entries
        !Rails.env.production?
      end

      class << self
        def configure(config)
          new(config).configure
        end
      end
    end

  end
end
