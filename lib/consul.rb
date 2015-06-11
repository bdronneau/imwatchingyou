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
    @conf.params['consul']['servers'].each do |server|
      response = JSON.parse(RestClient.get "#{server}/v1/health/state/critical")
      if response.any?
        errors.push(response)
      end
    end
    errors
  end
end
