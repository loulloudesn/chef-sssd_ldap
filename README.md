# sssd_ldap Cookbook

[![Build Status](https://travis-ci.org/tas50/chef-sssd_ldap.svg?branch=master)](https://travis-ci.org/tas50/chef-sssd_ldap) [![Cookbook Version](https://img.shields.io/cookbook/v/sssd_ldap.svg)](https://supermarket.chef.io/cookbooks/sssd_ldap)

This cookbook installs SSSD and configures it for LDAP authentication. As part of the setup of SSSD it will also remove the NSCD package as NSCD is known to interfere with SSSD (<https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/usingnscd-sssd.html>).

## Requirements

### Platforms

- Redhat
- Centos
- Amazon
- Scientific
- Oracle
- Ubuntu
- Debian

### Chef

- Chef 11+

### Cookbooks

- none

## Attributes

Arbitrary key/value pairs may be added to the `['sssd_conf']` attribute object. These key/values will be expanded in the domain block of `sssd.conf`. This allows you to set any SSSD configuration value you want, not just ones provided by the attributes in this cookbook.

Attribute                                  | Value                                                                          | Comment
------------------------------------------ | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------
`['sssd_ldap']['chef_vault']`              | `'true`                   | use chef-vault (true/false) for retrieving sensitive SSSD information. For now support is provided only for `bind_dn` and `bind_password`. Hence, if se to true, default attributes `['sssd_conf']['ldap_default_bind_dn']` and `['sssd_conf']['ldap_default_authtok']`  are overriden                  

`['sssd_conf']['id_provider']`             | `'ldap'`                                                                       |
`['sssd_conf']['auth_provider']`           | `'ldap'`                                                                       |
`['sssd_conf']['chpass_provider']`         | `'ldap'`                                                                       |
`['sssd_conf']['sudo_provider']`           | `'ldap'`                                                                       |
`['sssd_conf']['enumerate']`               | `'true'`                                                                       |
`['sssd_conf']['cache_credentials']`       | `'false'`                                                                      |
`['sssd_conf']['ldap_schema']`             | `'rfc2307bis'`                                                                 |
`['sssd_conf']['ldap_uri']`                | `'ldap://something.yourcompany.com'`                                           |
`['sssd_conf']['ldap_search_base']`        | `'dc=yourcompany,dc=com'`                                                      |
`['sssd_conf']['ldap_user_search_base']`   | `'ou=People,dc=yourcompany,dc=com'`                                            |
`['sssd_conf']['ldap_user_object_class']`  | `'posixAccount'`                                                               |
`['sssd_conf']['ldap_user_name']`          | `'uid'`                                                                        |
`['sssd_conf']['override_homedir']`        | `nil`                                                                          |
`['sssd_conf']['shell_fallback']`          | `'/bin/bash'`                                                                  |
`['sssd_conf']['ldap_group_search_base']`  | `'ou=Groups,dc=yourcompany,dc=com'`                                            |
`['sssd_conf']['ldap_group_object_class']` | `'posixGroup'`                                                                 |
`['sssd_conf']['ldap_id_use_start_tls']`   | `'true'`                                                                       |
`['sssd_conf']['ldap_tls_reqcert']`        | `'never'`                                                                      |
`['sssd_conf']['ldap_tls_cacert']`         | `'/etc/pki/tls/certs/ca-bundle.crt'` or `'/etc/ssl/certs/ca-certificates.crt'` | defaults for RHEL and others respectively
`['sssd_conf']['ldap_default_bind_dn']`    | `'cn=bindaccount,dc=yourcompany,dc=com'`                                       | if you have a domain that doesn't require binding set this attributes to nil
`['sssd_conf']['ldap_default_authtok']`    | `'bind_password'`                                                              | if you have a domain that doesn't require binding set this to nil
`['authconfig_params']`                    | `'--enablesssd --enablesssdauth --enablelocauthorize --update'`                |
`['sssd_conf']['access_provider']`         | `nil`                                                                          | Should be set to `'ldap'`
`['sssd_conf']['ldap_access_filter']`      | `nil`                                                                          | Can use simple LDAP filter such as `'uid=abc123'` or more expressive LDAP filters like `'(&(objectClass=employee)(department=ITSupport))'`
`['sssd_conf']['min_id']`                  | `'1'`                                                                          | default, used to ignore lower uid/gid's
`['sssd_conf']['max_id']`                  | `'0'`                                                                          | default, used to ignore higher uid/gid's
`['ldap_sudo']`                            | `false`                                                                        | Adds ldap enabled sudoers (true/false)
`['ldap_ssh']`                             | `false`                                                                        | Adds ldap enabled ssh keys (true/false)
`['ldap_autofs']`                          | `false`                                                                        | Adds ldap enabled autofs config (true/false)

## Recipes

- default: Installs and configures sssd daemon

## CA Certificates

If you manage your own CA then the easiest way to inject the certificate for system-wide use is as follows:

### RHEL

```
cp ca.crt /etc/pki/ca-trust/source/anchors
update-ca-trust enable
update-ca-trust extract
```

### Debian

```
cp ca.crt /usr/local/share/ca-certificates
update-ca-certificates
```

## Use of Chef-Vault

If you decide to retrieve SSSD sensitive information from [Chef-Vault](https://docs.chef.io/chef_vault.html), by setting attribute `['sssd_ldap']['chef_vault'] = true`, then you need to create a vault with name `credentials` and a respective item inside the vault with name `ldap`.

For now, the vault is mandatory to include the following two attributes: 
- `bind_dn`
- `bind_passwd`

A comprehensive tutorial on creating encrypted vaults is provided [here](https://blog.chef.io/2016/01/21/chef-vault-what-is-it-and-what-can-it-do-for-you/). Use the following JSON as a template file (i.e `ldap.json`) for creating the vault:

```json
{  
   "bind_dn":"some_text",
   "bind_passwd":"some_other_text"
}
```

## License & Authors

**Author:** Tim Smith - ([tsmith84@gmail.com](mailto:tsmith84@gmail.com))

**Copyright:** 2013-2015, Limelight Networks, Inc.

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
