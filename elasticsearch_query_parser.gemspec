Gem::Specification.new do |s|
  s.name = "elasticsearch_query_parser"
  s.version = "0.0.3"
  s.date = "2020-07-25"
  s.summary = "Parse user queries into Elastic query"
  s.description = "Convert user queries like `(London OR Paris) AND 'John Wick'` into elasticsearch JSON queries"
  s.author = "Ruslan Khabibullin"
  s.email = "khabibullin.ruslan.95@gmail.com"
  s.homepage = "https://rubygems.org/gems/elasticsearch_query_parser"
  s.files = Dir.glob("lib/**/*") + %w[LICENSE README.md]
  s.add_development_dependency "rspec", "~> 3.9"
  s.add_runtime_dependency "parslet", "~> 2.0"
  s.license = "MIT"
end
