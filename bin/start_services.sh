#!/usr/bin/env bash

# Run Sidekiq in the background to handle ActiveJobs
bundle exec sidekiq &

# Run the repeating rewards processor in the background
bundle exec rake rewards:process &

# Run Puma web server in the foreground
# This keeps the container alive
bundle exec puma -C config/puma.rb
