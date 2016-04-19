module Niki
  class ClientMessage < ActiveRecord::Base
    # create a new db connection
    # to move this class outside of any existing db transaction
    # since we are dealing with outside world
    # once we mark message delivered we dont want that to rollback for whatsoever be the reason
    establish_connection(connection_config)

    enum status: [:pending, :delivered, :ignored]

    belongs_to :client_handler

    after_create :notify_servers

    def self.next(client_handler)
      self.pending.where(client_handler: client_handler).first
    end

    def self.enqueue(client_handler_id, body)
      new_message = self.new(client_handler_id: client_handler_id, body: body)
      if duplicate?(new_message)
        new_message.ignored!
        return false
      else
        new_message.pending!
      end
    end

    def self.duplicate?(message)
      self.where(
                  client_handler_id: message.client_handler_id,
                  body: message.body,
                  status: self.statuses.except(:ignored).values).
           where('created_at >= ?', 5.seconds.ago).exists?
    end

    def notify_servers
      Server.all.each do |s|
        s.new_message_arrived(self.client_handler)
      end
    end
  end
end