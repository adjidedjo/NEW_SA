# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( penjualan/* )
Rails.application.config.assets.precompile += %w( stock/* )
Rails.application.config.assets.precompile += %w( order/* )
Rails.application.config.assets.precompile += %w( penjualan_salesman.js )
Rails.application.config.assets.precompile += %w( sales_productivities.js )
Rails.application.config.assets.precompile += %w( sales_productivities.css )
Rails.application.config.assets.precompile += %w( salesmen.js )
Rails.application.config.assets.precompile += %w( salesmen.css )
Rails.application.config.assets.precompile += %w( marketshares.js )
Rails.application.config.assets.precompile += %w( marketshares.css )
Rails.application.config.assets.precompile += %w( forecasts.js )
Rails.application.config.assets.precompile += %w( forecasts.css )
Rails.application.config.assets.precompile += %w( indonesia_cities.js )
Rails.application.config.assets.precompile += %w( indonesia_cities.css )
Rails.application.config.assets.precompile += %w( asong.js )
Rails.application.config.assets.precompile += %w( asong.css )