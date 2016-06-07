# cms-rean-cookbook

The cms-rean cookbook was created to facilitate the configuration of a CMS deployment.  cms-rean has several
[dependencies](https://github.com/andyboutte/cms-deployment/blob/master/chef/cookbooks/cms-rean/Berksfile)that it relies on to do the heavy lifting.

## Supported Platforms

Tested on Amazon Linux

## Attributes

### Wrapper Attributes

Several WordPress cookbook attributes are overridden in cms-rean.  See the [WordPress](https://github.com/brint/wordpress-cookbook) cookbook README for details.

### cms-rean Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cms-rean']['yum_packages']</tt></td>
    <td>array</td>
    <td>List of packages to install at deploy time</td>
    <td><tt>['lynx', 'htop', 'sysstat']</tt></td>
  </tr>
</table>

### Attributes passed in from CloudFormation

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cloud']['application']</tt></td>
    <td>string</td>
    <td>Controlls which recipe to include in the default recipe</td>
    <td><tt>none</tt></td>
  </tr>
  <tr>
    <td><tt>['cloud']['hostname']</tt></td>
    <td>string</td>
    <td>Sets the OS hostname and httpd ServerName</td>
    <td><tt>none</tt></td>
  </tr>
  <tr>
    <td><tt>['cloud']['mysql']['root_user_password']</tt></td>
    <td>string</td>
    <td>MySQL root password</td>
    <td><tt>none</tt></td>
  </tr>
  <tr>
    <td><tt>['cloud']['mysql']['cms_user_password']</tt></td>
    <td>string</td>
    <td>MySQL password for user the CMS uses</td>
    <td><tt>none</tt></td>
  </tr>
  <tr>
    <td><tt>['cloud']['cms']['admin_user_password']</tt></td>
    <td>string</td>
    <td>Password used for the initial CMS user</td>
    <td><tt>none</tt></td>
  </tr>
  <tr>
    <td><tt>['cloud']['cms']['admin_user_email']</tt></td>
    <td>string</td>
    <td>Email address for the initial CMS user</td>
    <td><tt>none</tt></td>
  </tr>
</table>


## Usage

### cms-rean::default

- sets hostname
- installs some additional packages that would be useful for troubleshooting
- depending on `node['cloud']['application']` include the wordpress or drupal recipe (drupal not currently implemented)

### cms-rean::wordpress

This recipe includes the WordPress cookbook that does all the heavy lifting.  The WordPress cookbook provides the following:

- installs php
- install httpd
- lays down a virtual host file for WordPress
- install MySql
- configures MySQL root password and WordPress specific user

The last thing cms-rean::wordpress does is complete the initial WordPress site setup using the wp-cli


### cms-rean::users

Adds all sysadmin users from databags and allows sysadmin group root access

## License and Authors

Author:: Andy Boutte
