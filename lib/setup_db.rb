
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

if !conn.table_exists?(:client_messages)
  conn.create_table(:client_messages) do |t|
    t.integer :client_handler_id
    t.string :body
    t.column :status, 'tinyint unsigned'
    t.timestamps null: false
  end
  conn.add_index(:client_messages, [:client_handler_id, :status])
  conn.add_index(:client_messages, [:client_handler_id, :created_at, :body], name: 'ch_created_at_body')
end


if !conn.table_exists?(:servers)
  conn.create_table(:servers) do |t|
    t.string :hostname
    t.column :port, 'smallint unsigned'
    t.timestamps null: false
  end
end