require 'drb/drb'
require 'timeout'

module God
  module Contacts
    class Irc < Contact
      class << self
        attr_accessor :server_settings
      end

      attr_accessor :channel

      def valid?
        valid = true
      end

      def notify(message, time, priority, category, host)

        begin
          chokan = DRbObject.new_with_uri("druby://#{Irc.server_settings[:address]}:#{Irc.server_settings[:port]}")
          
          self.channel = "##{self.channel}" unless self.channel =~ /^#/

          timeout(3) do
            chokan.notice self.channel, "#{host}:#{category}/#{priority} #{message}"
          end
          self.info = "sent irc update to #{channel}"
        rescue => e
          self.info = "failed to send irc from #{channel}: #{e.message}"
        end
      end
    end
  end
end
