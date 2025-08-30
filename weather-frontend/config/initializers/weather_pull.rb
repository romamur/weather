# frozen_string_literal: true

Rails.application.config.to_prepare do
  Thread.new do
    WeatherService.new.call
  end
end
