

normal['wordpress']['version'] = 'latest'
normal['wordpress']['dir'] = '/var/www/wordpress/'
normal['php']['mysql']['package'] = 'php56-mysqlnd'
normal['wordpress']['db']['prefix']
normal['wordpress']['db']['root_password'] = 'password'
normal['wordpress']['db']['name'] = 'wordpress'
normal['wordpress']['db']['user'] = 'wordpress'
normal['wordpress']['db']['pass'] = 'password'
normal['wordpress']['server_name'] = 'mytestsite.com'
normal['wordpress']['server_aliases'] = ['www.mytestsite.com']



default['wordpress-rean']['yum_packages'] = ['lynx']