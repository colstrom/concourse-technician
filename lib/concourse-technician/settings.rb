require 'contracts'
require 'yaml'

module ConcourseTechnician
  module Settings
    include ::Contracts::Core
    include ::Contracts::Builtin

    private

    Contract None => String
    def settings_path
      @config_path ||= ENV['CONCOURSE_TECHNICIAN_CONFIG'] || File.expand_path('~/.config/concourse-technician.yaml')
    end

    Contract None => HashOf[String, Or[String, Num]]
    def settings
      @config ||= YAML.load_file settings_path
    end
  end
end
