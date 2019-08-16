module UcbRailsUser::UserSearch

  def self.find_users_by_name(name)
    return [] unless name.present?
    (name1, name2) = name.split
    query = case_insenstive(:first_name, name1)
      .or(case_insenstive(:last_name, name1))
    if name2.present?
      query = query
        .or(case_insenstive(:first_name, name2))
        .or(case_insenstive(:last_name, name2))
    end
    query.order(:last_name, :first_name)
  end

  private

  def self.case_insenstive(column, value)
    User.where("LOWER(#{column}) = ?", value.downcase)
  end

end
