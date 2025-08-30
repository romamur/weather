# frozen_string_literal: true

class NatsClient
  MAX_RECONNECT_ATTEMPTS = 60

  def initialize(servers: [ ENV.fetch("NATS_URI", "nats://127.0.0.1:4222") ])
    @servers = servers
    @lock = Mutex.new
  end

  def nats
    init_nats if @nats.nil?
    begin
      unless @nats.connected?
        @lock.synchronize do
          @nats.connect(@nats_options) unless @nats.connected?
        end
      end
    rescue Errno::ECONNREFUSED
      Rails.logger.error("NATS connection refused")
    rescue => e
      raise "An error has occurred while connecting to NATS: #{e.detailed_message}"
    end
    @nats
  end

  def close
    nats&.close
  end

  private

  def init_nats
    @lock.synchronize do
      if @nats.nil?
        require "nats/io/client"

        @nats = NATS::IO::Client.new
        @nats_options = {
          servers: @servers,
          dont_randomize_servers: true,
          max_reconnect_attempts: MAX_RECONNECT_ATTEMPTS,
          reconnect_time_wait: 2,
          reconnect: true
        }

        @nats.on_error do |e|
          @logger.error("NATS client error: #{e.detailed_message}")
        end
      end
    end
  end
end

Rails.application.config.nats_client = NatsClient.new

module Rails
  def self.nats_client
    application.config.nats_client
  end
end

at_exit do
  Rails.nats_client.nats&.close
end
