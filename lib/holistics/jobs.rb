module Holistics
  class Jobs < SubcommandBase
    def initialize(*args)
      super
      @this = Model::Job.new(Holistics.client, 'jobs')
    end
    def self.help(*args)
      super
      puts <<-INSTRUCTION
Examples:
  holistics jobs list -t transform # List all transform jobs

      INSTRUCTION
    end

    desc 'list', 'List all jobs'
    method_option :source_type, aliases: '-t', desc: 'Filter by job type: DataImport, DataTransform, ...'
    def list
      puts "`jobs list` called with options: #{options}" if Holistics.debug?
      tp(
        @this.all.map do |item|
          {
            id: item['id'],
            source_method: item['source_method'],
            title: item['title'],
            created_at: DateTime.parse(item['created_at']).to_formatted_s(:short),
            source_type: item['source_type'],
            source_id: item['source_id'],
            # start_time: DateTime.parse(item['start_time']).to_formatted_s(:short),
            # end_time: DateTime.parse(item['end_time']).to_formatted_s(:short),
            duration: Time.at(item['duration']).utc.strftime("%H:%M:%S"),
            # cancelledable
            user: item['user']['name'],
            status: Holistics::Utils.colorize(item['status'])
          }
        end
      )
    end

    desc 'info ID', 'Show a job by ID'
    def info(id)
      puts "`jobs info #{id}` called with options: #{options}" if Holistics.debug?
      item = @this.find(id)
      puts "Job ID: " + item['id'].to_s.yellow
      {
        status: Holistics::Utils.colorize(item['status']),
        source_method: item['source_method'],
        source_type: item['source_type'],
        source_id: item['source_id'],
        created_at: DateTime.parse(item['created_at']).to_formatted_s(:short),
        user_id: item['user_id'],
        start_time: DateTime.parse(item['start_time']).to_formatted_s(:short),
        end_time: DateTime.parse(item['end_time']).to_formatted_s(:short),
        tenant_id: item['tenant_id'],
        duration: Time.at(item['duration']).utc.strftime("%H:%M:%S")
      }.each { |k, v| puts "\t" + [k,v].join(": ") }
    end

    desc 'logs ID', 'Show job logs by ID'
    method_option :watch, aliases: '-f', desc: 'Watch for new logs', type: :boolean
    method_option :number, aliases: '-n', desc: 'Watch for new logs', type: :numeric
    def logs(id)
      puts "`jobs logs #{id}` called with options: #{options}" if Holistics.debug?
      if options[:watch]
        last_id = 0
        loop do
          data = @this.logs(id, { 'last_id': last_id })
          print_logs(data['logs'])
          last_id = data['logs'].last['id'] if data['logs'].length > 0
          break unless data['has_more']
          sleep 0.5
        end
      else
        data = @this.logs(id)
        print_logs(data['logs'], options[:number])
      end
    end

    # desc 'cancel', 'Cancel a running job'
    # def cancel(id)
    #   puts "Comming soon".yellow
    # end

    private

    def print_logs(log_lines, line_count = 0)
      line_count ||= 0
      log_lines ||= []
      log_lines[(-[line_count, log_lines.length].min)..-1]
      log_lines.each do |log_line|
        t = log_line['timestamp'] || Time.now.utc
        puts "#{t}; #{log_line['level']}: #{log_line['message']}"
      end
    end

  end
end
