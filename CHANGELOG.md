# CHANGELOG for sssd_ldap

This file is used to list changes made in each version of sssd_ldap.

## 3.1.2 (2016-07-28)
- Added support for chef-vault, so that SSSD sensitive information (i.e bind_dn, bind_authtok) are retrieved from an encrypted vault.
- REQUIRED: Vault item name to be `:credentials['ldap']`
- Setting attribute `node['sssd_ldap']['chef_vault']` to true assigns values to `['sssd_ldap']['sssd_conf']['ldap_default_bind_dn'] ` and
`['sssd_ldap']['sssd_conf']['ldap_default_authtok']` from the vault

## 3.1.1 (2016-07-19)
- Added support so that SSSD retrieves user's public key from LDAP and uses it for authentication. Also restarts the SSH service for changes to take effect.
- Added support so that recipe identifies the corrent naming of the SSH service depending on the underlying platform.
- Added support to recipe to allow updating a PAM file so that user's home directories are automatically created when they login for the first time.

## 3.1.0 (2016-04-27)

- Added back support for RHEL 5 by making sure not to enable the sudo service on RHEL < 6 as the package is too old
- Switched Test Kitchen testing in Travis CI to kitchen-dokken
- Added support for Ubuntu 15.10+ by removing the hardcoded Upstart service provider on Ubuntu 13.10 or later. Chef 12 can auto determine the provider to use
- Added testing on Fedora 23 / Debian 8 / Ubuntu 16.04 / CentOS 5 in Travis CI

## 3.0.1 (2015-12-24):

- Added 2 new attributes for enabling autofs and ssh support, both of which default to false
- nil values for config options are now skipped in the config to prevent bad configs from being written out
- Added test kitchen integration testing in Travis CI

## 3.0.0 (2015-10-22):

- BREAKING: All config file attributes have been moved into the `node['sssd_ldap']['sssd_conf']` hash. You can add any key value config items to this by just adding to the hash.
- Add test kitchen config. Example: `node['sssd_ldap']['sssd_conf']['something'] = true`
- Update Travis to run unit/lint testing via ChefDK instead of Gems and to run kitchen-docker for integration testing
- Use the standard Chef rubocop config
- Update development deps to the latest in the Gemfile
- Require at least Chef 11

## 2.0.0:

- BREAKING: Change default['sssd_ldap']['ldap_tls_cacertdir'] to default['sssd_ldap']['ldap_tls_cacert'] and use per platform value
- BREAKING: default['sssd_ldap']['ldap_sudo'] is a boolean value now not a string
- BREAKING: nsswitch.conf is no longer templated, but edited inline instead
- BREAKING: NSCD package is now removed instead of stopping the service
- Debian support added
- ldap_group_name added to sssd.confg via default['sssd_ldap']['ldap_group_name'] attribute
- source_url and issues_url added to the metadata
- sssd is always restarted after templating the config now
- Chefspec unit tests added
- Use standard chef .gitignore file
- Update rules in the .rubocop.yml file
- Have Travis test on Ruby 2.2 and remove 1.9 from testing
- Add a Berksfile
- Update Gemfile deps and break out into groups
- Add a license file
- Add cookbook version badge to the readme
- Additional files added to the chefignore file

## 1.0.2:

- Added support for min_id / max_id
- Added support for conditional sudoers
- Added attributes to the Readme
- Updated Rubocop to 0.27

## 1.0.0:

- Switch modes to be strings not ints
- Remove duplicate reference to the config template
- Add shell_fallback attribute
- Support Ubuntu 13.04 and later with Upstart
- Allow authenticating to servers that don't require binding

## 0.1.6:

- Supports Ubuntu

## 0.1.5:

- Added some more configurable attributes

## 0.1.0:

- Initial release of sssd_ldap
