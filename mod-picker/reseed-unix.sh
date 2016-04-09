#!/bin/bash
rake setup:reset:db
rake setup:reset:ids
rake db:seed
# rake db:seed RAILS_ENV=test