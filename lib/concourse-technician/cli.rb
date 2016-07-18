require 'instacli'

module ConcourseTechnician
  class CLI < ::InstaCLI::CLI
    include ::InstaCLI::Help
    include ::InstaCLI::Silence

    def methods(m)
      super(m).reject { |m| [:Contract, :functype].include? m }
    end
  end
end
