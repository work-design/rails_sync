module RailsSync
  class Engine < ::Rails::Engine

    config.eager_load_paths += Dir[
      "#{config.root}/app/models/mysql"
    ]

  end
end
