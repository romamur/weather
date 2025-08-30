# frozen_string_literal: true

class WeatherService
  include Dry::Transaction

  step :receive_weather

  # @return [Array<Hash>]
  def receive_weather
    weather = []
    nc = Rails.nats_client.nats
    js = nc.jetstream
    psub = js.pull_subscribe("WEATHER", "WEATHER")

    loop do
      messages = psub.fetch(20)
      messages.each do |msg|
        weather << JSON.parse(msg.data)
        msg.ack
      end
      Rails.logger.info "received weather(#{weather.size})"
      next if weather.empty?

      prev_weather = Rails.cache.read('weather') || []
      Rails.cache.write('weather', weather + prev_weather, expires_in: 1.day)
      Turbo::StreamsChannel.broadcast_prepend_to(
        :weather, partial: 'weathers/weather', locals: { weather: }, target: :weather)

      sleep(60)
    end

    Success(weather)
  rescue => e
    Rails.logger.error e.detailed_message
    Failure(error: "Unexpected error when receiving weather", code: :unexpected_receiving_error)
    sleep(60)
    retry
  end
end
