#
# Cookbook Name:: cms-rean
# Recipe:: wordpress
#
# Copyright (C) 2016 Andy Boutte
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'wordpress'

# Now that php, httpd, and wordpress are installed use the wp cli to finish the initial configuration of WordPress
wp_cli_command 'core install' do
  args(
      'path' => node['wordpress']['dir'],
      'title' => node['cloud']['hostname'],
      'url' => node['cloud']['hostname'],
      'admin_user' => 'wordpress',
      'admin_password' => node['cloud']['cms']['admin_user_password'],
      'admin_email' => node['cloud']['cms']['admin_user_email'],
      'allow-root' => ''
  )
end