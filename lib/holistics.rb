require 'thor'
require 'colorize'
require 'json'
require 'table_print'
require 'fileutils'
require 'active_support/all'

# require 'byebug'

require 'holistics/version'
require 'holistics/subcommand_base'
require 'holistics/utils'
require 'holistics/client'
require 'holistics/models/resource'
require 'holistics/models/job_definition'
require 'holistics/models/job'
require 'holistics/sources'
require 'holistics/imports'
require 'holistics/transforms'
require 'holistics/jobs'

module Holistics

  CONFIG_FILE = (ENV['HOME'] + '/.holistics/config').freeze

  @@client = nil

  def self.client=(client)
    @@client = client
  end

  def self.client
    @@client
  end

  def self.debug?
    ENV['HOLISTICS_DEBUG'] == 'true'
  end

  class CLI < Thor

    def initialize(args = [], local_options = {}, config = {})
      require_config! unless %w{help config version}.include? config[:current_command].name
      super
    end

    map %w[--version -v] => :version

    desc 'version', 'Show version information'
    def version
      puts "\nHolistics CommandLine Interface version #{Holistics::VERSION}".yellow
    end

    desc 'config [TOKEN]', 'Init or update config'
    def config(token = nil)
      unless token
        current_config = configured? ? read_config : {}
        current_token = current_config[:token]
        new_token = ask "Your Holistics token [#{current_token.light_black}]: "
        new_token = nil if new_token.blank?
        unless token = new_token || current_token
          STDERR.puts 'Failed to config, empty token provided !'
          exit 1
        end
      end
      verify_token(token) do
        write_config(:token => token)
      end
    end

    desc 'sources', 'Data sources'
    subcommand 'sources', Sources
    map %w[source] => :sources

    desc 'imports', 'Import jobs'
    subcommand 'imports', Imports
    map %w[import] => :imports

    desc 'transforms', 'Data transformations'
    subcommand 'transforms', Transforms
    map %w[transform] => :transforms

    desc 'jobs', 'Submitted jobs'
    subcommand 'jobs', Jobs
    map %w[job] => :jobs

    private

    def configured?
      File.exists?(Holistics::CONFIG_FILE)
    end

    def require_config!
      unless configured?
        STDERR.puts "Missing config, run #{'holistics config'.yellow} to init your"
        exit 1
      end
      Holistics.client ||= Holistics::Client.new(nil, read_config[:token])
    end

    def verify_token(token)
      print 'Verifying token ...'
      client = Holistics::Client.new(nil, token)
      status, body = client.get('/users/info.json')
      if status == 200
        user_info = JSON.parse(body)
        puts 'ok'.green
        puts '- ID: ' + user_info['id'].to_s.yellow
        puts '- Email: ' + user_info['email']
        yield if block_given?
      else
        STDERR.puts 'Token is invalid'.red
        exit 1
      end
    end

    def read_config
      result = {}
      File.read(Holistics::CONFIG_FILE).split("\n").map do |line|
        k, v = line.split("=").map(&:strip)
        result[k.to_sym] = v
      end
      result
    end

    def write_config(config = {})
      dir = Holistics::CONFIG_FILE.split('/')[0..-2].join('/')
      unless File.directory?(dir)
        FileUtils::mkdir dir
        FileUtils.touch Holistics::CONFIG_FILE
        puts 'Create ' + Holistics::CONFIG_FILE.green
      end
      File.open(Holistics::CONFIG_FILE, 'w+') do |file|
        file.write config.map { |k,v| "#{k} = #{v}" }.join
      end
      puts "Config updated !"
    end
  end
end
