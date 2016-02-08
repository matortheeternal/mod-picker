# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << %w( )

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
animate.css
bootstrap.min.css
welcome.css
angular.css
style-responsive.css
angular.js
angular.min.js
angular-route.min.js
bootstrap.min.js
heartcode-canvasloader-min.js
jquery.countdown.min.js
jquery.nicescroll.min.js
jquery.smooth-scroll.js
script.js
wow.min.js
)
