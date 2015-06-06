require 'yaml'

class ConfigApp
  def initialize
    @params = YAML::load_file(File.join(__dir__, '..' ,'config' ,'config.yml'))
  end

  def params
    @params
  end
end