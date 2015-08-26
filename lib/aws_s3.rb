require 'json'
require 'aws-sdk'
require 'pp'
require './lib/aws_connection.rb'

# This class get informations of AWS S3 with SDK v2
class AwsS3
  def list_s3
    s3 = Aws::S3::Client.new(region: @region, credentials: @credentials)
    s3.list_buckets
  end

  def number_bucket_s3
    s3 = Aws::S3::Client.new(region: @region, credentials: @credentials)
    s3.list_buckets.buckets.length
  end
end
