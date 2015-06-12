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
    number_bucket = 0
    s3.list_buckets.buckets.each do
      number_bucket += 1
    end

    number_bucket
  end

  def number_ec2
    ec2 = Aws::EC2::Client.new(region: @region, credentials: @credentials)
    list_ec2 = ec2.describe_instances
    number_ec2 = 0
    list_ec2.reservations.each do |reservation|
      reservation.instances.each do
        number_ec2 += 1
      end
    end
    number_ec2
  end

  def number_ec2_by_stage(stage) # rubocop:disable Metrics/MethodLength
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
      reservation.instances.each do
        number_ec2 += 1
      end
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
    max_ec2
  end
end
