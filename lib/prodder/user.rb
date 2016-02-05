require 'securerandom'

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
        user = new(user_name)
        user.save

        user
      end
    end

    def find_by_id(user_id)
      found, user_name = redis_store.user_exists?(user_id)
      if found && user_name
        find(user_name)
      else
        nil
      end
    end

    def get_leader
      redis_store.find_leader
    end

    def get_rank_by_day(user_id)
      rank = redis_store.get_rank_by_day(user_id)
      no_of_users = redis_store.user_count
      [rank, no_of_users]
    end

    def key(user_name)
      "#{USER_PREFIX}#{user_name}"
    end

    def redis_store
      Server.settings.redis_store
    end
  end
end
