require 'sinatra'
require 'twilio-ruby'
require 'wolfram'
require 'yaml'

config = YAML.load_file('config.yaml')
account_sid=config['account']['account_sid']
auth_token=config['account']['auth_token']
to_number=config['to']
from_number=config['from']

get '/' do

    'Hi'
end

get '/send_sms/:name' do |name|

  client = Twilio::REST::Client.new account_sid, auth_token

  client.account.messages.create(
      :to => to_number,
      from: from_number,
      body: "Hello #{name}"
  )

  'You sent a message'
end

get '/wolfram/:query' do |query|
  get_wolfram(query)
end

def get_wolfram(query)
  result = Wolfram.fetch(query)
  # to see the result as a hash of pods and assumptions:
  hash = Wolfram::HashPresenter.new(result).to_hash
  hash[:pods]["Result"]
end
