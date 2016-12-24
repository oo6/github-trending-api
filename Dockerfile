FROM daocloud.io/ruby:2.3.3-alpine

MAINTAINER iLeeXu "leexu.job@gmail.com"

RUN apk add --update \
    build-base \
    libxml2-dev \
    libxslt-dev \
    && rm -rf /var/cache/apk/*

ADD . /code/github-trending-api
WORKDIR /code/github-trending-api

RUN bundle install

EXPOSE 3000
