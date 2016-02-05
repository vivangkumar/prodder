require 'sinatra'
require 'json'

require './lib/prodder'

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
    content_type 'text/html'
    @users = User.get_sorted_users_with_scores
    erb :index
  end

  get '/api' do
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
    if User.find_by_id(params[:user_id])
      app_name = params[:app_name]
      if (hostname = params[:hostname])
        app_name = Event.hostname_to_app_name(hostname)
      end

      event =
        Event.new(
          app_name,
          params[:time_spent],
          params[:timestamp],
          params[:user_id],
        )
      event.save

      rank, num_users = User.get_rank_by_day(params[:user_id])
      leader = User.get_leader
      send_response({ rank: rank, no_of_users: num_users, leader: leader.user_name })
    else
      status 404
      send_response({ error: 'User not found' })
    end
  end

end