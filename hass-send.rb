#!/usr/bin/env ruby

require_relative 'client'

HOST = ENV['HASS_HOST'] ? ENV['HASS_HOST'].freeze : 'localhost'.freeze
PORT = ENV['HASS_PORT'] ? ENV['HASS_PORT'].to_i : 8123
TOKEN = ENV['HASS_TOKEN']

hass = Hass::Client.new(HOST, PORT, TOKEN)
hass.light('light.stehlampe').toggle

# light = Hass::Light.new('light.stehlampe')
# light.client = hass
