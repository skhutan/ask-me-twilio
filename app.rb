require 'sinatra'
require 'twilio-ruby'
require 'yaml'

require './lib/command_parse'

get '/' do
    'Hi'
end

get '/send_sms/:name' do |name|

    config = YAML.load_file('config.yaml')
    account_sid=config['account']['account_sid']
    auth_token=config['account']['auth_token']

    to_number=config['to']
    from_number=config['from']

    client = Twilio::REST::Client.new account_sid, auth_token

    client.account.messages.create(
        :to => to_number,
        from: from_number,
        body: "Hello #{name}"
    )

    'You sent a message'
end

# Eat the post request from twilio
# FIXME: Need a way to lock this down? User-agent?
post '/twil/received' do
    
    message = params['Body'].strip

    parsed = Parser.parse(message)

    command = parsed[:command]
    args = parsed[:args]
    
    case command
        when 'weather'
            puts 'the weather is nice'
        else
            puts "Command #{command} not found"
    end
    'ok'
end
