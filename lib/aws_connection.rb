require 'json'
require 'aws-sdk'
require 'pp'

# This class initialize aws client
class AwsConnection
  def initialize
    @conf = ConfigApp.new

    @region = @conf.params['aws']['region']
    init_credentials(@conf.params['aws']['access'], @conf.params['aws']['secret'])
    @accounts = @conf.params['aws']['accounts']
  end

  def init_credentials(access, secret)
    @credentials = Aws::Credentials.new(access, secret)
  end
end
