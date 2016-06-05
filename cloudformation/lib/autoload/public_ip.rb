
# return the public IP of the workstation using the CloudFormation DSL
def public_ip
  require 'open-uri'
  open('http://whatismyip.akamai.com').read
end
