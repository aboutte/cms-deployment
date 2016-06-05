
normal['wordpress']['version'] = 'latest'
normal['wordpress']['dir'] = '/var/www/wordpress/'
normal['php']['mysql']['package'] = 'php56-mysqlnd'
normal['wordpress']['db']['prefix'] = ('a'..'z').to_a.shuffle[0,3].join
normal['wordpress']['db']['root_password'] = node['cloud']['mysql']['root_user_password']
normal['wordpress']['db']['name'] = 'wordpress'
normal['wordpress']['db']['user'] = 'wordpress'
normal['wordpress']['db']['pass'] = node['cloud']['mysql']['cms_user_password']
normal['wordpress']['server_name'] = node['cloud']['hostname']
normal['wordpress']['server_aliases'] = ["www.#{node['cloud']['hostname']}"]

#TODO: hook this up
normal['wordpress']['languages']['themes'] = ['https://downloads.wordpress.org/theme/xylus.1.6.zip', 'https://downloads.wordpress.org/theme/mh-techmagazine.1.0.8.zip']



default['wordpress-rean']['yum_packages'] = ['lynx', 'htop', 'sysstat']