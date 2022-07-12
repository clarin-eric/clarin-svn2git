FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y git-core git-svn ruby rubygems
RUN gem install svn2git
