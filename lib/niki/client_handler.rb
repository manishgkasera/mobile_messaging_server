module Niki
  class ClientHandler < ActiveRecord::Base
    self.table_name = 'client_handles'

    def self.do_work(io)
      io.puts "CLIENT_ID"
      client_id = io.gets
      if client_id == 'NONE'
        ci = self.create
      else
        ci = self.where(id: client_id).first || self.create
      end
      ci.lock_and_deliver_messages(io)
    end

    def lock_and_deliver_messages(io)
      with_lock do
        io.puts "CLIENT_ID: #{self.id}"
        loop do
          puts "Cheking message"
          break if self.disconnect_requested(io)
          self.check_and_deliver_message(io) || sleep(1)
        end
      end
    end

    def check_and_deliver_message(io)
      if message = ClientMessage.next(self)
        io.puts "MESSAGE: #{message.body}"
        return true
      end
    end

    # if client has not requested DISCONNECT
    # io#recv_nonblock will throw IO::EAGAINWaitReadable exception
    # catch that and return false
    def disconnect_requested(io)
      begin
        return io.recv_nonblock(10) == 'DISCONNECT'
      rescue IO::EAGAINWaitReadable
        return false
      end
    end
  end
end