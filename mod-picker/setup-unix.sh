#!/bin/bash
# run using "./setup-unix.sh" without quotes
rake db:drop db:create db:schema:load RAILS_ENV=development
