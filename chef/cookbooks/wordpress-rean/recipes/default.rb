#
# Cookbook Name:: wordpress-rean
# Recipe:: default
#
# Copyright (C) 2016 Andy Boutte
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'wordpress-rean::users'
include_recipe 'wp-cli'
include_recipe 'wordpress-rean::wordpress'