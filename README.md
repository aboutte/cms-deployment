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

## Parameters

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>Environment</td>
    <td>string</td>
    <td>What environment to deploy the CMS in</td>
    <td>development</td>
  </tr>
  <tr>
    <td>Application</td>
    <td>string</td>
    <td>Which CMS to deploy</td>
    <td>wordpress</td>
  </tr>
  <tr>
    <td>Hostname</td>
    <td>string</td>
    <td>What hostname to use for the CMS</td>
    <td>wordpress</td>
  </tr>
  <tr>
    <td>DBRootPassword</td>
    <td>string</td>
    <td>Password to use for root DB user</td>
    <td>redacted</td>
  </tr>
  <tr>
    <td>DBCMSPassword</td>
    <td>string</td>
    <td>Password to use when creating initial DB user for the CMS</td>
    <td>redacted</td>
  </tr>
  <tr>
    <td>CMSAdminPassword</td>
    <td>string</td>
    <td>Password to use when creating initial user in the CMS</td>
    <td>redacted</td>
  </tr>
  <tr>
    <td>CMSAdminEmail</td>
    <td>string</td>
    <td>Email address to use when creating initial user in the CMS</td>
    <td>redacted</td>
  </tr>
  <tr>
    <td>KeyName</td>
    <td>string</td>
    <td>SSH key name to use</td>
    <td>redacted</td>
  </tr>
  <tr>
    <td>SSHLocation</td>
    <td>string</td>
    <td>Public IP of workstation location used at launch time</td>
    <td>NA</td>
  </tr>
  <tr>
    <td>FrontendInstanceType</td>
    <td>string</td>
    <td>EC2 instance size to use</td>
    <td>t2.small</td>
  </tr>
</table>

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

