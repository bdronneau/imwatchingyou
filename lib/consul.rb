# https://github.com/rest-client/rest-client
require 'rest-client'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'

# Get informations from consul agent API
class ConsulInfo
  def initialize
    @conf = ConfigApp.new
  end

  def all_critical # rubocop:disable Metrics/MethodLength
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
    name_to_check = "#{server.last['protocol']}
                     #{server.last['name']}:
                     #{server.last['port']}"

    response = JSON.parse(
      RestClient.get "#{name_to_check}/v1/health/state/critical"
    )

    errors.push(response) if response.any?

    errors
  end
end
