# frozen_string_literal: true

class CitiesService
  include Dry::Transaction

  step :parse_env_variable
  step :load_from_db

  def parse_env_variable
    cities = ENV.fetch('WEATHER_CITIES', 'Moscow;Saint Petersburg').split(';').compact_blank
    if cities.empty?
      Failure(error: 'No cities was found in config', code: :not_found_in_env)
    else
      Success(cities)
    end
  end

  # @param [Array<String>] cities
  def load_from_db(cities)
    cities_from_db = City.where(name: cities).to_a
    if cities_from_db.empty?
      Failure(error: 'No cities was found in DB', code: :not_found_in_db)
    else
      Success(cities_from_db)
    end
  end
end
