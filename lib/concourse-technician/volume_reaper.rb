require 'btrfs'
require 'contracts'
require 'fileutils'
require 'systemized'
require 'time'
require_relative 'settings'

module ConcourseTechnician
  class VolumeReaper
    include ::Contracts::Core
    include ::Contracts::Builtin
    include Settings

    Contract None => ArrayOf[Time]
    def timestamps
      @timestamps ||= worker.journal.read(1000).map do |entry|
        Time.parse entry.split.first
      end.sort
    end

    Contract None => ArrayOf[Hash]
    def recent_events
      @recent_events ||= logs.read(100).map do |event|
        begin
          JSON.load event
        rescue JSON::ParserError
          nil
        end
      end.compact
    end

    Contract None => Any
    def damaged
      detected? ? exit : abort
    end

    Contract None => Any
    def repair
      detected ? repair! : abort
    end

    private

    Contract RespondTo[:to_s] => Bool
    def env?(key)
      if ![nil, 'nil', 'false'].include? ENV[key.to_s.upcase]
        true
      else
        block_given? ? yield : false
      end
    end

    Contract None => Bool
    def stagnant_logs?
      env?(:stagnant_logs) do
        (Time.now - timestamps.last) > (timestamps.last - timestamps.first)
      end
    end

    Contract None => Bool
    def reaping_failure?
      env?(:reaping_failure) do
        recent_events.any? do |event|
          event['message'] == 'baggageclaim.tick.failed-to-reap'
        end
      end
    end

    Contract RespondTo[:to_s] => nil
    def report(message)
      STDERR.puts message.to_s unless env?(:QUIET)
    end

    Contract None => Bool
    def detected?
      stagnant_logs?.tap do |status|
        report "Most recent log entry @ #{timestamps.last}"
        report "Logs seem stagnant? #{status}"
      end && reaping_failure?.tap do |status|
        report "Recently volume reaping failure? #{status}"
      end
    end

    Contract None => ::Systemized::Service
    def worker
      @worker = ::Systemized::Service.new('concourse-worker')
    end

    Contract None => ::Systemized::Journal
    def logs
      @logs ||= ::Systemized::Journal.new('concourse-worker', output: 'cat')
    end

    Contract None => String
    def volumes_root
      @volumes_root ||= ENV.fetch('VOLUMES_ROOT') do
        settings.fetch('volumes_root') { '/concourse/volumes' }
      end
    end

    Contract None => ArrayOf[::Btrfs::Subvolume]
    def subvolumes
      @subvolumes ||= ::Btrfs::Volume.new(volumes_root).subvolumes
    end

    Contract None => Maybe[Bool]
    def reap_subvolumes
      report "Reaping #{subvolumes.size} subvolumes..."
      subvolumes.each(&:delete).all?(&:deleted?) unless env?(:NOOP)
    end

    Contract None => ArrayOf[String]
    def dead_volumes
      Dir.glob("#{volumes_root}/dead/*")
    end

    Contract None => Any
    def reap_dead_volumes
      report "Reaping #{dead_volumes.size} dead volumes..."
      dead_volumes.each do |volume|
        FileUtils.rmtree volume, verbose: env?(:QUIET), noop: env?(:NOOP)
      end
    end

    Contract None => Any
    def repair!
      worker.stop if worker.active? && !env?(:NOOP)
      reap_subvolumes
      reap_dead_volumes
      worker.start unless env?(:NOOP)
    end
  end
end
