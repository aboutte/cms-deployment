#
# Cookbook Name:: wordpress-rean
# Recipe:: wp-cli
#
# Copyright (C) 2016 Andy Boutte
#
# All rights reserved - Do Not Redistribute
#

# http://wp-cli.org/

remote_file '/usr/local/bin/wp' do
  source 'curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end