#!/bin/bash
# run using "./setup-unix.sh" without quotes
bundle exec rake db:drop db:create db:schema:load RAILS_ENV=development
