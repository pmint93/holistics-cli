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
  holistics jobs list -t DataTransform # List all transform jobs

      INSTRUCTION
    end

    desc 'list', 'List all jobs'
    method_option :source_type, aliases: '-t', desc: 'Filter by job type: DataImport, DataTransform, ...'
    def list
      puts "`jobs list` called with options: #{options}" if Holistics.debug?
      tp(
        @this.all(options).map do |item|
          {
            id: item['id'],
            source_method: item['source_method'],
            title: item['title'],
            created_at: item['created_at'] ? DateTime.parse(item['created_at']).to_formatted_s(:short) : nil,
            source_type: item['source_type'],
            source_id: item['source_id'],
            # start_time: item['start_time'] ? DateTime.parse(item['start_time']).to_formatted_s(:short) : nil,
            # end_time: item['end_time'] ? DateTime.parse(item['end_time']).to_formatted_s(:short) : nil,
            duration: (item['duration'] < 0 ? nil : Time.at(item['duration']).utc.strftime("%H:%M:%S")),
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
      {
        id: item['id'].to_s.yellow,
        status: Holistics::Utils.colorize(item['status']),
        source_method: item['source_method'],
        source_type: item['source_type'],
        source_id: item['source_id'],
        created_at: DateTime.parse(item['created_at']).to_formatted_s(:short),
        user_id: item['user_id'],
        start_time: item['start_time'] ? DateTime.parse(item['start_time']).to_formatted_s(:short) : nil,
        end_time: item['end_time'] ? DateTime.parse(item['end_time']).to_formatted_s(:short) : nil,
        tenant_id: item['tenant_id'],
        duration: (item['duration'] < 0 ? nil : Time.at(item['duration']).utc.strftime("%H:%M:%S"))
      }.each { |k, v| puts [k.to_s.upcase, v].join(": ") }
    end

    desc 'logs ID', 'Show job logs by ID'
    method_option :follow, aliases: '-f', desc: 'Specify if the logs should be streamed', type: :boolean
    method_option :number, aliases: '-n', desc: 'Only print number of last lines', type: :numeric
    def logs(id)
      puts "`jobs logs #{id}` called with options: #{options}" if Holistics.debug?
      if options[:follow]
        last_id = 0
        loop do
          data = @this.logs(id, { 'last_id': last_id })
          print_logs(id, data['logs'])
          last_id = data['logs'].last['id'] if data['logs'].length > 0
          break unless data['has_more']
          sleep 0.5
        end
      else
        data = @this.logs(id)
        print_logs(id, data['logs'], options[:number])
      end
    end

    desc 'cancel', 'Cancel a running job'
    def cancel(id)
      puts "`jobs cancel #{id}` called with options: #{options}" if Holistics.debug?
      print "Cancelling Job #{id} ...".yellow
      result = @this.cancel(id)
      if result['status'].to_s.upcase == 'OK'
        loop do
          job_info = @this.find(id)
          unless job_info['status'] == 'cancelling'
            puts Holistics::Utils.colorize(job_info['status'])
            break
          end
          sleep 0.5
        end
      else
        puts "Failed to cancel the job #{id}".red
      end
    end

    private

    def print_logs(job_id, log_lines, line_count = 0)
      line_count ||= 0
      log_lines ||= []
      log_lines[(-[line_count, log_lines.length].min)..-1]
      log_lines.each do |log_line|
        t = log_line['timestamp'] || Time.now.utc
        puts "[#{t} ##{job_id}] #{log_line['level']}: #{log_line['message']}"
      end
    end

  end
end
