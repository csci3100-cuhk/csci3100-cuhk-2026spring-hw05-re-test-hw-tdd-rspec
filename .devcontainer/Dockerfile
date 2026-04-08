FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

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

RUN git clone --depth 1 https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
  /tmp/ruby-build/bin/ruby-build 2.7.0 /usr/local && \
  rm -rf /tmp/ruby-build

RUN ruby --version && gem --version

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

ENV RUBYOPT="-rbigdecimal_fix"

WORKDIR /app

# Key fix: downgrade RubyGems for old dependencies like ZenTest
RUN gem update --system 2.7.11 && \
  gem --version

RUN gem install bundler -v 1.15.3 --no-document && \
  bundle _1.15.3_ --version

RUN gem install public_suffix -v 5.1.1 --no-document && \
  gem install addressable -v 2.8.6 --no-document && \
  gem install rspec -v 3.10.0 --no-document && \
  gem install nokogiri -v 1.12.5 --no-document && \
  gem install connection_pool -v 2.5.5 --no-document && \
  gem install net-http-persistent -v 4.0.1 --no-document && \
  gem install mechanize -v 2.8.2 --no-document

COPY Gemfile Gemfile.lock ./

RUN bundle _1.15.3_ install --without production

COPY . .

RUN RAILS_ENV=development bundle _1.15.3_ exec rake db:setup && \
  RAILS_ENV=test bundle _1.15.3_ exec rake db:setup

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-e", "development", "-p", "3000", "-b", "0.0.0.0"]