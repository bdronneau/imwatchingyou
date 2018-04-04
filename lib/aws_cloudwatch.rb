require 'json'
require 'aws-sdk'
require 'pp'
require './lib/aws_connection.rb'

# This class get informations of AWS Cloudwatch with SDK v2
class AwsCloudwatch < AwsConnection
  def initialize
    super
  end

  def list_cloudwatch_metric(select_region = @region)
    cloudwatch = Aws::CloudWatch::Client.new(region: select_region, credentials: @credentials)
    cloudwatch.list_metrics()
  end

  def current_max_billing_value
    result = ["No date", 0]
    bills = bill_by_account("us-east-1")

    merge_bills(bills, result)
  end

  def bill_by_account(select_region = @region)
    cloudwatch = Aws::CloudWatch::Client.new(region: select_region, credentials: @credentials)
    bill_value = []
    @accounts.each do |account|
      bill_value.push(cloudwatch.get_metric_statistics(
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
      ))
    end
    bill_value
  end

  def merge_bills(bills, result)
    bills.each do |bill|
      if bill.datapoints.any?
        result[0] = "#{bill.datapoints[0].timestamp}" unless result[0].eql? bill.datapoints[0].timestamp.to_s
        result[1] = result[1] + bill.datapoints[0].maximum
      end
    end
    result
  end
end
