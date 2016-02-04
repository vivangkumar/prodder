require_relative 'server'
require_relative 'redis_store'
require_relative 'app'

Server.set :redis_store, RedisStore.new
App.populate_redis

run Server