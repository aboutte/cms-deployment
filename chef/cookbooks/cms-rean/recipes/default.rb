#
# Cookbook Name:: cms-rean
# Recipe:: default
#
# Copyright (C) 2016 Andy Boutte
#
# All rights reserved - Do Not Redistribute
#

# Update /etc/hosts so that httpd does not complain
hostname node['cloud']['hostname']

node['cms-rean']['yum_packages'].each do |yum_package|
  package yum_package do
    action :install
  end
end

if node['cloud']['application'] == 'wordpress'

  include_recipe 'cms-rean::users'
  include_recipe 'wp-cli'
  include_recipe 'cms-rean::wordpress'

elsif node['cloud']['application'] == 'drupal'

else
  Chef::Application.fatal!("#{node['cloud']['application']} is unsupported!}", 1)
end