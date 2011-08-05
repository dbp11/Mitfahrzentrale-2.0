# Source: http://snippets.dzone.com/posts/show/2525
# With some minor modifications

desc 'Create YAML test fixtures from data in an existing database.
Defaults to development database.  Set RAILS_ENV to override.'

task :extract_fixtures => :environment do
  sql = 'SELECT * FROM %s'
  skip_tables = ['schema_info', 'schema_migrations']
  skip_tables += ENV['EXCLUDE'].split unless ENV['EXCLUDE'].blank?
  ActiveRecord::Base.establish_connection
  (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
    puts "Extracting #{table_name.pluralize}..."
    i = '000'
    File.open "#{Rails.root}/test/fixtures/#{table_name}.yml", 'w' do |file|
      data = ActiveRecord::Base.connection.select_all sql % table_name
      file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
	hash
      }.to_yaml
    end
  end
end
