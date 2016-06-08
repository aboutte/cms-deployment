
AWS_CLIENTS = {}

AWS_CLIENTS[:ec2] = Aws::EC2::Client.new(
  region: aws_region
)

def amazon_linux_ami_id
  amazon_linux_amis = AWS_CLIENTS[:ec2].describe_images(owners: ['amazon'],
                                                        filters: [
                                                          {
                                                            name: 'architecture',
                                                            values: ['x86_64']
                                                          },
                                                          {
                                                            name: 'state',
                                                            values: ['available']
                                                          },
                                                          {
                                                            name: 'virtualization-type',
                                                            values: ['hvm']
                                                          },
                                                          {
                                                            name: 'description',
                                                            values: ['Amazon Linux AMI*']
                                                          },
                                                          {
                                                            name: 'name',
                                                            values: ['amzn-ami-hvm-*']
                                                          }
                                                        ])

  # The results of describe_images is an array of all Amazon Linux AMIs
  # To find the latest sort by the object attribute creation_date
  amazon_linux_amis.images.sort_by!(&:creation_date)
  amazon_linux_amis.images.last.image_id
end

# Passing in a subnet (public or private) will return the subnet cidr based on region and environment
def get_cidr(subnet)
  case aws_region
  when 'us-west-2'
    case parameters['Environment']
    when 'development'
      case subnet
      when 'vpc'
        '10.0.0.0/16'
      when 'public'
        '10.0.0.0/24'
      when 'private'
        '10.0.1.0/24'
      end
    when 'production'
      case subnet
      when 'vpc'
        '10.1.0.0/16'
      when 'public'
        '10.1.0.0/24'
      when 'private'
        '10.1.1.0/24'
      end
    end
  when 'us-east-1'
    case parameters['Environment']
    when 'development'
      case subnet
      when 'vpc'
        '10.2.0.0/16'
      when 'public'
        '10.2.0.0/24'
      when 'private'
        '10.2.1.0/24'
      end
    when 'production'
      case subnet
      when 'vpc'
        '10.3.0.0/16'
      when 'public'
        '10.3.0.0/24'
      when 'private'
        '10.3.1.0/24'
      end
    end
  end
end
