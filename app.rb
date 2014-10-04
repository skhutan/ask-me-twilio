require 'sinatra'
require 'twilio-ruby'
require 'yaml'

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

post '/twil/received' do
    
    p params[:body]

    'ok'
end
