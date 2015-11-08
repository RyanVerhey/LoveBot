require 'rubygems'
require 'bundler/setup'
require 'net/http'
require 'httparty'
require 'json'
require 'yaml'
require_relative 'reddit'
require_relative 'lovebot'

random_post = Reddit.random_post
Reddit.random_comment(random_post)
