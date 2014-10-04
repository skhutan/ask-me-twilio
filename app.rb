require 'sinatra'
require 'twilio-ruby'
require 'wolfram'
require 'yaml'
require 'json'
require 'net/http'

require './lib/command_parse'


config = YAML.load_file('config.yaml')
@@account_sid=config['account']['account_sid']
@@auth_token=config['account']['auth_token']
@@to_number=config['to']
@@from_number=config['from']

@@absolute_zero = 273.15

get '/' do
  'Hi'
end

get '/send_sms/:name' do |name|
  send_sms("Hello #{name}", @@to_number)
  %{You sent a message to #{@@to_number}}
end

get '/wolfram/:query' do |query|
  get_wolfram(query)
end

get '/weather/:query' do |query|
  get_weather(query)
end

# Eat the post request from twilio
# FIXME: Need a way to lock this down? User-agent?
post '/twil/received' do
    message = params['Body'].strip
    from = params["From"]
    parsed = Parser.parse(message)

    command = parsed[:command]
    args = parsed[:args]
    
    case command
        when 'weather'
          weather = get_weather(args)
          send_sms(weather, from)
        when 'wolfram'
          wolfram_result = get_wolfram(args)
          send_sms(wolfram_result, from)
        else
          puts "Command #{command} not found"
    end
    'ok'
end

def send_sms(message, phone_number)
  @@client = Twilio::REST::Client.new @@account_sid, @@auth_token
  @@client.account.messages.create(
    to: phone_number,
    from: @@from_number,
    body: message
  )
end

def get_wolfram(query)
  result = Wolfram.fetch(query)
  # to see the result as a hash of pods and assumptions:
  hash = Wolfram::HashPresenter.new(result).to_hash
  main_result = hash[:pods]["Result"]
  main_result = "Sorry, no answer available" unless main_result
  main_result
end

def get_weather(query)
  req = Net::HTTP.get('api.openweathermap.org', "/data/2.5/weather?q=#{query}")
  res = JSON.parse(req)

  p res

  weather_description = res['weather'][0]['description']
  # Convert absolute zero to Celsius
  temperature = (res['main']['temp'] - @@absolute_zero).to_i
  wind = res['wind']['speed']

  response = "#{query.capitalize} has #{weather_description} and temperatures of #{temperature}C with wind speeds of #{wind}"

  response
end
