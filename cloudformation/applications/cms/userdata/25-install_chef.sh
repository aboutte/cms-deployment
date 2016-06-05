
# Using chef-dk
rpm -ivh https://packages.chef.io/stable/el/6/chefdk-0.14.25-1.el6.x86_64.rpm

# Using chef-client
#export CHEF_VERSION="12.10.24"
#curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -v $CHEF_VERSION && rm -f install.sh

mkdir -p /etc/chef/cookbooks/
mkdir -p /etc/chef/data_bags/
mkdir -p /etc/chef/environments/


cat <<EOF > /etc/chef/client.rb
log_level       :warn
log_location    "/var/log/chef-client.log"
node_name       "$INSTANCE_ID"
chef_repo_path  "/etc/chef/"
cookbook_path   "/etc/chef/cookbooks/"
data_bag_path   "/etc/chef/data_bags/"
environment     "{{ref('Environment')}}"
local_mode      true
json_attribs    "/etc/chef/json_attributes.json"
EOF

# Create the json attributes file to define the run list and cloudformation parameters

cat <<EOF > /etc/chef/json_attributes.json
{
  "run_list": [
    "wordpress-rean"
  ],
  "cloud": {
    "hostname": "{{ref('Hostname')}}",
    "wordpress": {
      "key": "value"
    },
    "mysql": {
      "root_user_password": "value",
      "wordpress_user_password": "value"
    }
  }
}
EOF

# Pull down the application cookbook from GitHub



# Pull down all the dependency cookbooks
cd /etc/chef/cookbooks/wordpress-rean
/usr/bin/berks vendor /etc/chef/cookbooks/

# Create an alias for rerunning chef-client

# run chef

chef-client
