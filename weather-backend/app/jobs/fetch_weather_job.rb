# frozen_string_literal: true

class FetchWeatherJob
  include Sidekiq::Job
  sidekiq_options retry: false, dead: false

  def perform
    FetchWeather.new.call do |m|
      m.failure do |f|
        logger.error "#{f[:error]} (#{f[:code]})"
      end
      m.success do |cities|
        logger.info "send weather(#{cities.size})"
      end
    end
  end
end
