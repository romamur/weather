# frozen_string_literal: true

# == Schema Information
#
# Table name: cities
#
#  id        :bigint           not null, primary key
#  latitude  :decimal(10, 6)
#  longitude :decimal(10, 6)
#  name      :string           not null
#
# Indexes
#
#  index_cities_on_name  (name) UNIQUE
#
class City < ApplicationRecord
  attribute :temperature, :string
end
