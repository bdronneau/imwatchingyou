require 'json'
require 'aws-sdk'
require 'pp'
require './lib/aws_connection.rb'

# This class get informations of AWS RDS with SDK v2
class AwsRds < AwsConnection
  def initialize
    super
  end

  def number_rds
    rds = Aws::RDS::Client.new(region: @region, credentials: @credentials)
    rds.describe_db_instances.db_instances.length
  end

  def rds_limit
    rds = Aws::RDS::Client.new(region: @region, credentials: @credentials)
    limit = 0
    resp = rds.describe_account_attributes
    resp['account_quotas'].each do |value|
      limit = value['max'] if value['account_quota_name'].eql? 'DBInstances'
    end
    limit
  end
end
