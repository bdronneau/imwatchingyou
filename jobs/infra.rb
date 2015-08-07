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

# Init variables
ga_user = 0
github_pr = 0
github_repos = 0
github_token = 0

#Init count down
config = ConfigApp.new
#We assume countdown hash in config is present
if config.params['countdown'].include? 'ie'
  if config.params['countdown']['ie']['enable']
    send_event(
      'countdownie3',
      title: 'IE3 is ours in',
      end: config.params['countdown']['ie']['date']
    )
  else
    send_event(
      'countdownie3',
      title: 'Countdown IE3 disable',
      end: ''
    )
  end
else
  send_event(
    'countdownie3',
    title: 'Countdown IE3 have no parameters',
    end: ''
  )
end

# Scheduler for consul Alert
SCHEDULER.every config.params['scheduler']['consul'] do
  logger.info('Start Scheduler Consul')

  consul_info = ConsulInfo.new(logger)

  array_alert = consul_info.all_critical
  array_alert.concat consul_info.all_warnings
  status = 0

  if array_alert.any?
    array_alert_display = []
    array_alert.each do |alerts|
      alerts.each do |alert|
        host_alert =  alert['Node']
        check_alert = alert['CheckID']
        type_alert = alert['Status']
        array_alert_display.push(
          label: host_alert,
          value: "[#{type_alert}] #{check_alert}"
        )

        case type_alert
        when 'warning'
          status = 1 unless status.eql? 2
        when 'critical'
          status = 2
        else
          status = 0
        end
      end
    end
    logger.info(array_alert_display)
    send_event(
      'alerts',
      title: 'Alarms',
      items: array_alert_display,
      status: status
    )
  else
    send_event(
      'alerts',
      title: 'Keep calm there is no alerts',
      items: [],
      status: status
    )
  end

  logger.info('End Scheduler Consul')
end

# Scheduler for AWS Informations
SCHEDULER.every config.params['scheduler']['aws'] do
  logger.info('Start Scheduler AWS')

  aws_info = AwsInfo.new

  send_event(
    'ec2number',
    value: aws_info.number_ec2,
    max: aws_info.ec2_limit
  )

  send_event(
    'rdsnumber',
    value: aws_info.number_rds,
    max: aws_info.rds_limit
  )

  send_event(
      'elbnumber',
      value: aws_info.number_elb,
      max: '20'
  )

  logger.info('End Scheduler AWS')
end

# Scheduler for UptimeRobot graph
SCHEDULER.every config.params['scheduler']['uptimerobot'] do
  logger.info('Start Scheduler UptimeRobot')

  uptimerobot = UptimeRobot.new

  monitor = uptimerobot.random_monitor

  send_event(
    'uptimerobot',
    points: monitor[0],
    title: monitor[1] + ' (ms)'
  )

  logger.info('End Scheduler UptimeRobot')
end

# Scheduler for Google Analytics
SCHEDULER.every config.params['scheduler']['ga'] do
  logger.info('Start Scheduler Google Analytics')

  ga = GoogleAnalytics.new

  previous_ga_user = ga_user
  ga_user = ga.realtime_users

  send_event(
    'gausersrealtime',
    current: ga_user,
    last: previous_ga_user
  )
  logger.info('End Scheduler Google Analytics')
end

# Scheduler for github
SCHEDULER.every config.params['scheduler']['github'], :first_at => Time.now  do
  logger.info('Start Scheduler Github')

  github = GithubInfo.new

  previous_github_repos = github_repos
  github_repos = github.list_orgas_repos.length

  previous_github_pr = github_pr
  github_pr = github.list_orgas_pr.length

  previous_github_token = github_token
  github_token = github.token_left

  send_event(
      'githubtoken',
      current: github_token,
      last: previous_github_token
  )

  send_event(
      'githubpr',
      current: previous_github_pr,
      last: github_pr
  )

  send_event(
      'githubrepos',
      current: github_repos,
      last: previous_github_repos
  )

  logger.info('End Scheduler Github')
end