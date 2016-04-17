module Niki
  class ClientHandler < ActiveRecord::Base
    self.table_name = 'client_handles'

    def self.get_handler(io)
      io.puts "GET_CLIENT_ID"
      client_id = io.gets
      if client_id == 'NONE'
        ch = self.create
      else
        ch = self.where(id: client_id).first || self.create
      end
      io.puts "SET_CLIENT_ID: #{ch.id}"
      return ch
    end

    def do_work(io)
      while(message = ClientMessage.next(self)) do
        io.puts "MESSAGE: #{message.body}"
        message.delivered!
      end
    end

    def handle_command(command, io)
      if command == 'DISCONNECT'
        return :disconnect
      end
    end
  end
end