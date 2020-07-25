# Elasticsearch query parser

[![Build Status](https://semaphoreci.com/api/v1/khabibullin_ruslan/elasticsearch_query_parser/branches/master/badge.svg)](https://semaphoreci.com/khabibullin_ruslan/elasticsearch_query_parser)
[![Gem Version](https://badge.fury.io/rb/elasticsearch_query_parser.svg)](https://badge.fury.io/rb/elasticsearch_query_parser)

- I can search “London” and it will return everyone with “London”
- And then a complex example could be a boolean search such as: ((('London' OR 'Paris') OR 'Madrid') AND 'Venture Capital') NOT VC

## Hot to install

Add this line to your application's Gemfile:

```ruby
gem "elasticsearch_query_parser"
```

And then execute:

```sh
$ bundle
```

## How to use

```ruby
require "elasticsearch_query_parser"

ElasticsearchQueryParser.parse_query("London")
# => { query: { bool: { should: [{ match: { text: { query: "London", operator: "and" } } }] } } }

ElasticsearchQueryParser.parse_query("London Madrid")
=begin
{
  query: {
    bool: {
      should: [
        { match: { text: { query: "London", operator: "and" } } },
        { match: { text: { query: "Madrid", operator: "and" } } }
      ]
    }
  }
}
=end

ElasticsearchQueryParser.parse_query("London OR Madrid")
=begin
{
  query: {
    bool: {
      should: [
        { match: { text: { query: "London", operator: "and" } } },
        { match: { text: { query: "Madrid", operator: "and" } } }
      ]
    }
  }
}
=end

ElasticsearchQueryParser.parse_query("(London OR Madrid) AND Paris")
=begin
{
  query: {
    bool: {
      must: [
        { match: { text: { query: "Paris", operator: "and" } } },
        {
          bool: {
            should:[
              { match: { text: { query: "Madrid", operator: "and" } } },
              { match: { text: { query: "London", operator:"and" } } }
            ]
          }
        }
      ]
    }
  }
}
=end

ElasticsearchQueryParser.parse_query("(((London OR Paris) OR Madrid) AND 'Venture Capital') NOT VC")
=begin
{
  query: {
    bool: {
      must: [
        { match: { text: { query: "Venture Capital", operator: "and" } } },
        {
          bool: {
            should: [
              { match: { text: { query: "Madrid", operator: "and" } } },
              {
                bool: {
                  should: [
                    { match: { text: { query: "Paris", operator: "and" }}},
                    { match: { text: { query: "London", operator: "and" } } }
                  ]
                }
              }
            ]
          }
        }
      ],
      must_not:[{ match: { text: { query: "VC", operator: "and" } } }]
    }
  }
}
=end

ElasticsearchQueryParser.parse_query("Paris AND (London OR Madrid)")
=begin
{
  query:{
    bool: {
      must:[
        { match: { text: { query: "Paris", operator: "and" } } },
        {
          bool: {
            should:[
              { match: { text: { query: "London", operator: "and" } } },
              { match: { text: { query: "Madrid", operator: "and" } } }
            ]
          }
        }
      ]
    }
  }
}
=end

ElasticsearchQueryParser.parse_query("VC AND ('Venture Capital' AND (Madrid OR (Paris AND London)))")
=begin
{
  query: {
    bool: {
      must:[
        { match: { text: { query: "VC", operator: "and" } } },
        {
          bool: {
            must: [
              { match: { text: { query: "Venture Capital", operator: "and" } } },
              {
                bool: {
                  should:[
                    { match: { text: { query: "Madrid", operator: "and" } } },
                    {
                      bool: {
                        must: [
                          { match: { text: { query: "Paris", operator: "and" } } },
                          { match: { text: { query: "London", operator: "and" } } }
                        ]
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    }
  }
}
=end

ElasticsearchQueryParser.parse_query("((London OR Madrid) NOT VC) NOT 'Venture Capital'")
=begin
{
  query: {
    bool: {
      should: [
        { match: { text: { query: "Madrid", operator: "and" } } },
        { match: { text: { query: "London", operator: "and" } } }
      ],
      must_not: [
        { match: { text: { query: "VC", operator: "and" } } },
        { match: { text: { query: "Venture Capital", operator: "and" } } }
      ]
    }
  }
}
=end
```

## How to change Elastic field name

By default `#parse_query` generates elastic query with `text` attribute. You can customize field name via config:

```ruby
ElasticsearchQueryParser.configure do |config|
  # elastic_field_name can accepts symbol or string
  config.elastic_field_name = "title"
end

ElasticsearchQueryParser.parse_query("London")
# => { query: { bool: { should: [{ match: { "title": { query: "London", operator: "and" } } }] } } }
```
