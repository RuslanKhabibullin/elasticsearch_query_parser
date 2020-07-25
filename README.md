# Elasticsearch query parser

[![Build Status](https://semaphoreci.com/api/v1/khabibullin_ruslan/elasticsearch_query_parser/branches/master/badge.svg)](https://semaphoreci.com/khabibullin_ruslan/elasticsearch_query_parser)

User input examples:
- I can search “London” and it will return everyone with “London”
- And then a complex example could be a boolean search such as: ((‘London’ OR ‘Paris’ OR ‘Madrid’) AND ‘Venture Capital’) NOT ‘VC’


Client query examples:

- `ElasticsearchQueryParser.new("London").call`

Result:

```
{query:{bool:{should:[{match:{text:{query:"London",operator:"and"}}}]}}}
```

- `ElasticsearchQueryParser.new("London Madrid").call`

Result:

```
{query:{bool:{should:[{match:{text:{query:"London",operator:"and"}}},{match:{text:{query:"Madrid",operator:"and"}}}]}}}
```

- `ElasticsearchQueryParser.new("London OR Madrid").call`

Result:

```
{query:{bool:{should:[{match:{text:{query:"London",operator:"and"}}},{match:{text:{query:"Madrid",operator:"and"}}}]}}}
```

- `ElasticsearchQueryParser.new("(London OR Madrid) AND Paris").call`

Result:

```
{query:{bool:{must:[{match:{text:{query:"Paris",operator:"and"}}},{bool:{should:[{match:{text:{query:"Madrid",operator:"and"}}},{match:{text:{query:"London",operator:"and"}}}]}}]}}}
```

- `ElasticsearchQueryParser.new("(((London OR Paris) OR Madrid) AND 'Venture Capital') NOT VC").call`

Result:

```
{query:{bool:{must:[{match:{text:{query:"Venture Capital",operator:"and"}}},{bool:{should:[{match:{text:{query:"Madrid",operator:"and"}}},{bool:{should:[{match:{text:{query:"Paris",operator:"and"}}},{match:{text:{query:"London",operator:"and"}}}]}}]}}],must_not:[{match:{text:{query:"VC",operator:"and"}}}]}}}
```

- `ElasticsearchQueryParser.new("Paris AND (London OR Madrid)").call`

Result:

```
{query:{bool:{must:[{match:{text:{query:"Paris",operator:"and"}}},{bool:{should:[{match:{text:{query:"London",operator:"and"}}},{match:{text:{query:"Madrid",operator:"and"}}}]}}]}}}
```

- `ElasticsearchQueryParser.new("VC AND ('Venture Capital' AND (Madrid OR (Paris AND London)))").call`

Result:

```
{query:{bool:{must:[{match:{text:{query:"VC",operator:"and"}}},{bool:{must:[{match:{text:{query:"Venture Capital",operator:"and"}}},{bool:{should:[{match:{text:{query:"Madrid",operator:"and"}}},{bool:{must:[{match:{text:{query:"Paris",operator:"and"}}},{match:{text:{query:"London",operator:"and"}}}]}}]}}]}}]}}}
```

- `ElasticsearchQueryParser.new("((London OR Madrid) NOT VC) NOT 'Venture Capital'").call`

Result:

```
{query:{bool:{should:[{match:{text:{query:"Madrid",operator:"and"}}},{match:{text:{query:"London",operator:"and"}}}],must_not:[{match:{text:{query:"VC",operator:"and"}}},{match:{text:{query:"Venture Capital",operator:"and"}}}]}}}
```
