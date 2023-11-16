Rails.application.routes.draw do

  match "/login", to: UcbRailsUser::SessionsController.action(:new),
    as: "login", via: [:get]
  match "/logout", to: UcbRailsUser::SessionsController.action(:destroy),
    as: "logout", via: [:all]
  match "/auth/:omniauth_provider/callback", to: UcbRailsUser::SessionsController.action(:create),
    via: [:get]
  match "/auth/failure", to: UcbRailsUser::SessionsController.action(:failure), via: [:get]
  match "/not_authorized", to: UcbRailsUser::SessionsController.action(:not_authorized),
    as: "not_authorized", via: [:get]

  match "/admin/users/toggle_superuser", to: UsersController.action(:toggle_superuser),
    as: "admin_toggle_superuser", via: [:get]

  match "/admin/users/search", to: UsersController.action(:search),
    as: "admin_user_search", via: [:get]
  match "/admin/users/impersonate_search", to: UsersController.action(:impersonate_search),
    as: "admin_user_impersonate_search", via: [:get]
  match "/admin/users/ldap_search", to: UsersController.action(:ldap_search),
    as: "admin_user_ldap_search", via: [:get]
  resources :users, controller: "users", path: "admin/users", as: :admin_users

  resources :impersonations, controller: "ucb_rails_user/impersonations", path: "admin/impersonations", as: :admin_impersonations
  match "/admin/stop_impersonation", to: UcbRailsUser::ImpersonationsController.action(:stop_impersonation),
    as: :admin_stop_impersonation, via: [:get]

end
