module Niki
  class ClientMessage
    def self.next(client_handle)
      OpenStruct.new(:body => 'hi there') if rand(10) == 5
    end
  end
end