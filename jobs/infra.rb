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
aws_bill = 0

# Init github object for enble octokit caching
github = GithubInfo.new

#Init count down
config = ConfigApp.new
#We assume countdown hash in config is present
if config.params['countdown'].include? 'ws'
  if config.params['countdown']['ws']['enable']
    send_event(
      'countdownws',
      title: 'WS is ours in',
      end: config.params['countdown']['ws']['date']
    )
  else
    send_event(
      'countdownws',
      title: 'Countdown WS disable',
      end: ''
    )
  end
else
  send_event(
    'countdownws',
    title: 'Countdown WS have no parameters',
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
      status: status,
      image: "/assets/alarm.gif"
    )
  else
    gif = GifMe.new
    send_event(
      'alerts',
      title: gif.lesjoiesdusysadmin[0],
      items: [],
      status: status,
      image: gif.lesjoiesdusysadmin[1]
    )
  end

  logger.info('End Scheduler Consul')
end

# Scheduler for AWS Informations
SCHEDULER.every config.params['scheduler']['aws'], :first_at => Time.now  do
  logger.info('Start Scheduler AWS')

  cw = AwsCloudwatch.new
  aws_billing = cw.current_max_billing_value
  previous_aws_bill = aws_bill
  aws_bill = aws_billing[1]

  ec2 = AwsEc2.new
  rds = AwsRds.new

  logger.debug("AWS :
    Billing -> update at #{aws_billing[0]}, value : #{aws_billing[1]}
    RDS -> instances : #{rds.number_rds} / #{rds.rds_limit}
    Ec2 -> instances : #{ec2.number_ec2} / #{ec2.ec2_limit}, elb : #{ec2.number_elb} / 20
  ")

  send_event(
    'ec2number',
    value: ec2.number_ec2,
    max: ec2.ec2_limit
  )

  send_event(
    'rdsnumber',
    value: rds.number_rds,
    max: rds.rds_limit
  )

  send_event(
      'elbnumber',
      value: ec2.number_elb,
      max: '20'
  )

  send_event(
    'billaws',
    title: 'Facture AWS (estimation)',
    moreinfo: "#{aws_billing[0]}",
    current: aws_billing[1],
    last: previous_aws_bill
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

  previous_github_repos = github_repos
  github_repos_list = github.list_orgas_repos
  github_repos = github_repos_list.length

  logger.debug("Github : Number Repos : #{github_repos}")

  previous_github_pr = github_pr
  github_pr = (github.list_pr github_repos_list).length

  logger.debug("Github : Number PR : #{github_pr}")

  previous_github_token = github_token
  github_token = github.token_left

  logger.debug("Github : Number Token : #{github_token}")

  send_event(
      'githubtoken',
      current: github_token,
      last: previous_github_token
  )

  send_event(
      'githubpr',
      current: github_pr,
      last: previous_github_pr
  )

  send_event(
      'githubrepos',
      current: github_repos,
      last: previous_github_repos
  )

  logger.info('End Scheduler Github')
end
