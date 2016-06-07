# cms-deployment

## Summary

This repository contains the tools to create a WordPress deployment in an AWS environment.

Tools used:

- [cloudformation-ruby-dsl](https://github.com/bazaarvoice/cloudformation-ruby-dsl) - Used to manage the creation of CloudFormation templates
- [berkshelf](http://berkshelf.com/) - berkshelf is used to manage the chef cookbook dependencies
- [chef-client](https://docs.chef.io/chef_client.html) - chef-client (in local_mode) is used to converge the EC2 instance into the expected state (running httpd, PHP, MySQL, WordPress)


## Using Expanded .json Templates

The expanded CloudFormation templates can be found in the [expanded](https://github.com/andyboutte/cms-deployment/tree/master/cloudformation/applications/cms/expanded) directory.
These expanded templates are the output of the cloudformation-ruby-dsl and are ready for use.

## Installing from GitHub

If development work is needed in the CloudFormation area go through this section.

### Prerequisites

- AWS credentials setup.  Example using environment variables in `~/.bash_profile`:

```
export AWS_ACCESS_KEY_ID="xxxxxxxx"
export AWS_SECRET_ACCESS_KEY="xxxxxxxx"
```
- A sane Ruby environment setup on your workstation.  The recommended approach would be to install the [ChefDK](https://downloads.chef.io/chef-dk/)

### Install

```
# Clone repo from GitHub
git clone https://github.com/andyboutte/cms-deployment.git
cd cms-deployment
gem install bundler
bundle install
cd applications/cms/
```

### Usage

##### Usage:

```
$ ./cms.rb
usage: ./cms.rb <expand|diff|validate|create|update|cancel-update|delete|describe|describe-resource|get-template>
```

##### Launching CloudFormation stack:

```
bundle exec ./cms.rb create --region us-west-2 --stack-name wordpress-production-$(date '+%s') --disable-rollback --parameters "Application=wordpress;Environment=production"
```

##### Expand Ruby CloudFormation template into json:

```
bundle exec ./cms.rb expand --parameters "Application=wordpress;Environment=production"
```

