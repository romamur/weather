# frozen_string_literal: true

module Api
  module V1
    module Forecast
      extend ActiveSupport::Concern

      included do
        def v1_forecast(latitude:, longitude:)
          conn.get('/v1/forecast', { latitude:, longitude:, current_weather: true }).body
        end

        def v1_forecast_temperature(latitude:, longitude:)
          forecast = v1_forecast(latitude:, longitude:)
          temperature = forecast.dig('current_weather', 'temperature')
          unit = forecast.dig('current_weather_units', 'temperature')
          return unless unit.present? && temperature

          "#{temperature} #{unit}"
        end
      end
    end
  end
end
