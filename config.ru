require './lib/prodder'
require './server'

Server.set :redis_store, RedisStore.new
App.populate_redis

run Server
