resource 'S3Access', Type: 'AWS::IAM::Policy', Properties: {
  PolicyName: 'S3Access',
  PolicyDocument: {
    Statement: [
      {
        Effect: 'Allow',
        Action: [
          's3:Get*',
          's3:List*'
        ],
        Resource: 'arn:aws:s3:::rean-us-west-2-aboutte/application/environment/*'
      }
    ]
  },
  Roles: [ref('IAMRole')]
}
