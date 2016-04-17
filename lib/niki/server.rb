require 'socket'

module Niki
  class Server
    attr_reader :hostname, :port, :max_clients
    def initialize(port=8000)
      @port = port
      @hostname = Socket.gethostname
      @max_clients = 10
    end

    def start
      server = TCPServer.new hostname, port
      puts "Server started on #{server_id}"
      client_count = 0
      loop do
        if client_count < max_clients
          client_count += 1
          puts "Waiting for Client"
          Thread.start(server.accept) do |client|
            begin
              do_work(client)
              client.close
            rescue Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE => e
              puts "Exception for a client: #{e.message}"
            ensure
              client_count -= 1
            end
          end.join
        end
      end
    end

    def server_id
      "#{hostname}:#{port}"
    end

    def do_work(io)
      ClientHandler.do_work(io)
    end
  end
end