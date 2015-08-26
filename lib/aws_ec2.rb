require 'json'
require 'aws-sdk'
require 'pp'
require './lib/aws_connection.rb'

# This class get informations of AWS ec2 with SDK v2
class AwsEc2 < AwsConnection
  def initialize
    super
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

  def number_elb
    elb = Aws::ElasticLoadBalancing::Client.new(region: @region, credentials: @credentials)
    elb.describe_load_balancers.load_balancer_descriptions.length
  end
end
