# http://ruby-doc.org/stdlib-2.0.0/libdoc/open-uri/rdoc/OpenURI.html
require 'open-uri'
# https://github.com/flori/json
require 'json'
# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'

class ConsulInfo
  def initialize
    open("https://www.ruby-lang.org/") {|f|
      f.each_line {|line| pp line}
    }
  end
end
