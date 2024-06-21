module RailsSync
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/app"
    ]

    config.eager_load_paths += Dir[
      "#{config.root}/app/models/app"
    ]

  end
end
