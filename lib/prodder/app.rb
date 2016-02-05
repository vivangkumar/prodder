require 'json'

class App
  APP_FILE_PATH = './apps.json'

  class << self
    def populate_redis
      redis_store.store_apps(parse_apps)
    end

    def lookup_score(app_name)
      redis_store.get_score(app_name)
    end

    private

    def parse_apps
      apps = JSON.parse(File.read(APP_FILE_PATH)).to_a
      apps.map { |e| [e.last.to_f, e.first] }
    end

    def redis_store
      Server.settings.redis_store
    end
  end
end
