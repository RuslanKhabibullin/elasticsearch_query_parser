require "rubygems"
require "bundler/setup"
require "json"
require_relative "elasticsearch_query_parser"

Bundler.require(:default)

parser = ElasticsearchQueryParser.new(ARGV[0])
puts parser.call.to_json
