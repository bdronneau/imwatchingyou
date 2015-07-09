require 'json'
require 'aws-sdk'
require 'pp'

# This class get info from AWS with SDK v2
class AwsInfo
  def initialize
    @conf = ConfigApp.new

    @region = @conf.params['aws']['region']
    access = @conf.params['aws']['access']
    secret = @conf.params['aws']['secret']
    @credentials = Aws::Credentials.new(access, secret)
  end

  def list_s3
    s3 = Aws::S3::Client.new(region: @region, credentials: @credentials)
    s3.list_buckets
  end

  def number_bucket_s3
    s3 = Aws::S3::Client.new(region: @region, credentials: @credentials)
    s3.list_buckets.buckets.length
  end

  def number_ec2
    ec2 = Aws::EC2::Client.new(region: @region, credentials: @credentials)
    list_ec2 = ec2.describe_instances
    number_ec2 = 0
    list_ec2.reservations.each do |reservation|
      number_ec2 += reservation.instances.length
    end
    number_ec2
  end

  def number_ec2_by_stage(stage)
    ec2 = Aws::EC2::Client.new(region: @region, credentials: @credentials)
    list_ec2 = ec2.describe_instances(
      filters: [
        {
          name: 'tag-value',
          values: [stage]

        }
      ]
    )

    number_ec2 = 0
    list_ec2.reservations.each do |reservation|
      number_ec2 += reservation.instances.length
    end
    number_ec2
  end

  def ec2_limit
    ec2 = Aws::EC2::Client.new(region: @region, credentials: @credentials)
    max_ec2 = ''
    resp = ec2.describe_account_attributes(
      attribute_names: ['max-instances']
    )
    resp.account_attributes.each do |element|
      max_ec2 = element.attribute_values.each.next.attribute_value
    end
    max_ec2.to_i
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

  def number_elb
    elb = Aws::ElasticLoadBalancing::Client.new(region: @region, credentials: @credentials)
    elb.describe_load_balancers.load_balancer_descriptions.length
  end
end
