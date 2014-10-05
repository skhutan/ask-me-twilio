require 'sinatra'
require 'twilio-ruby'
require 'wolfram'
require 'yaml'
require './lib/command_parse'

config = YAML.load_file('config.yaml')
@@account_sid=config['account']['account_sid']
@@auth_token=config['account']['auth_token']
@@to_number=config['to']
@@from_number=config['from']
@@client = Twilio::REST::Client.new @@account_sid, @@auth_token

get '/' do
  "Hi"
end

get '/voicemail' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say 'You have one MESSAGE... BEEP!!!', voice: 'woman'
    r.Dial callerId: @@to_number do |d|
      d.Client 'Calum'
    end
  end
end

get '/callme' do
  @call = @@client.account.calls.create(
  from: @@from_number, # From your Twilio number
  to: @@to_number, # To any number
  # Fetch instructions from this URL when the call connects
  url: 'http://mlh.homelinen.org/voicemail'
)
end

get '/send_sms/:name' do |name|
  send_sms("Hello #{name}", @@to_number)
  %{You sent a message to #{ @@to_number }}
end

get '/wolfram/:query' do |query|
  get_wolfram(query)
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
        puts 'the weather is nice'
      when 'wolfram'
        wolfram_result = get_wolfram(args.join())
        send_sms(wolfram_result, from)
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
  main_result = "Sorry, no answer available" unless main_result
  main_result
end
