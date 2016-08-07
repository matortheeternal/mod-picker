# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << %w( )

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

Rails.application.config.assets.precompile += [
# angular apps
'modpicker.js',
# themes
'main/Whiterun.css',
'main/Darkwater.css',
'main/Blackreach.css',
'main/High Hrothgar.css',
'help/High Hrothgar.css',
'legal.css',
# temporary welcome page assets
'temp/welcome.css',
'animate.css',
'bootstrap.min.css',
'style-responsive.css',
'jquery.countdown.min.js',
'jquery.nicescroll.min.js',
'jquery.smooth-scroll.js',
'script.js',
# vendor assets
'rzslider.min.css',
'simplemde.min.css',
'marked.min.js',
'angular-animate.min.js',
'angular-relative-date.min.js',
'angular-smooth-scroll.min.js',
'angular-drag-and-drop-lists.min.js',
'angular.min.1.5.1.js',
'angular-marked.min.js',
'angular-ui-router.min.js',
'angular-marked.min.js',
'ct-ui-router-extras.min.js',
'angular-elastic-input.min.js',
'sticky.min.js',
'bootstrap.min.js',
'rzslider.min.js',
'heartcode-canvasloader-min.js',
'spin.min.js',
'simplemde.min.js',
'wow.min.js'
]
