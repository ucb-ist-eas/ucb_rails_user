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
        new(
          :uid => ldap_entry.uid,
          :calnet_id => ldap_entry.berkeleyedukerberosprincipalstring.first,
          :employee_id => ldap_entry.attributes[:berkeleyeduucpathid]&.first,
          :student_id => ldap_entry.berkeleyedustuid,
          :first_name => ldap_entry.givenname.first,
          :last_name => ldap_entry.sn.first,
          :email => ldap_entry.mail.first,
          :phone => ldap_entry.phone,
          :departments => ldap_entry.berkeleyeduunithrdeptname,
          :affiliations => ldap_entry.berkeleyeduaffiliations,
          :affiliate_id => ldap_entry.berkeleyeduaffid.first,
          :inactive => ldap_entry.expired? || false
        )
      end

    end

  end
end
