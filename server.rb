require 'sinatra'
require 'json'
require_relative 'user'
require_relative 'event'

class Server < Sinatra::Base
  configure { set :server, :puma }

  before do
    content_type 'application/json'
  end

  helpers do
    def send_response(hash)
      hash.to_json
    end
  end

  get '/' do
    { prodder: 'API' }.to_json
  end

  post '/users' do
    user = User.find_or_create(params[:user_name])
    send_response({ user_id: user.id })
  end

  get '/users' do
    if (user = User.find(params[:user_name]))
      send_response(user.serialize)
    else
      status 404
      send_response({ error: 'User not found' })
    end
  end

  post '/events' do
    event =
      Event.new(
        params[:app_name],
        params[:time_spent],
        params[:timestamp],
        params[:user_id],
      )
    event.save

    send_response({ event_id: event.id })
  end

end