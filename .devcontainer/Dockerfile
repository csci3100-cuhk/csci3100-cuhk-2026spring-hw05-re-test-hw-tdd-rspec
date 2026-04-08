# Dockerfile for HW05 - Ruby on Rails (Autograding environment)
# Versions strictly follow .github/workflows/classroom.yml
# Uses Ubuntu 20.04 + ruby-build to compile Ruby 2.7.0 exactly

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies for compiling Ruby and running the app
RUN apt-get update && apt-get install -y --no-install-recommends \
autoconf \
bison \
build-essential \
ca-certificates \
curl \
git \
libffi-dev \
libgdbm-dev \
libncurses5-dev \
libreadline-dev \
libsqlite3-dev \
libssl-dev \
libxml2-dev \
libxslt1-dev \
libyaml-dev \
sqlite3 \
zlib1g-dev \
nodejs \
openssl \
&& rm -rf /var/lib/apt/lists/*

# Install ruby-build and compile Ruby 2.7.0 (exact version from workflow)
RUN git clone --depth 1 https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
/tmp/ruby-build/bin/ruby-build 2.7.0 /usr/local && \
rm -rf /tmp/ruby-build

# Verify Ruby version
RUN ruby --version

# Fix Rails 4.2.9 + Ruby 2.7 compatibility:
# BigDecimal.new was removed in Ruby 2.7, but activesupport 4.2.9 still calls it.
# This must be loaded before ANY gem/bundle command that might touch Rails,
# and also before cucumber which loads rails via a different path than boot.rb.
RUN mkdir -p /usr/local/lib/ruby/site_ruby/2.7.0 && \
printf '%s\n' \
'require "bigdecimal"' \
'unless BigDecimal.respond_to?(:new)' \
' class BigDecimal' \
' def self.new(*args)' \
' BigDecimal(*args)' \
' end' \
' end' \
'end' \
> /usr/local/lib/ruby/site_ruby/2.7.0/bigdecimal_fix.rb

# Ensure the fix is loaded in every Ruby process
ENV RUBYOPT="-rbigdecimal_fix"

# Set working directory
WORKDIR /app

# Install Bundler 1.15.3 (exact version from workflow)
RUN gem install bundler -v 1.15.3 --no-document

# Install grader gems (exact versions from workflow)
# Pin public_suffix and addressable to versions compatible with Ruby 2.7
# (latest public_suffix requires Ruby >= 3.2)
RUN gem install public_suffix -v 5.1.1 --no-document && \
gem install addressable -v 2.8.6 --no-document && \
gem install rspec -v 3.10.0 --no-document && \
gem install nokogiri -v 1.12.5 --no-document && \
gem install connection_pool -v 2.5.5 --no-document && \
gem install net-http-persistent -v 4.0.1 --no-document && \
gem install mechanize -v 2.8.2 --no-document

# Copy Gemfile and Gemfile.lock first for layer caching
COPY Gemfile Gemfile.lock ./

# Install app dependencies (excluding production group, same as workflow)
RUN bundle _1.15.3_ install --without production

# Copy the rest of the application
COPY . .

# Do not run database tasks during image build.
# App migrations may change over time and can make the image build fail.

# Expose the Rails default port
EXPOSE 3000

# Start Rails server (matches workflow: development mode, port 3000)
CMD ["bundle", "exec", "rails", "server", "-e", "development", "-p", "3000", "-b", "0.0.0.0"]
