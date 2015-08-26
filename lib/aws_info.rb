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
    @accounts = @conf.params['aws']['accounts']
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

  def list_cloudwatch_metric
    cloudwatch = Aws::CloudWatch::Client.new(region: "us-east-1", credentials: @credentials)
    cloudwatch.list_metrics()
  end

  def current_max_billing_value
    cloudwatch = Aws::CloudWatch::Client.new(region: "us-east-1", credentials: @credentials)

    bill_value = 0

    @accounts.each do |account|
      bill_value = cloudwatch.get_metric_statistics(
        {
          namespace: "AWS/Billing", # required
          metric_name: "EstimatedCharges", # required
          dimensions:
            [
              {
                name: "Currency", # required
                value: "USD", # required
              },
              {
                name: "LinkedAccount",
                value: account.to_s
              }
            ],
          start_time: Time.now - 86400, # required, we get on one day
          end_time: Time.now, # required
          period: 84600, # required
          statistics: ["Maximum"], # required, accepts SampleCount, Average, Sum, Minimum, Maximum
        }
      )
    end

    result = []

    if !bill_value.datapoints.any?
      result.push('No date')
      result.push('-1')
    else
      result.push(bill_value.datapoints[0].timestamp)
      result.push(bill_value.datapoints[0].maximum)
    end
    result
  end
end
