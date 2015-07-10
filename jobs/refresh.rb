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

# Scheduler for refresh dashboard
SCHEDULER.every '3h' do
  logger.info('Start Scheduler refresh dashboards')
  send_event(
      'refresh_infra',
      {
          event: 'reload',
          dashboard: 'infra'
      },
      'dashboards'
  )

  send_event(
      'refresh_infratv',
      {
          event: 'reload',
          dashboard: 'infratv'
      },
      'dashboards'
  )
  logger.info('Start Scheduler refresh dashboards')
end
