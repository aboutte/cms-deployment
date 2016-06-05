#!/usr/bin/env ruby

require '../../lib/preload.rb'

template do

  value :AWSTemplateFormatVersion => '2010-09-09'

  value :Description => 'AWS CloudFormation to deploy a front end website'

  parameter 'Environment',
            :Description => 'What environment to deploy the application into',
            :Type => 'String',
            :Default => 'development',
            :AllowedValues => %w(development production),
            :ConstraintDescription => 'must be a valid environment.'

  parameter 'Application',
            :Description => 'What application to deploy',
            :Type => 'String',
            :AllowedValues => %w(wordpress drupal),
            :Default => 'wordpress',
            :ConstraintDescription => 'Must be a valid CMS.'

  parameter 'Hostname',
            :Description => 'What Hostname should be used?',
            :Type => 'String',
            :Default => 'mytestsite.com'

  parameter 'DBRootPassword',
            :Description => 'What password to use for root user?',
            :Type => 'String',
            :MinLength => '10',
            :MaxLength => '20',
            :AllowedPattern => '[a-zA-Z0-9]*',
            :Default => '3wZqvWddoT3D339uFEQW'

  parameter 'DBCMSPassword',
            :Description => 'What password to use for cms user?',
            :Type => 'String',
            :MinLength => '10',
            :MaxLength => '20',
            :AllowedPattern => '[a-zA-Z0-9]*',
            :Default => 'Zrx46g7fyicdUf9Nh4mj'

  #TODO: figure out how to preload the parameters
  load_from_file('../../lib/autoloader.rb')

  parameter 'KeyName',
            :Description => 'Name of an existing EC2 KeyPair to enable SSH access to the instances',
            :Type => 'String',
            :MinLength => '1',
            :MaxLength => '64',
            :AllowedPattern => '[-_ a-zA-Z0-9]*',
            :Default => 'aboutte',
            :ConstraintDescription => 'can contain only alphanumeric characters, spaces, dashes and underscores.'

  parameter 'SSHLocation',
            :Description => 'Lockdown SSH access to the bastion host (default can be accessed from anywhere)',
            :Type => 'String',
            :MinLength => '9',
            :MaxLength => '18',
            :Default => "#{public_ip}/32",
            :AllowedPattern => '(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})',
            :ConstraintDescription => 'must be a valid CIDR range of the form x.x.x.x/x.'

  parameter 'FrontendInstanceType',
            :Description => 'Frontend Server EC2 instance type',
            :Type => 'String',
            :Default => 't2.small',
            :AllowedValues => %w(t1.micro t2.small m1.small m1.medium m1.large m1.xlarge m2.xlarge m2.2xlarge m2.4xlarge m3.xlarge m3.2xlarge c1.medium c1.xlarge cc2.8xlarge),
            :ConstraintDescription => 'must be a valid EC2 instance type.'

  parameter 'FrontendSize',
            :Description => 'Number of EC2 instances to launch for the Frontend server',
            :Type => 'Number',
            :Default => '1'

  parameter 'BastionInstanceType',
            :Description => 'Bastion Host EC2 instance type',
            :Type => 'String',
            :Default => 't2.small',
            :AllowedValues => %w(t1.micro t2.small m1.small m1.medium m1.large m1.xlarge m2.xlarge m2.2xlarge m2.4xlarge m3.xlarge m3.2xlarge c1.medium c1.xlarge cc2.8xlarge),
            :ConstraintDescription => 'must be a valid EC2 instance type.'

  tag :application, :Value => parameters['Application']
  tag :environment, :Value => parameters['Environment']
  tag :launched_by, :Value => ENV['USER']

  resource 'VPC', :Type => 'AWS::EC2::VPC', :Properties => {
      :CidrBlock => get_cidr('vpc'),
  }

  resource 'PublicSubnet', :Type => 'AWS::EC2::Subnet', :Properties => {
      :VpcId => ref('VPC'),
      :CidrBlock => get_cidr('public'),
      :Tags => [
          { :Key => 'Name', :Value => 'public' },
      ],
  }

  resource 'InternetGateway', :Type => 'AWS::EC2::InternetGateway', :Properties => {
      :Tags => [
          { :Key => 'Name', :Value => 'public' },
      ],
  }

  resource 'GatewayToInternet', :Type => 'AWS::EC2::VPCGatewayAttachment', :Properties => {
      :VpcId => ref('VPC'),
      :InternetGatewayId => ref('InternetGateway'),
  }

  resource 'PublicRouteTable', :Type => 'AWS::EC2::RouteTable', :Properties => {
      :VpcId => ref('VPC'),
      :Tags => [
          { :Key => 'Name', :Value => 'public' },
      ],
  }

  resource 'PublicRoute', :Type => 'AWS::EC2::Route', :DependsOn => 'GatewayToInternet', :Properties => {
      :RouteTableId => ref('PublicRouteTable'),
      :DestinationCidrBlock => '0.0.0.0/0',
      :GatewayId => ref('InternetGateway'),
  }

  resource 'PublicSubnetRouteTableAssociation', :Type => 'AWS::EC2::SubnetRouteTableAssociation', :Properties => {
      :SubnetId => ref('PublicSubnet'),
      :RouteTableId => ref('PublicRouteTable'),
  }

  resource 'PublicNetworkAcl', :Type => 'AWS::EC2::NetworkAcl', :Properties => {
      :VpcId => ref('VPC'),
      :Tags => [
          { :Key => 'Name', :Value => 'public' }
      ],
  }

  resource 'InboundHTTPPublicNetworkAclEntry', :Type => 'AWS::EC2::NetworkAclEntry', :Properties => {
      :NetworkAclId => ref('PublicNetworkAcl'),
      :RuleNumber => '100',
      :Protocol => '6',
      :RuleAction => 'allow',
      :Egress => 'false',
      :CidrBlock => '0.0.0.0/0',
      :PortRange => { :From => '80', :To => '80' },
  }

  resource 'InboundHTTPSPublicNetworkAclEntry', :Type => 'AWS::EC2::NetworkAclEntry', :Properties => {
      :NetworkAclId => ref('PublicNetworkAcl'),
      :RuleNumber => '101',
      :Protocol => '6',
      :RuleAction => 'allow',
      :Egress => 'false',
      :CidrBlock => '0.0.0.0/0',
      :PortRange => { :From => '443', :To => '443' },
  }

  resource 'InboundSSHPublicNetworkAclEntry', :Type => 'AWS::EC2::NetworkAclEntry', :Properties => {
      :NetworkAclId => ref('PublicNetworkAcl'),
      :RuleNumber => '102',
      :Protocol => '6',
      :RuleAction => 'allow',
      :Egress => 'false',
      :CidrBlock => ref('SSHLocation'),
      :PortRange => { :From => '22', :To => '22' },
  }

  resource 'InboundEmphemeralPublicNetworkAclEntry', :Type => 'AWS::EC2::NetworkAclEntry', :Properties => {
      :NetworkAclId => ref('PublicNetworkAcl'),
      :RuleNumber => '103',
      :Protocol => '6',
      :RuleAction => 'allow',
      :Egress => 'false',
      :CidrBlock => '0.0.0.0/0',
      :PortRange => { :From => '1024', :To => '65535' },
  }

  resource 'OutboundPublicNetworkAclEntry', :Type => 'AWS::EC2::NetworkAclEntry', :Properties => {
      :NetworkAclId => ref('PublicNetworkAcl'),
      :RuleNumber => '100',
      :Protocol => '6',
      :RuleAction => 'allow',
      :Egress => 'true',
      :CidrBlock => '0.0.0.0/0',
      :PortRange => { :From => '0', :To => '65535' },
  }

  resource 'PublicSubnetNetworkAclAssociation', :Type => 'AWS::EC2::SubnetNetworkAclAssociation', :Properties => {
      :SubnetId => ref('PublicSubnet'),
      :NetworkAclId => ref('PublicNetworkAcl'),
  }

  resource 'PrivateSubnet', :Type => 'AWS::EC2::Subnet', :Properties => {
      :VpcId => ref('VPC'),
      :CidrBlock => get_cidr('private'),
      :Tags => [
          { :Key => 'Name', :Value => 'private' }
      ],
  }

  resource 'PrivateRouteTable', :Type => 'AWS::EC2::RouteTable', :Properties => {
      :VpcId => ref('VPC'),
      :Tags => [
          { :Key => 'Name', :Value => 'private' }
      ],
  }

  resource 'PrivateSubnetRouteTableAssociation', :Type => 'AWS::EC2::SubnetRouteTableAssociation', :Properties => {
      :SubnetId => ref('PrivateSubnet'),
      :RouteTableId => ref('PrivateRouteTable'),
  }

  resource 'PrivateRoute', :Type => 'AWS::EC2::Route', :Properties => {
      :RouteTableId => ref('PrivateRouteTable'),
      :DestinationCidrBlock => '0.0.0.0/0',
      :NatGatewayId => ref('NATDevice'),
  }

  resource 'PrivateNetworkAcl', :Type => 'AWS::EC2::NetworkAcl', :Properties => {
      :VpcId => ref('VPC'),
      :Tags => [
          { :Key => 'Name', :Value => 'private' }
      ],
  }

  resource 'InboundPrivateNetworkAclEntry', :Type => 'AWS::EC2::NetworkAclEntry', :Properties => {
      :NetworkAclId => ref('PrivateNetworkAcl'),
      :RuleNumber => '100',
      :Protocol => '6',
      :RuleAction => 'allow',
      :Egress => 'false',
      :CidrBlock => '0.0.0.0/0',
      :PortRange => { :From => '0', :To => '65535' },
  }

  resource 'OutBoundPrivateNetworkAclEntry', :Type => 'AWS::EC2::NetworkAclEntry', :Properties => {
      :NetworkAclId => ref('PrivateNetworkAcl'),
      :RuleNumber => '100',
      :Protocol => '6',
      :RuleAction => 'allow',
      :Egress => 'true',
      :CidrBlock => '0.0.0.0/0',
      :PortRange => { :From => '0', :To => '65535' },
  }

  resource 'PrivateSubnetNetworkAclAssociation', :Type => 'AWS::EC2::SubnetNetworkAclAssociation', :Properties => {
      :SubnetId => ref('PrivateSubnet'),
      :NetworkAclId => ref('PrivateNetworkAcl'),
  }

  resource 'NATIPAddress', :Type => 'AWS::EC2::EIP', :Properties => {
      :Domain => 'vpc'
  }

  resource 'NATDevice', :Type => 'AWS::EC2::NatGateway', :Properties => {
      :AllocationId => get_att('NATIPAddress', 'AllocationId'),
      :SubnetId => ref('PublicSubnet')
  }

  resource 'BastionIPAddress', :Type => 'AWS::EC2::EIP', :Properties => {
      :Domain => 'vpc',
      :InstanceId => ref('BastionHost'),
  }

  resource 'BastionHost', :Type => 'AWS::EC2::Instance', :Properties => {
      :InstanceType => ref('BastionInstanceType'),
      :KeyName => ref('KeyName'),
      :SubnetId => ref('PublicSubnet'),
      :ImageId => amazon_linux_ami_id,
      :SecurityGroupIds => [ ref('BastionSecurityGroup') ],
      :Tags => [
          { :Key => 'Name', :Value => 'BastionHost' }
      ],
  }

  resource 'BastionSecurityGroup', :Type => 'AWS::EC2::SecurityGroup', :Properties => {
      :GroupDescription => 'Enable access to the Bastion host',
      :VpcId => ref('VPC'),
      :SecurityGroupIngress => [
          { :IpProtocol => 'tcp', :FromPort => '22', :ToPort => '22', :CidrIp => ref('SSHLocation'), },
      ],
      :SecurityGroupEgress => [
          { :IpProtocol => 'tcp', :FromPort => '22', :ToPort => '22', :CidrIp => get_cidr('private'), },
          { :IpProtocol => 'tcp', :FromPort => '80', :ToPort => '80', :CidrIp => '0.0.0.0/0' },
          { :IpProtocol => 'tcp', :FromPort => '443', :ToPort => '443',  :CidrIp => '0.0.0.0/0' }
      ],
  }

  resource 'PublicElasticLoadBalancer', :Type => 'AWS::ElasticLoadBalancing::LoadBalancer', :Properties => {
      :SecurityGroups => [ ref('PublicLoadBalancerSecurityGroup') ],
      :Subnets => [ ref('PublicSubnet') ],
      :Listeners => [
          { :LoadBalancerPort => '80', :InstancePort => '80', :Protocol => 'HTTP' },
      ],
      :HealthCheck => { :Target => 'HTTP:80/', :HealthyThreshold => '3', :UnhealthyThreshold => '5', :Interval => '90', :Timeout => '60' },
  }

  resource 'PublicLoadBalancerSecurityGroup', :Type => 'AWS::EC2::SecurityGroup', :Properties => {
      :GroupDescription => 'Public ELB Security Group with HTTP access on port 80 from the internet',
      :VpcId => ref('VPC'),
      :SecurityGroupIngress => [
          { :IpProtocol => 'tcp', :FromPort => '80', :ToPort => '80', :CidrIp => '0.0.0.0/0' },
      ],
      :SecurityGroupEgress => [
          { :IpProtocol => 'tcp', :FromPort => '80', :ToPort => '80', :CidrIp => '0.0.0.0/0' },
      ],
  }

  resource 'FrontendFleet', :Type => 'AWS::AutoScaling::AutoScalingGroup', :Properties => {
      :AvailabilityZones => [ get_att('PrivateSubnet', 'AvailabilityZone') ],
      :VPCZoneIdentifier => [ ref('PrivateSubnet') ],
      :LaunchConfigurationName => ref('FrontendServerLaunchConfig'),
      :MinSize => '1',
      :MaxSize => '3',
      :DesiredCapacity => ref('FrontendSize'),
      :LoadBalancerNames => [ ref('PublicElasticLoadBalancer') ],
  }

  resource 'FrontendServerLaunchConfig', :Type => 'AWS::AutoScaling::LaunchConfiguration', :Properties => {
      :ImageId => amazon_linux_ami_id,
      :SecurityGroups => [ ref('FrontendSecurityGroup') ],
      :InstanceType => ref('FrontendInstanceType'),
      :KeyName => ref('KeyName'),
      :UserData => base64(interpolate(assemble_userdata)),
  }

  resource 'FrontendSecurityGroup', :Type => 'AWS::EC2::SecurityGroup', :Properties => {
      :GroupDescription => 'Allow access from load balancer and bastion as well as outbound HTTP and HTTPS traffic',
      :VpcId => ref('VPC'),
      :SecurityGroupIngress => [
          {
              :IpProtocol => 'tcp',
              :FromPort => '80',
              :ToPort => '80',
              :SourceSecurityGroupId => ref('PublicLoadBalancerSecurityGroup'),
          },
          {
              :IpProtocol => 'tcp',
              :FromPort => '22',
              :ToPort => '22',
              :SourceSecurityGroupId => ref('BastionSecurityGroup'),
          },
      ],
      :SecurityGroupEgress => [
          { :IpProtocol => 'tcp', :FromPort => '80', :ToPort => '80', :CidrIp => '0.0.0.0/0' },
          { :IpProtocol => 'tcp', :FromPort => '443', :ToPort => '443', :CidrIp => '0.0.0.0/0' },
      ],
  }

  resource 'FrontendWaitHandle', :Type => 'AWS::CloudFormation::WaitConditionHandle'

  resource 'FrontendWaitCondition', :Type => 'AWS::CloudFormation::WaitCondition', :DependsOn => 'FrontendFleet', :Properties => {
      :Handle => ref('FrontendWaitHandle'),
      :Timeout => '300',
      :Count => ref('FrontendSize'),
  }

  resource 'PrivateLoadBalancerSecurityGroup', :Type => 'AWS::EC2::SecurityGroup', :Properties => {
      :GroupDescription => 'Private ELB Security Group with HTTP access on port 80 from the Frontend Fleet only',
      :VpcId => ref('VPC'),
      :SecurityGroupIngress => [
          {
              :IpProtocol => 'tcp',
              :FromPort => '80',
              :ToPort => '80',
              :SourceSecurityGroupId => ref('FrontendSecurityGroup'),
          },
      ],
      :SecurityGroupEgress => [
          { :IpProtocol => 'tcp', :FromPort => '80', :ToPort => '80', :CidrIp => '0.0.0.0/0' },
      ],
  }

  output 'WebSite',
         :Description => 'URL of the website',
         :Value => join('', 'http://', get_att('PublicElasticLoadBalancer', 'DNSName'))

  output 'Bastion',
         :Description => 'IP Address of the Bastion host',
         :Value => ref('BastionIPAddress')

end.exec!
