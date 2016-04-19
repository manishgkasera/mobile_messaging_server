module Niki
  class Server < ActiveRecord::Base

    def self.start(options={})
      options[:hostname] ||= Socket.gethostname
      options[:port] ||= 8000
      server = self.register!(options)
      server.start
    end

    def self.register!(options)
      self.find_or_create_by(hostname: options[:hostname], port: options[:port])
    end

    def start
      register_os_signals
      listen_for_client_commands
      # creats a thread which gets a event when new message arives
      # then sends it to the client
      event_listner_for_incomming_messages
      listen_for_new_connections
    end

    def event_port
      self.port + 1
    end

    def new_message_arrived(client_handler)
      socket = TCPSocket.new(self.hostname, self.event_port)
      socket.puts(client_handler.id)
      socket.close
    end

    private
      def register_os_signals
        Signal.trap("TERM") {
          say("Shutting down!!")
          exit
        }
        Signal.trap("INT") {
          say("Shutting down!!")
          exit
        }
      end

      def event_listner_for_incomming_messages
        Thread.start do
          server = TCPServer.new hostname, event_port
          say "Starting event listner on #{hostname}:#{event_port} PID:#{Process.pid}"
          loop do
            Thread.start(server.accept) do |client|
              ch_id = client.gets.to_i
              client.close
              cs = find_socket_by_id(ch_id)
              if cs
                if cs.closed?
                  remove_client(ch_id)
                else
                  do_work_with_lock(ClientHandler.find(ch_id), cs)
                end
              end
            end
          end
        end
      end

      def listen_for_client_commands
        Thread.start do
          loop do
            client_with_commands.each do |socket, ch_id|
              next if ch_id.nil?
              begin
                command = socket.gets.try(:chomp)
                handle_command(socket, ch_id, command)
              rescue IOError, Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE => e
                remove_client(ch_id)
              end
            end
          end
        end
      end

      def listen_for_new_connections
        server_socket = TCPServer.new hostname, port
        say "Starting main server on #{hostname}:#{port} PID:#{Process.pid}"
        loop do
          say "Waiting for Client... "
          Thread.start(server_socket.accept) do |client|
            add_client(client)
            do_work(client)
          end
        end
      end

      def do_work(socket)
        ch = ClientHandler.get_handler(socket)
        assign_client_handler_to_socket(socket, ch)
        begin
          do_work_with_lock(ch, socket)
        rescue Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE => e
          # bad socket
          say "Exception for a client: #{e.message}, removing.."
          remove_client(ch.id)
        end
      end

      def do_work_with_lock(client_handler, socket)
        client_handler.with_lock do
          client_handler.do_work(socket)
        end
      end

      def client_with_commands
        loop do
          if io_ready_clients = IO.select(client_sockets.keys, nil, nil, 5).try(:[], 0)
            return io_ready_clients.map{|socket| [socket, client_sockets[socket]]}
          end
          # if none has issued any commands
          # then check again with possible new clients
        end
      end

      def handle_command(socket, ch_id, command)
        case ClientHandler.find(ch_id).handle_command(command, socket)
        when :disconnect
          remove_client(ch_id)
        else
          socket.puts "Invalid command: #{command}"
        end
      end

      def add_client(socket)
        client_sockets[socket] = nil
      end

      def remove_client(ch_id)
        if socket = find_socket_by_id(ch_id)
          if !socket.closed?
            socket.close
          end
          client_sockets.delete(socket)
        end
      end

      def find_socket_by_id(ch_id)
        client_sockets.key(ch_id)
      end

      def assign_client_handler_to_socket(socket, ch)
        # remove client if previously connected
        # from other or same device
        remove_client(ch.id)
        client_sockets[socket] = ch.id
      end

      def client_sockets
        @client_sockets ||= {}
      end

      def say(message)
        puts "[#{Time.now}] #{message}"
      end
  end
end