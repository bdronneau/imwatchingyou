require 'pp'

SCHEDULER.every '5s' do
  pp "Start Scheduler Consul"

  awsInfo = AwsInfo.new()

  allS3 = awsInfo.listS3

  numberS3 = awsInfo.getNumberBucketS3

  consulInfo = ConsulInfo.new()

  arrayCritical = consulInfo.getAllCritical

  if arrayCritical.any?
    arrayAlertDisplay = []
    arrayCritical.each do |alerts|
      alerts.each do |alert|
        hostAlert =  alert['Node']
        checkAlert = alert['CheckID']
        arrayAlertDisplay.push({ label: hostAlert, value: checkAlert })
      end
    end
    pp arrayAlertDisplay
    send_event('alerts', {title: 'Alarms', items: arrayAlertDisplay, status: 2})
  else
    send_event('alerts', {title: 'Keep calm there is no alerts', items: [{label: '', value: ''}], status: 0})
  end

  send_event('ec2number', { value: awsInfo.getNumberEc2, max: awsInfo.getEc2Limit })

  pp "End Scheduler Consul"
end
