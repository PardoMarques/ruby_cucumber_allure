ARG RUBY_VERSION=3.0.0
FROM ruby:${RUBY_VERSION}

WORKDIR /test-admission-command/

COPY . /test-admission-command/

RUN gem install bundle && bundle install