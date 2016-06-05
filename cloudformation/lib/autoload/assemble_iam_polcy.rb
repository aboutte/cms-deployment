
# resource 'IAMRole', Type: 'AWS::IAM::Role', Properties: {
#   AssumeRolePolicyDocument: {
#     Version: '2012-10-17',
#     Statement: [
#       {
#         Effect: 'Allow',
#         Principal: { Service: ['ec2.amazonaws.com'] },
#         Action: ['sts:AssumeRole']
#       }
#     ]
#   },
#   Path: '/'
# }
#
# resource 'IAMInstanceProfile', Type: 'AWS::IAM::InstanceProfile', Properties: {
#   Path: '/',
#   Roles: [ref('IAMRole')]
# }

Dir["#{File.dirname(File.expand_path($PROGRAM_NAME))}/iam_policies/*.rb"].each { |file| load_from_file(file) }
