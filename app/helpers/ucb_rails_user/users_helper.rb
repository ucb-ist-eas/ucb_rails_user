module UcbRailsUser
  module UsersHelper

    def link_to_new_user
      text = 'New User'
      # text = image_tag('ucb_rails/glyphicons_006_user_add.png', size: '14x14')
      button(text, :primary,
        class: 'ldap-person-search',
        data: {
          search_url: "",
          result_link_url: new_admin_user_path,
          result_link_http_method: 'post',
        }
      )
    end

    def checkmark(bool, true_string="&#10004;".html_safe, false_string='&nbsp;'.html_safe)
      bool ? true_string : false_string
    end
  end
end
