module Holistics
  class Sources < SubcommandBase
    def initialize(*args)
      super
      @this = Model::Resource.new(Holistics.client, 'data_sources')
    end
    def self.help(*args)
      super
      puts <<-INSTRUCTION
Examples:
  holistics sources list # List all data sources

      INSTRUCTION
    end

    desc 'list', 'List all data sources'
    def list
      puts "`sources list` called with options: #{options}" if Holistics.debug?
      tp(@this.all)
    end

    desc 'info ID', 'Show a data source by ID'
    def info(id)
      puts "`sources info #{id}` called with options: #{options}" if Holistics.debug?
      item = @this.find(id)
      puts "Source ID: " + item['id'].to_s.yellow
      {
        name: item['name'],
        dbtype: item['dbtype'],
        slug: item['slug'],
        settings: item['settings']
      }.each { |k, v| puts "\t" + [k,v].join(": ") }
    end

    # desc 'delete ID', 'Remove a data source by ID'
    # def delete(id)
    #   puts "`sources delete #{id}` called with options: #{options}" if Holistics.debug?
    #   tp(@this.remove(id))
    # end

  end
end
