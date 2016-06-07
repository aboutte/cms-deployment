
# return the public IP of the workstation using the CloudFormation DSL
def public_ip
  open('http://whatismyip.akamai.com').read
end
