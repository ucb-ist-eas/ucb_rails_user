module UcbRailsUser::LdapPerson
  class Entry

    # include ActiveAttr::Model  <--- doesn't work with 4.0 (mass assign. security)
    include ::ActiveAttr::Attributes
    include ::ActiveAttr::BasicModel
    include ::ActiveAttr::BlockInitialization
    include ::ActiveAttr::MassAssignment

    attribute :uid
    attribute :calnet_id
    attribute :employee_id
    attribute :student_id
    attribute :first_name
    attribute :last_name
    attribute :email
    attribute :alternate_email
    attribute :phone
    attribute :departments
    attribute :affiliations
    attribute :affiliate_id
    attribute :inactive

    def full_name
      "#{first_name()} #{last_name()}"
    end

    def last_first
      "#{last_name}, #{first_name}"
    end

    def last_first_downcase
      last_first.downcase
    end

    # Currently only used in rspec
    def ==(other)
      uid == other.uid
    end

    class << self

      def new_from_ldap_entry(ldap_entry)
        # the to_s calls are because the underlying LDAP library sometimes returns strings as instances
        # of Net::BER::BerIdentifiedString rather than String, and the Oracle DB library doesn't play
        # nicely with those (postgres and sqlite work fine)
        new(
          uid: ldap_entry.uid&.to_s,
          calnet_id: ldap_entry.berkeleyedukerberosprincipalstring.first&.to_s,
          employee_id: ldap_entry.attributes[:berkeleyeduucpathid]&.first&.to_s,
          student_id: ldap_entry.berkeleyedustuid&.to_s,
          first_name: ldap_entry.givenname.first&.to_s,
          last_name: ldap_entry.sn.first&.to_s,
          email: ldap_entry.mail.first&.to_s,
          alternate_email: ldap_entry.attributes[:berkeleyedualternateid]&.first&.to_s,
          phone: ldap_entry.phone&.to_s,
          departments: ldap_entry.berkeleyeduunithrdeptname&.to_s,
          affiliations: ldap_entry.berkeleyeduaffiliations&.map(&:to_s),
          affiliate_id: ldap_entry.berkeleyeduaffid.first&.to_s,
          inactive: ldap_entry.expired? || false
        )
      end

    end

  end
end
