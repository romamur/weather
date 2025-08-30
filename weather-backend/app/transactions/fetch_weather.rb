# frozen_string_literal: true

class FetchWeather
  include Dry::Transaction

  step :load_cities
  step :fetch_cities_temperature
  step :broadcast_cities_temperature

  def load_cities
    CitiesService.new.call
  end

  # @param [Array<City>] cities
  def fetch_cities_temperature(cities)
    client = OpenMeteoClient.new
    cities.each do |c|
      c.temperature = client.v1_forecast_temperature(latitude: c.latitude, longitude: c.longitude)
    end
    Success(cities)
  end

  # @param [Array<City>] cities
  def broadcast_cities_temperature(cities)
    ts = Time.current
    nc = Rails.nats_client.nats
    return Failure(error: 'Connect to NATS failed', code: :nats_connection_error) unless nc

    js = nc.jetstream
    js.add_stream(name: "WEATHER", subjects: [ "WEATHER" ])
    cities.each do |c|
      payload = { name: c.name, ts: ts.iso8601, temp: c.temperature }
      js.publish("WEATHER", payload.to_json)
    end
    Success(cities)
  rescue => e
    Rails.logger.error e.detailed_message
    Failure(error: "Unexpected error when broadcasting cities temperature", code: :unexpected_broadcasting_error)
  end
end
