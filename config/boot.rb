require 'rubygems'

# Rails 4.2 expects BigDecimal.new, which is removed in newer Ruby.
require 'bigdecimal'
unless BigDecimal.respond_to?(:new)
  class << BigDecimal
    def new(*args)
      Kernel.BigDecimal(*args)
    end
  end
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
