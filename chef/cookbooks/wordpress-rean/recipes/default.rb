#
# Cookbook Name:: wordpress-rean
# Recipe:: default
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