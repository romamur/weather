# frozen_string_literal: true

class OpenMeteoClient
  BASE_URL = 'https://api.open-meteo.com'

  include Api::V1::Forecast

  # @return [Faraday::Connection]
  attr_reader :conn

  def initialize(**opts)
    @conn = Faraday.new(default_options(**opts)) do |b|
      b.request :json
      b.response :json
      b.response :raise_error
    end
  end

  private

  def default_options(**opts)
    {
      url: BASE_URL,
      request: { timeout: 60 }
    }.merge(opts)
  end
end
