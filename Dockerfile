ARG RUBY_VERSION=3.0.0
FROM ruby:${RUBY_VERSION}

WORKDIR /ruby_cucumber_allure/

COPY . /ruby_cucumber_allure/

RUN gem install bundle && bundle install
