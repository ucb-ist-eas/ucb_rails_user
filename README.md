# UCB Rails User

A [Rails engine](http://guides.rubyonrails.org/engines.html) that provides authentication and user management for UCB Rails apps. By adding this engine to your app, you get:

  * login and logout via [CAS](https://calnetweb.berkeley.edu/calnet-technologists/cas)
  * automatic creation of user records following CAS authentication
  * controller filters that block access to resources unless user is logged in
  * a default home page that reflects user's login status
  * admin screens for updating and deleting user records
  * ability for admins to impersonate other users
  * optional generator to create a users table that's compatible with this gem

This engine also includes the [Datatables](https://datatables.net/) JQuery plug-in, which is used in the user management screens, and [typeahead.js](https://github.com/twitter/typeahead.js) for autocomplete. Host apps can make use of these libraries as well.

## Conversion to UCPath

Version 2.0 and greater of this gem sets a user's `employee_id` to the new UCPath employee id, rather than the legacy HCM employee id. If you need to use the older ID, use version 1.1.3 of this gem, or lower.

## Upgrading to version 6.0+

See [this wiki page](https://github.com/ucb-ist-eas/ucb_rails_user/wiki/Upgrading-to-version-6.0) for details.

## Upgrading to version 3.0+ from version 2.x

See [this wiki page](https://github.com/ucb-ist-eas/ucb_rails_user/wiki/Upgrading-to-version-3.0) for details.

## Prerequisites

  * Ruby >= 3.0
  * Rails >= 6.0

Older versions may work as well, but they haven't been tested.

## Installation

The easiest way to use this is to generate a new app with the [ucb_rails command-line tool](https://github.com/ucb-ist-eas/ucb_rails_cli), which has this engine integrated as a gem and automates most of the steps below for you.

But if you need to add this to an already-existing app, do the following:

1. Add the required gems to your Gemfile:

```ruby
gem "ucb_rails_user", github: "ucb-ist-eas/ucb_rails_user"
gem "ucb_ldap", github: "ucb-ist-eas/ucb-ldap"
```

then run `bundler` to install them:

```bash
bundle install
```

2. Set the `RAILS_MASTER_KEY` environment variable and setup an encrypted credentials file containing (at least) the credentials needed to connect to LDAP (ask another dev to help get this setup for you).

3. Add this line to your host app's `ApplicationController:`

```ruby
include UcbRailsUser::AuthConcerns
```

4. Copy [this initializer file](https://github.com/ucb-ist-eas/ucb_rails_cli/blob/master/lib/ucb_rails_cli/templates/config/initializers/ucb_rails_user.rb) into your host app's `config/initializer` directory.

5. Setup a root path in `config/routes.rb`, if you haven't already. You can use the default home page provided by this gem, if you like:

```ruby
root to: UcbRailsUser::HomeController.action(:index)
```

6. Copy the migrations for the `Impersonation` models from the engine into your host app, and run them:

```
bin/rails railties:install:migrations
bin/rake db:migrate
```

7. (optional) If you don't already have a `users` table, you can generate one with a Rails task (see next section below)

8. Update your assets files

In `application.css` add this line:

```
*= require ucb_rails_user/main
```

And in `application.js` add this line:

```
//= require ucb_rails_user/scripts
```

9. Restart your host app as usual

You should be able to access the following routes:

  * `/`: if you're using `UcbRailsUser::HomeController#index` as your home page, you should see a simple screen showing your login status
  * `/login`: this should redirect you to the main CAS login page
  * `/logout`: this should log you out of CAS and redirect you back to the host app
  * `/admin/users`: this should display the user management screen, if your user account has the `superuser` flag set; otherwise, you'll see a 401 page
  * `/admin/impersonations`: this is the page used to start impersonating another user (see below)
  * `/admin/stop_impersonation`: this stops an active impersonation
  * `/admin/users/toggle_superuser`: in dev mode, you can use this url to turn the superuser flag of your account on and off

## User model

This gem does not define a model representing a user - that is left to the host app. However, if you don't have such a model yet, you can generate a migration for one by running:

```bash
bin/rails ucb_rails_user:create_users_table
```

This will create a migration for a `users` table containing the fields this gem expects to see.

### Alternate naming

By default, this gem expects the user model to be named `User`, but if you're using a different class name, you can specify that name in an initializer (e.g. `config/initializers/ucb_rails_user.rb`):

```ruby
UcbRailsUser.user_class = "Entity"
```

## Routing

The [config/routes.rb file](https://github.com/ucb-ist-eas/ucb_rails_user/blob/master/config/routes.rb) will show you the routes that this engine provides out of the box. But if necessary, you can override these routes in your host app.

For example, if the admin screens for your app are under the `/backend` path rather than `/admin,` you can rewrite the route in your host app like this:

```ruby
resources :users, controller: "ucb_rails_user/users", path: "backend/users", as: :backend_users
```

## Session Managers

Authentication during login is handled by UCB's central auth system and this gem uses the [omniauth-cas](https://github.com/dlindahl/omniauth-cas) to manage the handshake. Once that is completed, we're handed the LDAP uid of the authenticated user, and, by default, this gem will attempt to pull the user's employee data and create or update a `User` record for them in the local database.

This behavior can be customized by writing your own user session manager. There are two steps to do this:

   1. Create a subclass of [`UcbRailsUser::UserSessionManager::Base`](https://github.com/ucb-ist-eas/ucb_rails_user/blob/main/app/models/ucb_rails_user/user_session_manager/base.rb). At a minimum you need to implement a `login` method that accepts the user's LDAP uid and returns a `User` instance (or raises an error if the process fails), and a `current_user` method that returns the `User` instance for the currently-logged-in user. [Several implementations](https://github.com/ucb-ist-eas/ucb_rails_user/tree/main/app/models/ucb_rails_user/user_session_manager) are included so you can look to these to base yours off of.

   1. Open `config/initializers/ucb_rails_user.rb` in your host app and change the `user_session_manager` config setting to the class your custom implementation:

```
    config.user_session_manager = "MyApp::MyCustomUserSessionManager"
```

## User Impersonation

The impersonation feature allows admins to be logged in as a different user in the system. This is useful when trying to diagnose data-specific problems, as the admin can see exactly what the user sees.

### Impersonation Permissions

By default, this feature is only available to superusers, but you can change this by overriding the `User#can_impersonate?` method and implementing any logic you prefer. See "Overriding Model And Controller Behavior" to see how to override methods in the `User` class.

### Determining Who The Real User Is

In the past, this gem provided a controller and helper method called `current_user` which returned the `User` record associated with the logged-in user. With the impersonation feature in place, this behavior changes slightly.

As of version 3.0, `current_user` returns the currently logged-in user, unless that user is impersonating another user. In that case, `current_user` will return the impersonated user (referred to as the impersonation "target" in the code). Most of our existing apps rely on `current_user` to determine what should or should not be displayed, so the impersonation feature will work best for existing apps if `current_user` returns the impersonated user.

Version 3.0 also adds a new method called `logged_in_user` that always returns the actual logged-in user (whether or not that user is impersonating someone else).

For example:

Alice is an admin who has logged into the system:
   * `logged_in_user` returns Alice
   * `current_user` returns Alice

Alice then starts impersonating Bob:
   * `logged_in_user` returns Alice
   * `current_user` returns Bob

Alice stops impersonating Bob:
   * `logged_in_user` returns Alice
   * `current_user` returns Alice

## Auth Helpers

If you followed the setup instructions above, your `ApplicationController` should be including `UcbRails::AuthConcerns.` This provides a number of utility methods you can use in your controllers:

  * `current_user`: returns the `User` instance for the currently logged-in user, or `nil` if user is not logged in. If the logged-in user is impersonating another user, this will return the impersonated user
  * `logged_in_user`: this returns the user who logged in with their Calnet credentials, even if that user is impersonating another user
  * `current_ldap_person`: returns the `UCB::LDAP::Person` instance for the currently logged-in user, or `nil` if user is not logged in
  * `logged_in?`: returns true if the user is logged in
  * `superuser?`: returns true if the current user has the superuser flag set to true
  * `ensure_authenticated_user`: returns a 401 error if the user is not logged in
  * `ensure_admin_user`: returns a 401 error if the user is not a superuser

`current_user`, `logged_in_user`, `current_ldap_person`, `logged_in?` and `superuser?` are all helper methods, so you can use them in views as well as controllers.

`ensure_authenticated_user` is set as a `before_filter` so by default, all pages will require a login (except the `HomeController` included in this gem).

To make a page available to a non-logged-in user, add this line to your controller:

```ruby
skip_before_action :ensure_authenticated_user
```

`UsersController` uses `ensure_admin_user` as a `before_filter`

## Testing Support

This engine comes with a few features to help with testing.

The `UcbRailsUser::UserSessionManager::TestSessionManager` is a specialized session manager designed for test cases. It overrides the `login` method to lookup the given `uid` in the `users` table of the database. As long as the user record already exists, the `login` method will return successfully.

There is also a `UcbRailsUser::SpecHelpers` module that provides some support methods. Specifically, the `login_user` method can be used in request or integration specs to perform the behind-the-scenes work needed to login a given user. This method is implemented according to the [omniauth gem documentation.](https://github.com/omniauth/omniauth/wiki/Integration-Testing)

To add the testing support, add the following lines to your `spec_helper.rb` or `rails_helper.rb` file:

```ruby
# add this line
require 'ucb_rails_user/spec_helpers'

# then, somewhere in this block...
RSpec.configure do |config|

  ...

  # ...add these lines
  config.include UcbRailsUser::SpecHelpers
  UcbRailsUser.config do |config|
    config.user_session_manager = "UcbRailsUser::UserSessionManager::TestSessionManager"
  end
```

Then, from within any request spec, you should be able to do this:

```ruby
  it "should do some neato feature" do
    user = create(:user) # assumes you've added FactoryBot or similiar
    login_user(user)
  end
```

and the user should now be logged in.

*NOTE:* For system specs, the logic is a little different - use `system_login_user` rather than `login_user` in these specs.


## Overriding Model And Controller Behavior

The host app can add or override behavior of the `User` model and `UserController` as needed. We've followed the conventions suggested in the [Rails guide](http://guides.rubyonrails.org/engines.html#implementing-decorator-pattern-using-activesupport-concern) to make this as easy as possible.

To add to the `User` model, create a file named `app/models/user.rb` in your host app, and add the following code:

```ruby
class User < ApplicationRecord
  include UcbRailsUser::UserConcerns

  # add your code here

end
```

Similarly, to override `UserController,` add `app/controllers/ucb_rails/user_controller.rg` and add the following:

```ruby
class UcbRailsUser::UsersController < ApplicationController
  include UcbRailsUser::UsersControllerConcerns

  # add your code here

end
```

## Overriding The Default Home Page

If you're using the `HomeController` provided by this engine for your home page, you can change the views that are used for the logged in and not logged in states.

  * create the directory `app/views/ucb_rails_user/home`
  * inside that directory, create two files:
      * `logged_in.html.haml`
      * `not_logged_in.html.haml`

One of those two views will render when the user hits the home page, depending on whether or not they're currently logged in.
