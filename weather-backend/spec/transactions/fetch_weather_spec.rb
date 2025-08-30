# frozen_string_literal: true

RSpec.describe FetchWeather do
  it "success fetch temperature and broadcast to NATS" do
    result = described_class.new.call

    expect(result).to be_success
    expect(result.value!).to be_a(Array)
    # @type [City]
    result.value!.each do |city|
      expect(city.temperature).to be_present
    end
  end
end
