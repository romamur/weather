# frozen_string_literal: true

RSpec.describe OpenMeteoClient, type: :model do
  let(:client) { OpenMeteoClient.new }
  fixtures :cities

  it "success fetch weather in Moscow" do
    weather = client.v1_forecast(latitude: cities(:msk).latitude, longitude: cities(:msk).longitude)
    expect(weather).to be_a(Hash)
    expect(weather).to include("current_weather_units")
    expect(weather).to include("current_weather")
  end

  it "success fetch temperature in Moscow" do
    temperature = client.v1_forecast_temperature(latitude: cities(:msk).latitude, longitude: cities(:msk).longitude)
    expect(temperature).to be_present
  end
end
