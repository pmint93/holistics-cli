module Holistics
  class Imports < SubcommandBase
    def initialize(*args)
      @this = Model::JobDefinition.new(Holistics.client, 'data_imports')
      super
    end
    def self.help(*args)
      super
      puts <<-INSTRUCTION
Examples:
  holistics imports list # List all import jobs

      INSTRUCTION
    end

    desc 'list', 'List all import jobs'
    def list
      puts "`imports list` called with options: #{options}" if Holistics.debug?
      tp(
        @this.all.map do |item|
          source =  case item['source_type']
                    when 'dbtable'
                      source_config = item['source_config'][item['source_type']]
                      "(#{source_config['ds_id']}) #{source_config['fqname']}"
                    else
                      # TODO: add another source types
                      item['source_label']
                    end
          destination = "(#{item['dest_ds_id']}) " + [item['dest_schema_name'], item['dest_table_name']].map(&:to_s).join('.')
          last_run_status = if item['last_run_job']
                              case item['last_run_job']['status']
                              when 'success' then item['last_run_job']['status'].green
                              when 'failed'  then item['last_run_job']['status'].red
                              else
                                item['last_run_job']['status']
                              end
                            else
                              'unknown'.yellow
                            end
          {
            id: item['id'],
            title: item['title'],
            owner: item['owner_name'],
            source: source,
            destination: destination,
            created_at: DateTime.parse(item['created_at']).to_formatted_s(:short),
            last_run: DateTime.parse(item['last_run']).to_formatted_s(:short),
            last_run_status: last_run_status
          }
        end
      )
    end

    # desc 'info ID', 'Show a import job by id'
    # def info(id)
    #   puts "`imports info #{id}` called with options: #{options}" if Holistics.debug?
    #   tp(@this.find(id))
    # end

    desc 'execute', 'Execute a import job by ID'
    def execute(id)
      puts "`imports execute #{id}` called with options: #{options}" if Holistics.debug?
      result = @this.execute(id)
      puts 'Job ID: ' + result['job_id'].to_s.yellow
      puts 'Status: ' + Holistics::Utils.colorize(result['status'])
      invoke 'holistics:jobs:logs', [result['job_id']], { watch: true }
    end
    map %w[exec] => :execute

    # desc 'delete ID', 'Remove a import job by id'
    # def delete(id)
    #   puts "`imports delete #{id}` called with options: #{options}" if Holistics.debug?
    #   tp(@this.remove(id))
    # end

  end
end
