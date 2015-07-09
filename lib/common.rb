require 'socket'
require 'pp'

# This class contains general and reusable methods
class Common
  # http://hibberttech.blogspot.fr/2013/05/ruby-check-if-port-is-open.html
  def check_port_is_open?(ip, port, timeout)
    start_time = Time.now
    current_time = start_time
    while (current_time - start_time) <= timeout
      begin
        TCPSocket.new(ip, port)
        return true
      rescue Errno::ECONNREFUSED
        sleep 0.1
      end
      current_time = Time.now
    end
    false
  end
end
