require 'thor'
require 'dummy_log_generator'
require 'active_support/core_ext'

module DummyLogGenerator
  class CLI < Thor
    class_option :config, :aliases => ["-c"], :type => :string, :default => 'dummy_log_generator.conf'
    default_command :start

    def initialize(args = [], opts = [], config = {})
      super(args, opts, config)

      @options = @options.dup # avoid frozen
      if options[:config] && File.exists?(options[:config])
        dsl = instance_eval(File.read(options[:config]), options[:config])
        @options[:setting] = dsl.setting
      end
    end

    desc "start", "Start a dummy_log_generator"
    # options for serverengine
    option :daemonize,   :aliases => ["-d"], :type => :boolean
    option :workers,     :aliases => ["-w"], :type => :numeric
    def start
      opts = @options.symbolize_keys.except(:config)

      se = ServerEngine.create(nil, DummyLogGenerator::Worker, opts)
      se.run
    end

    desc "stop", "Stops a dummy_log_generator"
    option :pid_path,    :aliases => ["-p"], :type => :string
    def stop
      pid = File.read(@options["pid_path"]).to_i

      begin
        Process.kill("QUIT", pid)
        puts "Stopped #{pid}"
      rescue Errno::ESRCH
        puts "DummyLogGenerator #{pid} not running"
      end
    end

    desc "graceful_stop", "Gracefully stops a dummy_log_generator"
    option :pid_path,    :aliases => ["-p"], :type => :string
    def graceful_stop
      pid = File.read(@options["pid_path"]).to_i

      begin
        Process.kill("TERM", pid)
        puts "Gracefully stopped #{pid}"
      rescue Errno::ESRCH
        puts "DummyLogGenerator #{pid} not running"
      end
    end

    desc "restart", "Restarts a dummy_log_generator"
    option :pid_path,    :aliases => ["-p"], :type => :string
    def restart
      pid = File.read(@options["pid_path"]).to_i

      begin
        Process.kill("HUP", pid)
        puts "Restarted #{pid}"
      rescue Errno::ESRCH
        puts "DummyLogGenerator #{pid} not running"
      end
    end

    desc "graceful_restart", "Graceful restarts a dummy_log_generator"
    option :pid_path,    :aliases => ["-p"], :type => :string
    def graceful_restart
      pid = File.read(@options["pid_path"]).to_i

      begin
        Process.kill("USR1", pid)
        puts "Gracefully restarted #{pid}"
      rescue Errno::ESRCH
        puts "DummyLogGenerator #{pid} not running"
      end
    end

  end
end

DummyLogGenerator::CLI.start(ARGV)
