require "rubygems"
require "bundler/setup"
require "parslet"
require_relative "grammar/parser"
require_relative "grammar/transformer"
require_relative "sentence"
Bundler.require(:default)

query = Sentence.new(ARGV[0]).to_s
begin
  parse_tree = Grammar::Parser.new.parse(query)
  puts parse_tree.inspect
rescue Parslet::ParseFailed => e
  puts e.parse_failure_cause.ascii_tree
end
