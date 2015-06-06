require 'json'
require 'aws-sdk'
require 'pp'

class AwsInfo
  def initialize
    @conf = ConfigApp.new()

    @region = @conf.params['aws']['region']
    access = @conf.params['aws']['access']
    secret = @conf.params['aws']['secret']
    @credentials = Aws::Credentials.new(access, secret)
  end

  def listS3
    s3 = Aws::S3::Client.new(region: @region, credentials: @credentials)
    s3.list_buckets
  end

  def getNumberBucketS3
    s3 = Aws::S3::Client.new(region: @region, credentials: @credentials)
    listBucket = s3.list_buckets
    numberBucket = 0
    listBucket.buckets.each do |object|
        numberBucket = numberBucket + 1
    end

    numberBucket
  end

  def getNumberEc2
    ec2 = Aws::EC2::Client.new(region: @region, credentials: @credentials)
    listEc2 = ec2.describe_instances
    numberEc2 = 0
    listEc2.reservations.each do |reservation|
      reservation.instances.each do |ec2Instance|
        numberEc2 = numberEc2 + 1
      end
    end
    numberEc2
  end

  def getNumBerEc2byStage(stage)
    ec2 = Aws::EC2::Client.new(region: @region, credentials: @credentials)
    listEc2 = ec2.describe_instances(
        filters: [{
                      name: "tag-value",
                      values: [stage]
                  }]
    )

    numberEc2 = 0
    listEc2.reservations.each do |reservation|
      reservation.instances.each do |ec2Instance|
        numberEc2 = numberEc2 + 1
      end
    end
    numberEc2
  end

  def getEc2Limit
    ec2 = Aws::EC2::Client.new(region: @region, credentials: @credentials)
    maxEc2 = ''
    resp = ec2.describe_account_attributes(
        attribute_names: ["max-instances"],
    )
    resp.account_attributes.each do |element|
      maxEc2 = element.attribute_values.each.next.attribute_value
    end
    maxEc2
  end
end