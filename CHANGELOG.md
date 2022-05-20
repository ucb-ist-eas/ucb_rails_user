4.1.0
-----
   * Update dependencies to latest versions. ([PR #81](https://github.com/ucb-ist-eas/ucb_rails_user/pull/81))
   * Improve scoping of "Add New" button CSS on Users screen. ([PR #81](https://github.com/ucb-ist-eas/ucb_rails_user/pull/81), resolveing [issue #21](https://github.com/ucb-ist-eas/ucb_rails_user/issues/21))
   * Support lived names by optionally pulling employee data from UCPath rather than LDAP. ([PR #84](https://github.com/ucb-ist-eas/ucb_rails_user/pull/84))


4.0.7
-----

   * Update puma to address security issue. ([PR #59](https://github.com/ucb-ist-eas/ucb_rails_user/pull/59))
   * Update addressable to address security issue. ([PR #61](https://github.com/ucb-ist-eas/ucb_rails_user/pull/61))


4.0.6
-----

Add support for customizing which columns in the user admin section are not sorted. ([PR #60](https://github.com/ucb-ist-eas/ucb_rails_user/pull/60))

4.0.5
-----

Fix conversion of LDAP string to Ruby String ([PR #53](https://github.com/ucb-ist-eas/ucb_rails_user/pull/53))

4.0.4
-----

   * Add support for LDAP searches ([PR #48](https://github.com/ucb-ist-eas/ucb_rails_user/pull/48))
   * Fix exceptions with skip_before_action ([PR #49](https://github.com/ucb-ist-eas/ucb_rails_user/pull/49))

4.0.3
-----

Fix deprecation warnings for Rails 6 ([PR #40](https://github.com/ucb-ist-eas/ucb_rails_user/pull/40))


4.0.2
-----

Cascade deletes from `User` to `Impersonation` ([PR #36](https://github.com/ucb-ist-eas/ucb_rails_user/pull/36))


4.0.1
-----

Upgrade to haml-rails 2.x ([PR #26](https://github.com/ucb-ist-eas/ucb_rails_user/pull/26))


4.0.0
-----

   * Security upgrade(PR [#24](https://github.com/ucb-ist-eas/ucb_rails_user/pull/24))
   * Move out of beta phase

4.0.0.beta1
-----

Security upgrade to dependencies(PR [#16](https://github.com/ucb-ist-eas/ucb_rails_user/pull/16), [#17](https://github.com/ucb-ist-eas/ucb_rails_user/pull/17), [#18](https://github.com/ucb-ist-eas/ucb_rails_user/pull/18), [#18](https://github.com/ucb-ist-eas/ucb_rails_user/pull/18), [#19](https://github.com/ucb-ist-eas/ucb_rails_user/pull/19), [#20](https://github.com/ucb-ist-eas/ucb_rails_user/pull/20))

Upgrade to Rails 6(PR [#22](https://github.com/ucb-ist-eas/ucb_rails_user/pull/22))

3.0.1
-----

Add various UI tweaks to the impersonation feature([PR #14](https://github.com/ucb-ist-eas/ucb_rails_user/pull/14))

3.0.0
-----

Add user impersonation feature([PR #13](https://github.com/ucb-ist-eas/ucb_rails_user/pull/13))

2.0.1
-----

Minor release for a style change ([PR #10](https://github.com/ucb-ist-eas/ucb_rails_user/pull/10))

2.0.0
-----

Switch the user's `employee_id` to the new UCPath ID ([PR #8](https://github.com/ucb-ist-eas/ucb_rails_user/pull/8))

1.1.3
-----

Make sure all user attributes are included when updating an existing user record([57c0a9](https://github.com/ucb-ist-eas/ucb_rails_user/commit/57c0a9b9162bf42f9469a79d6f9b04c4777581a4))

1.1.2
-----

Correctly fetch student id from LDAP ([29f724](https://github.com/ucb-ist-eas/ucb_rails_user/commit/29f724084ae1de1dbf5cdbf6d670ed393453b0fd))

1.1.1
------

Make the user admin table responsive ([7ad233e](https://github.com/ucb-ist-eas/ucb_rails_user/commit/7ad23e388edd9cfa805fce9b44bc4680bced9968))

1.1.0
------

Add better testing support ([#6](https://github.com/ucb-ist-eas/ucb_rails_user/pull/6))

1.0.0
------

Upgrade to Datatables 1.10.18 and Bootstrap 4

0.9.0
------

Initial release, using Bootstrap 3
