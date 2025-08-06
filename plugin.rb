# frozen_string_literal: true

# name: discourse-scheduled-bump
# about: A plugin that automatically bumps old topics to keep them fresh
# version: 1.0.0
# authors: Jeffrey
# url: https://github.com/b89k57w62/discourse-scheduled-bump

after_initialize do
  # Load the scheduled job
  load File.expand_path('../jobs/scheduled/bump_old_topics_job.rb', __FILE__)
end