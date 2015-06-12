# https://github.com/rest-client/rest-client
require 'rest-client'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'

class ConsulInfo
  def initialize
    @conf = ConfigApp.new()
  end

  def getAllCritical
    errors = Array.new
    commonFunction = Common.new()
    @conf.params['consul']['servers'].each do |server|
      if commonFunction.checkPortIsOpen?(server.last['name'], server.last['port'], 3)
        nameToCheck = "#{server.last['protocol']}#{server.last['name']}:#{server.last['port']}"
        response = JSON.parse(RestClient.get "#{nameToCheck}/v1/health/state/critical")
        if response.any?
          errors.push(response)
        end
      else
        errors.push([{"Node"=>"#{server.first}", "CheckID"=>"Unreachable Agent"}])
      end
    end
    errors
  end
end
