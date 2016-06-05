
yum update -y

# Install dependencies for berkshelf gem
yum -y install gcc ruby-devel rubygems

# Install general dependencies that can not be managed by chef
yum -y install git jq
