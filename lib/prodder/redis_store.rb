require 'redis'

class RedisStore
  PRODDER_PREFIX = 'prodder:'
  USER_PREFIX = 'users'
  EVENT_PREFIX = 'events:'

  def initialize
    @redis = Redis.new(url: ENV['REDIS_URL'])
  end

  def save_user(key, id)
    @redis.hmset(prefixed_key(key), 'id', id)
    @redis.sadd(prefixed_key(USER_PREFIX), prefixed_key(key))
  end

  def save_event(key, id, app_name, time_spent, timestamp, user_id, score)
    event_key = prefixed_key(key)
    @redis.hmset(
      event_key,
      'app_name', app_name,
      'time_spent', time_spent,
      'timestamp', timestamp,
      'user_id', user_id
    )

    key = prefixed_key("#{EVENT_PREFIX}#{user_id}")
    @redis.zincrby(
      dayscoped_key,
      score,
      key
    )
  end

  def get_rank_by_day(user_id)
    key = prefixed_key("#{EVENT_PREFIX}#{user_id}")

    # Redis ranks are 0 based
    @redis.zrevrank(dayscoped_key, key) + 1
  end

  def user_count
    @redis.smembers(prefixed_key(USER_PREFIX)).length
  end

  def store_apps(apps)
    key = prefixed_key('apps')

    unless @redis.exists(key)
      @redis.zadd(key, apps)
    end
  end

  def get_user(key)
    @redis.hgetall(prefixed_key(key))
  end

  def get_score(app_name)
    @redis.zscore(prefixed_key('apps'), app_name).to_f
  end

  private

  def prefixed_key(key)
    "#{PRODDER_PREFIX}#{key}"
  end

  def dayscoped_key
    start_of_day = Time.at(Time.now.to_i).to_date.to_time.to_i
    prefixed_key("#{EVENT_PREFIX}#{start_of_day}")
  end
end
