#!/bin/bash
rake db:drop db:create db:schema:load RAILS_ENV=test