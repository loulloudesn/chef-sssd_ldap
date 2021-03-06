#
# Author:: Tim Smith(<tsmith84@gmail.com>)
# Cookbook Name:: sssd_ldap
# Recipe:: default
#
# Copyright 2013-2014, Limelight Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# If chef_vault will be used for retrieving sensitive information
if node['sssd_ldap']['chef_vault']
  include_recipe 'chef-vault'
  vault = chef_vault_item(:credentials,'ldap')
  node.default['sssd_ldap']['sssd_conf']['ldap_default_bind_dn'] = vault['bind_dn']
  node.default['sssd_ldap']['sssd_conf']['ldap_default_authtok'] = vault['bind_passwd']
end

package 'sssd' do
  action :install
end

package 'libsss-sudo' do
  package_name value_for_platform(
    'debian' => { '< 8.0' => 'libsss-sudo0' },
    'ubuntu' => { '< 13.04' => 'libsss-sudo0' },
    'default' => 'libsss-sudo'

  )
  action :install
  only_if { platform_family?('debian') && node['sssd_ldap']['ldap_sudo'] }
end

# Only run on RHEL
if platform_family?('rhel')

  # authconfig allows cli based intelligent manipulation of the pam.d files
  package 'authconfig' do
    action :install
  end

  # https://bugzilla.redhat.com/show_bug.cgi?id=975082
  ruby_block 'nsswitch sudoers' do
    block do
      edit = Chef::Util::FileEdit.new '/etc/nsswitch.conf'
      edit.insert_line_if_no_match(/^sudoers:/, 'sudoers: files')

      if node['sssd_ldap']['ldap_sudo']
        # Add sss to the line if it's not there.
        edit.search_file_replace(/^sudoers:([ \t]*(?!sss\b)\w+)*[ \t]*$/, '\0 sss')
      else
        # Remove sss from the line if it is there.
        edit.search_file_replace(/^(sudoers:.*)\bsss[ \t]*/, '\1')
      end

      edit.write_file
    end

    action :nothing
  end

  # Have authconfig enable SSSD in the pam files
  execute 'authconfig' do
    command "authconfig #{node['sssd_ldap']['authconfig_params']}"
    notifies :run, 'ruby_block[nsswitch sudoers]', :immediately
    action :nothing
  end
end


# Run on Ubuntu
# Edit /etc/ssh/sshd_config and append the AuthorizedKeysCommand, so that SSSD retrieves user's public key from LDAP and uses it for authentication
if platform_family?('debian')

	ruby_block 'sshd_append_keyscommand' do
	  block do
	  	edit = Chef::Util::FileEdit.new '/etc/ssh/sshd_config'
	    edit.insert_line_if_no_match(/^AuthorizedKeysCommand/, 'AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys')
	    edit.insert_line_if_no_match(/^AuthorizedKeysCommandUser/, 'AuthorizedKeysCommandUser root')
	    edit.write_file
	  end
    action :run
	end
end

# Update PAM file so that user's home directories are automatically created when they login for the first time
if (node['sssd_ldap']['ldap_ssh'] && node['sssd_ldap']['pam_mkhomedir'])
  case node['platform_family']
    when 'debian'
      template '/usr/share/pam-configs/my_mkhomedir' do
        source 'mkhomedir.erb'
        owner 'root'
        group 'root'
        mode '0644'
        notifies :run, 'execute[pam-auth-update]'
      end
      execute 'pam-auth-update' do
        command 'pam-auth-update --package'
        action :run
      end
    when 'fedora', 'rhel'
      bash 'authconfig' do
        user 'root'
        code 'authconfig --enablesssd --enablesssdauth --enablemkhomedir --update'
        not_if 'grep -q pam_oddjob_mkhomedir /etc/pam.d/*'
      end
  end
end

# sssd automatically modifies the PAM files with pam-auth-update and /etc/nsswitch.conf, so all that's left is to configure /etc/sssd/sssd.conf
template '/etc/sssd/sssd.conf' do
  source 'sssd.conf.erb'
  owner 'root'
  group 'root'
  mode '0600'

  if platform_family?('rhel')
    # this needs to run immediately so it doesn't happen after sssd
    # service block below, or sssd won't start when recipe completes
    notifies :run, 'execute[authconfig]', :immediately
  end

  notifies :restart, 'service[sssd]'
end

# NSCD and SSSD don't play well together.
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/usingnscd-sssd.html
package 'nscd' do
  action :remove
end

service 'sssd' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end


# SSH Service
service_provider = nil

if platform_family?('debian ')
  if Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version'])
    service_provider = Chef::Provider::Service::Systemd
  elsif Chef::VersionConstraint.new('>= 12.04').include?(node['platform_version'])
    service_provider = Chef::Provider::Service::Upstart
  end
end

service 'ssh' do
  provider service_provider
  service_name node['sssd_ldap']['ssh_service_name']
  supports value_for_platform_family(
    %w(debian rhel fedora) => [:restart, :reload, :status],
    %w(arch) =>  [:restart],
    'default' => [:restart, :reload]
  )
  action [:enable, :restart]
end