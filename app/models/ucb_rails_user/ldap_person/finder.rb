module UcbRailsUser::LdapPerson
  class Finder
    BlankSearchTermsError = Class.new(StandardError)
    PersonNotFound = Class.new(StandardError)

    def benchmark(message = "Benchmarking")
      result = nil
      ms = Benchmark.ms { result = yield }
      Rails.logger.debug "#{message} #{ms}"
      result
    end

    def find_by_uid(uid)
      benchmark("find_by_uid(#{uid})") do
        find_by_attributes(:uid => uid.to_s).first ||
          find_expired_by_attributes(:uid => uid.to_s).first
      end
    end

    def find_by_uid!(uid)
      find_by_uid(uid) or raise(PersonNotFound, "uid=#{uid.inspect}")
    end

    def find_by_first_last(first_name, last_name, options={})
      raise BlankSearchTermsError unless first_name.present? || last_name.present?

      find_by_attributes({:givenname => first_name, :sn => last_name}, options).tap do |entries|
        if options[:sort]
          sort_symbol = options[:sort]
          entries.sort_by!(&options[:sort])
        end
      end
    end

    def find_by_affiliate_id(affiliate_id)
      find_by_attributes("berkeleyEduAffID" => affiliate_id)
    end

    def find_by_attributes(attributes, options={})
      attributes.each { |k, v| attributes.delete(k) if v.blank?  }

      search_opts = { :filter => build_filter(attributes, options) }
      search_opts[:return_result] = options[:return_result] if options.has_key?(:return_result)
      search_opts[:size] = options[:size] if options.has_key?(:size)

      result = []
      %w(people guests).each do |ou|
        search_opts[:base] = "ou=#{ou},dc=berkeley,dc=edu"
        result = UCB::LDAP::Person.search(search_opts)
        break if result.present?
      end
      result.map { |ldap_entry| Entry.new_from_ldap_entry(ldap_entry) }
    end

    def find_expired_by_attributes(attributes)
      attributes.each { |k, v| attributes.delete(k) if v.blank?  }
      UCB::LDAP::ExpiredPerson.
        search(:filter => build_filter(attributes)).
        map { |ldap_entry| Entry.new_from_ldap_entry(ldap_entry) }
    end

    def build_filter(attrs, options={})
      operator = options[:operator] || :&
      filter_parts = attrs.map { |k, values|
        Array(values).map{|v| build_filter_part(k, v) }
      }.flatten
      filter = filter_parts.inject { |accum, filter| accum.send(operator, filter) }
      filter
    end

    def build_filter_part(key, value)
      value = key.to_s == 'uid' ? value : "#{value}*"
      Net::LDAP::Filter.eq(key.to_s, value)
    end

    class << self
      def klass
        if Rails.env.test? || UcbRailsUser[:omniauth_provider] == :developer
          UcbRailsUser::LdapPerson::TestFinder
        else
          UcbRailsUser::LdapPerson::Finder
        end
      end

      def method_missing(method, *args)
        klass.new.send(method, *args)
      end
    end

  end
end
