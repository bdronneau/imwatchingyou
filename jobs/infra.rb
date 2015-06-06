current_valuation = 0
current_karma = 0

SCHEDULER.every '5s' do
  last_valuation = current_valuation
  last_karma     = current_karma
  current_valuation = rand(100)
  current_karma     = rand(200000)

  awsInfo = AwsInfo.new()

  allS3 = awsInfo.listS3

  numberS3 = awsInfo.getNumberBucketS3


  send_event('welcome', {text: allS3 })

  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('ec2number',   { value: awsInfo.getNumberEc2, max: awsInfo.getEc2Limit })
end