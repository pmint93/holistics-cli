module Holistics
  class Transforms < SubcommandBase
    def initialize(*args)
      super
      @this = Model::JobDefinition.new(Holistics.client, 'data_transforms')
    end
    def self.help(*args)
      super
      puts <<-INSTRUCTION
Examples:
  holistics transforms list # List all data transformations

      INSTRUCTION
    end

    desc 'list', 'List all data transformations'
    def list(ds_id = nil)
      puts "`transforms list` called with options: #{options}" if Holistics.debug?
      tp(
        @this.all.map do |item|
          item.slice(*%w{id title owner_name}).merge({
            mode: item['settings']['mode'],
            created_at: item['created_at'] ? DateTime.parse(item['created_at']).to_formatted_s(:short) : nil,
            last_run:   item['last_run']   ? DateTime.parse(item['last_run']).to_formatted_s(:short)   : nil
          })
        end
      )
    end

    desc 'info ID', 'Show a data transform by ID'
    def info(id)
      puts "`transform info #{id}` called with options: #{options}" if Holistics.debug?
      item = @this.find(id)
      # General info
      {
        id: item['id'].to_s.yellow,
        title: item['title'],
        data_source: item['data_source_id'],
        data_dest_id: item['data_dest_id'],
        owner_id: item['owner_id'],
        dest_schema_name: item['dest_schema_name'],
        dest_table_name: item['dest_table_name'],
        tenant_id: item['tenant_id'],
        settings: item['settings'],
        created_at: item['created_at'] ? DateTime.parse(item['created_at']).to_formatted_s(:short) : nil,
        updated_at: item['updated_at'] ? DateTime.parse(item['updated_at']).to_formatted_s(:short) : nil
      }.each { |k, v| puts [k.to_s.upcase, v].join(": ") }
      puts ""
      # Query info
      puts "==> QUERY:"
      puts item['query'].to_s.magenta
      puts ""
      puts "==> COLUMNS:"
      tp(item['table_config']['columns'], *%w{column_name data_type is_nullable})
      puts ""
      {
        dist_key: item['dist_key'],
        dist_style: item['dist_style'],
        sort_keys: item['sort_keys'],
        sort_style: item['sort_style'],
        enable_upsert: item['enable_upsert'],
        upsert_column: item['upsert_column'],
        increment_column: item['increment_column']
      }.each { |k, v| puts [k.to_s.upcase, v].join(": ") }
      puts ""
      # Schedules
      puts "==> SCHEDULES:"
      tp(item['schedules'])
      puts ""
    end

    desc 'execute ID', 'Execute a transform job by ID'
    def execute(id)
      puts "`transforms execute #{id}` called with options: #{options}" if Holistics.debug?
      result = @this.execute(id)
      puts 'Job ID: ' + result['job_id'].to_s.yellow + " Submit: " + Holistics::Utils.colorize(result['status'])
      invoke 'holistics:jobs:logs', [result['job_id']], { follow: true }
    end
    map %w[exec] => :execute

    # desc 'delete ID', 'Remove a data transform by ID'
    # def delete(id)
    #   puts "`transform delete #{id}` called with options: #{options}" if Holistics.debug?
    #   tp(@this.remove(id))
    # end

  end
end
