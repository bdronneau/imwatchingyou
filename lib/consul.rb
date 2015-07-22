# https://github.com/rest-client/rest-client
require 'rest-client'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'
require 'logger'

# Get informations from consul agent API
class ConsulInfo
  def initialize(logger)
    @conf = ConfigApp.new
    @logger = logger
  end

  def all_critical
    errors = []
    common_function = Common.new
    @conf.params['consul']['servers'].each do |server|
      if common_function.check_port_is_open?(
        server.last['name'],
        server.last['port'],
        3
      )
        errors = alarms(server, errors)
      else
        errors = agent_unreachable(server.first, errors)
      end
    end
    errors
  end

  def all_warnings
    warns = []
    common_function = Common.new
    @conf.params['consul']['servers'].each do |server|
      if common_function.check_port_is_open?(
          server.last['name'],
          server.last['port'],
          3
      )
        warns = warnings(server, warns)
      else
        @logger.error('No response of agent for warning check')
      end
    end
    warns
  end

  def agent_unreachable(server_name, errors)
    no_data_from_agent = [
      {
        'Node' => "#{server_name}",
        'CheckID' => 'Unreachable Agent'
      }
    ]
    errors.push(no_data_from_agent)
    errors
  end

  def alarms(server, errors)
    name_to_check = "#{server.last['protocol']}#{server.last['name']}:#{server.last['port']}"

    response = JSON.parse(
      RestClient.get "#{name_to_check}/v1/health/state/critical"
    )

    errors.push(response) if response.any?

    errors
  end

  def warnings(server, warns)
    name_to_check = "#{server.last['protocol']}#{server.last['name']}:#{server.last['port']}"

    response = JSON.parse(
        RestClient.get "#{name_to_check}/v1/health/state/warning"
    )

    warns.push(response) if response.any?

    warns
  end
end
