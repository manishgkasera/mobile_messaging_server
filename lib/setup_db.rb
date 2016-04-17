
ActiveRecord::Base.logger = Logger.new(STDOUT)
db_config = {
              host: 'localhost',
              username: 'root',
              password: 'root',
              database: 'niki_messaging_server',
              socket: '/var/run/mysqld/mysqld.sock', 
              adapter: 'mysql2'
            }

client = Mysql2::Client.new(db_config.except(:database))
client.query("create database if not exists #{db_config[:database]}") 
ActiveRecord::Base.establish_connection(db_config)

conn = ActiveRecord::Base.connection

if !conn.table_exists?(:client_handles)
  conn.create_table(:client_handles) do |t|
    t.timestamps null: false
  end
end