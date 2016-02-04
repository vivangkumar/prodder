require 'securerandom'
require_relative 'server'

class User
  USER_PREFIX = 'user:'

  attr_accessor :user_name, :id

  def initialize(user_name)
    @user_name = user_name
  end

  def save
    @id = SecureRandom.hex(12)
    User.redis_store.save_user(User.key(@user_name), @id)
  end

  def serialize
    { id: @id, user_name: @user_name }
  end

  class << self
    def find(user_name)
      user = redis_store.get_user(key(user_name))
      if user['id']
        user_obj = new(user_name)
        user_obj.id = user['id']
        user_obj
      else
        nil
      end
    end

    def find_or_create(user_name)
      if (user = find(user_name))
        user
      else
        new(user_name)
      end
    end

    def key(user_name)
      "#{USER_PREFIX}#{user_name}"
    end

    def redis_store
      Server.settings.redis_store
    end
  end
end