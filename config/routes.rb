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

  match "/admin/users/toggle_superuser", to: UcbRailsUser::UsersController.action(:toggle_superuser),
    as: "admin_toggle_superuser", via: [:get]

  resources :users, controller: "ucb_rails_user/users", path: "admin/users", as: :admin_users

end
