module UcbRailsUser::UserSearch

  def self.find_users_by_name(name)
    return [] unless name.present?
    (name1, name2) = name
      .downcase
      .split
      .take(2)
      .reject { |n| n.blank? }
      .map { |n| "#{n}%" }
    query =
      if name1.present? && name2.present?
        UcbRailsUser.user_class.where("LOWER(first_name) LIKE ? AND LOWER(last_name) LIKE ?", name1, name2)
          .or(UcbRailsUser.user_class.where("LOWER(last_name) LIKE ? AND LOWER(first_name) LIKE ?", name1, name2))
      else
        UcbRailsUser.user_class.where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", name1, name1)
      end
    query.order(:last_name, :first_name)
  end

end
