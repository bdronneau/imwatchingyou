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
    points = []

    last_x = 1
    total_value = 0

    monitor['responsetime'].reverse.each do |value|
      points.push({ x: last_x, y: value['value'].to_i })

      total_value += value['value'].to_i
      last_x += 1
    end

    points.push({ x: last_x + 1, y: total_value / last_x })
  end

  def random_monitor
    data = []

    monitors = all_monitors

    monitor_random = monitors.sample

    points = graph_data(monitor_random)

    data.push(points)
    data.push(monitor_random['friendlyname'])

    data
  end
end
