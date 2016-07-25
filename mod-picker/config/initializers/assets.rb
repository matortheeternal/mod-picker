# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << %w( )

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.


# TODO: clean this shiat
Rails.application.config.assets.precompile += [
'animate.css',
'Whiterun.css',
'Darkwater.css',
'Blackreach.css',
'High Hrothgar.css',
'bootstrap.min.css',
'legal.css',
'temp/welcome.css',
'rzslider.min.css',
'style-responsive.css',
'simplemde.min.css',
'marked.min.js',
'modpicker.js',
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
'jquery.countdown.min.js',
'jquery.nicescroll.min.js',
'jquery.smooth-scroll.js',
'script.js',
'spin.min.js',
'simplemde.min.js',
'lzma.js',
'rar.js',
'wow.min.js',
'zip.js',
'pages/help.css'
]
