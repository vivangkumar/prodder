require 'securerandom'

class Event
  EVENT_PREFIX = 'event:'

  attr_accessor :app_name, :time_spent, :timestamp, :user_id, :id, :score

  def initialize(app_name, time_spent, timestamp, user_id)
    @app_name = app_name
    @time_spent = time_spent
    @timestamp = timestamp
    @user_id = user_id
  end

  def save
    @id = SecureRandom.hex(12)
    @score = App.lookup_score(@app_name)
    key = Event.key(@id)
    Event.redis_store.save_event(key, id, app_name, time_spent, timestamp, user_id, score)
  end

  def serialize
    {
      id: @id,
      app_name: @app_name,
      time_spent: @time_spent,
      timestamp: @timestamp,
      user_id: @user_id,
      score: @score
    }
  end

  class << self
    def redis_store
      Server.settings.redis_store
    end

    def key(id)
      "#{EVENT_PREFIX}#{id}"
    end
  end
end
