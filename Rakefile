#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# Rails 4.2 task loading expects Rake::Application#last_comment.
# Some newer rake runtimes no longer provide this accessor.
unless Rake.application.respond_to?(:last_comment)
  class << Rake.application
    attr_accessor :last_comment
  end
end

Rottenpotatoes::Application.load_tasks
