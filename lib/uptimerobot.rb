require 'pp'

# This class get information from uptimerobot for API
class UptimeRobot
  def initialize
    @conf = ConfigApp.new
  end

  def construct_url
    api_url = 'http://api.uptimerobot.com'

    parameters = [
        "apiKey=#{@conf.params['uptimerobot']['token']}",
        'responseTimesAverage=30',
        'responseTimes=1',
        'customUptimeRatio=30',
        'format=json',
        'noJsonCallback=1'
    ]

    url = "#{api_url}/getMonitors?#{parameters.join('&')}"

    url
  end

  def all_monitors
    data = []

    response = JSON.parse(
        RestClient.get construct_url
    )

    response['monitors']['monitor'].each do |monitor|
      data.push(graph_data(monitor))
    end
  end

  def graph_data(monitor)

  end
end
