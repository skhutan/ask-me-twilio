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
@@client = Twilio::REST::Client.new @@account_sid, @@auth_token

@@absolute_zero = 273.15

get '/' do
  "Hi"
end

post '/voicemail/:message' do |message|
  response = Twilio::TwiML::Response.new do |r|
    r.Say message, voice: 'alice', language: 'en-GB'
    r.Dial callerId: @@to_number do |d|
      d.Client 'Inquisitor'
    end
  end
  response.text
end

def call_me(message)
  @call = @@client.account.calls.create(
  from: @@from_number, # From your Twilio number
  to: @@to_number, # To any number
  # Fetch instructions from this URL when the call connects
  url: %{http://mlh.homelinen.org/voicemail/#{CGI.escape(message)}}
)
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
      if wolfram_result == "Sorry, no answer available"
        send_sms(wolfram_result, from)
      else
        call_me(wolfram_result.join(' '))
      end
    else
      puts "Command #{command} not found"
  end
  'ok'
end

def send_sms(message, phone_number)
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
  main_result = "Sorry, no answer available" if main_result.nil? or main_result[0] == '(data not available)'
  main_result
end

def get_weather(query)
  req = Net::HTTP.get('api.openweathermap.org', "/data/2.5/weather?q=#{query}")
  res = JSON.parse(req)

  weather_description = res['weather'][0]['description']
  # Convert absolute zero to Celsius
  temperature = (res['main']['temp'] - @@absolute_zero).to_i
  wind = res['wind']['speed']

  "#{query.capitalize} has temperatures of #{temperature}C with wind speeds of #{wind}mph and #{weather_description.downcase}."
end
