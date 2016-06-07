
# Using chef-dk
rpm -ivh https://packages.chef.io/stable/el/6/chefdk-0.14.25-1.el6.x86_64.rpm

# Using chef-client
#export CHEF_VERSION="12.10.24"
#curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -v $CHEF_VERSION && rm -f install.sh

# Pull down the application cookbook from GitHub
export HOME=/root/
mkdir -p /etc/chef/
cd /tmp/
git clone https://github.com/andyboutte/cms-deployment.git
mv cms-deployment/chef/* /etc/chef/

cat <<EOF > /etc/chef/client.rb
log_level       :warn
log_location    "/var/log/chef-client.log"
node_name       "$INSTANCE_ID"
chef_repo_path  "/etc/chef/"
cookbook_path   "/etc/chef/cookbooks/"
data_bag_path   "/etc/chef/databags/"
environment     "{{ref('Environment')}}"
local_mode      true
json_attribs    "/etc/chef/json_attributes.json"
EOF

# Create the json attributes file to define the run list and cloudformation parameters
cat <<EOF > /etc/chef/json_attributes.json
{
  "run_list": [
    "cms-rean"
  ],
  "cloud": {
    "application": "{{ref('Application')}}",
    "hostname": "{{ref('Hostname')}}",
    "mysql": {
      "root_user_password": "{{ref('DBRootPassword')}}",
      "cms_user_password": "{{ref('DBCMSPassword')}}"
    },
    "cms": {
      "admin_user_password": "{{ref('CMSAdminPassword')}}",
      "admin_user_email": "{{ref('CMSAdminEmail')}}"
    }
  }
}
EOF

# Pull down all the dependency cookbooks
cd /etc/chef/cookbooks/cms-rean
/usr/bin/berks vendor /etc/chef/cookbooks/

# Run chef
chef-client
