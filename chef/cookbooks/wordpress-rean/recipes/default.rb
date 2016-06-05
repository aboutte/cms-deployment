#
# Cookbook Name:: wordpress-rean
# Recipe:: default
#
# Copyright (C) 2016 Andy Boutte
#
# All rights reserved - Do Not Redistribute
#

if node['cloud']['application'] == 'wordpress'

  include_recipe 'wordpress-rean::users'
  include_recipe 'wp-cli'
  include_recipe 'wordpress-rean::wordpress'

elsif node['cloud']['application'] == 'drupal'

else
  Chef::Application.fatal!("#{node['cloud']['application']} is unsupported!}", 1)
end