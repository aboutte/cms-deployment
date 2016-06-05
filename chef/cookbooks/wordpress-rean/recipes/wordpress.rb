#
# Cookbook Name:: wordpress-rean
# Recipe:: wordpress
#
# Copyright (C) 2016 Andy Boutte
#
# All rights reserved - Do Not Redistribute
#

hostname node['cloud']['hostname']


node['wordpress-rean']['yum_packages'].each do |yum_package|
  package yum_package do
    action :install
  end
end

include_recipe 'wordpress'

# Now that php, httpd, and wordpress are installed use the wp cli to finish the initial configuration of WordPress
execute 'Perform initial configuration of WordPress' do
  command "/usr/local/bin/wp core install --allow-root --path=#{node['wordpress']['dir']} --url=#{node['cloud']['hostname']} --title=#{node['cloud']['hostname']} --admin_user=wordpress --admin_password=#{node['cloud']['cms']['admin_user_password']} --admin_email=#{node['cloud']['cms']['admin_user_email']}"
  action :run
end
