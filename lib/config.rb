require 'yaml'

# This load config/config.yml
class ConfigApp
  attr_reader :params

  def initialize
    @params = YAML.load_file(File.join(__dir__, '..', 'config', 'config.yml'))
  end
end
