
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
cat <<EOF > /etc/chef/json_attributes_cloudformation.json
{
  "run_list": [
    "wordpress-rean"
  ],
  "cloud": {
    "application": "{{ref('Application')}}"
  }
}
EOF

aws --region {{aws_region}} s3 cp s3://rean-us-west-2-aboutte/#{parameters['Application']}/#{parameters['Environment']}/json_attributes_sensitive.json /etc/chef/json_attributes_sensitive.json

# Merge the json_attributes files into one file for Chef to read in
jq -s '.[0] * .[1]' /etc/chef/json_attributes_cloudformation.json /etc/chef/json_attributes_sensitive.json > /etc/chef/json_attributes.json

# Pull down all the dependency cookbooks
cd /etc/chef/cookbooks/wordpress-rean
/usr/bin/berks vendor /etc/chef/cookbooks/

# Create an alias for rerunning chef-client

# run chef

chef-client
