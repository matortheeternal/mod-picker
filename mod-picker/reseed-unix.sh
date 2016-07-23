#!/bin/bash
bundle exec rake setup:reset:db
bundle exec rake setup:reset:ids
bundle exec rake db:seed
