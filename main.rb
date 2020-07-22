require "rubygems"
require "bundler/setup"
require "parslet"
require 'json'
require_relative "grammar/parser"
require_relative "grammar/transformer"
require_relative "sentence"
Bundler.require(:default)

query = Sentence.new(ARGV[0]).to_s
begin
  parse_tree = Grammar::Parser.new.parse(query)
  transformer = Grammar::Transformer.new.apply(parse_tree)
  puts({ query: transformer.to_elasticsearch }.to_json)
rescue Parslet::ParseFailed => e
  puts e.parse_failure_cause.ascii_tree
end
