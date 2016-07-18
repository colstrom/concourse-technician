require 'contracts'
require 'sequel'
require_relative 'settings'

module ConcourseTechnician
  class Database
    include ::Contracts::Core
    include ::Contracts::Builtin
    include Settings

    Contract None => Sequel::Dataset
    def workers
      db[:workers].select(:name)
    end

    Contract None => Sequel::Dataset
    def volumes
      db[:volumes].select(:id)
    end

    Contract None => Sequel::Dataset
    def abandoned_volumes
      volumes.exclude(worker_name: workers)
    end

    Contract None => Num
    def delete_abandoned_volumes
      abandoned_volumes.delete
    end

    private

    Contract None => Sequel::Database
    def db
      @db ||= Sequel.connect(settings)
    end
  end
end
