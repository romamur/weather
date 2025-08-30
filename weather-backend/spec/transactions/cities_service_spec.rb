# frozen_string_literal: true

RSpec.describe CitiesService do
  it "success fetch temperature" do
    ENV['WEATHER_CITIES'] ||= 'Moscow;Saint Petersburg'
    result = described_class.new.call

    expect(result).to be_success
    expect(result.value!).to be_a(Array)
    # @type [City]
    result.value!.each do |city|
      expect(city.temperature).to be_nil
    end
  end

  it "failure fetch temperature" do
    ENV['WEATHER_CITIES'] = 'Gotham City'
    result = described_class.new.call

    expect(result).to be_failure
    expect(result.failure[:code]).to eq(:not_found_in_db)
    expect(result.failure[:error]).to be_present
  end
end
