require 'pp'
require 'logger'

logger = Logger.new(STDOUT)
case ConfigApp.new.params['log']['level']
when 'fatal'
  logger.level = Logger::FATAL
when 'error'
  logger.level = Logger::ERROR
when 'warning'
  logger.level = Logger::WARN
when 'info'
  logger.level = Logger::INFO
when 'debug'
  logger.level = Logger::DEBUG
end

# Scheduler for consul Alert
SCHEDULER.every '5s' do
  logger.info('Start Scheduler Consul')

  consul_info = ConsulInfo.new

  array_critical = consul_info.all_critical

  if array_critical.any?
    array_alert_display = []
    array_critical.each do |alerts|
      alerts.each do |alert|
        host_alert =  alert['Node']
        check_alert = alert['CheckID']
        array_alert_display.push(
          label: host_alert,
          value: check_alert
        )
      end
    end
    logger.info(array_alert_display)
    send_event(
      'alerts',
      title: 'Alarms',
      items: array_alert_display,
      status: 2
    )
  else
    send_event(
      'alerts',
      title: 'Keep calm there is no alerts',
      items: [],
      status: 0
    )
  end

  logger.info('End Scheduler Consul')
end

# Scheduler for AWS Informations
SCHEDULER.every '1m' do
  logger.info('Start Scheduler AWS')

  aws_info = AwsInfo.new

  send_event(
    'ec2number',
    value: aws_info.number_ec2,
    max: aws_info.ec2_limit
  )

  logger.info('End Scheduler AWS')
end

# Scheduler for UptimeRobot graph
SCHEDULER.every '10s' do
  logger.info('Start Scheduler UptimeRobot')

  uptimerobot = UptimeRobot.new

  monitor = uptimerobot.random_monitor

  send_event(
    'uptimerobot',
    points: monitor[0],
    title: monitor[1]
  )

  logger.info('End Scheduler UptimeRobot')
end
