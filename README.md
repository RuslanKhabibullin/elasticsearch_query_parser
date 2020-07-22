# Elasticsearch query parser

User input examples:
- I can search “London” and it will return everyone with “London”
- And then a complex example could be a boolean search such as: ((‘London’ OR ‘Paris’ OR ‘Madrid’) AND ‘Venture Capital’) NOT ‘VC’


Client query examples:

- London

Result:

```
{"query":{"bool":{"should":[{"match":{"text":{"query":"London","operator":"and"}}}]}}}
```

- London Madrid

Result:

```
{"query":{"bool":{"should":[{"match":{"text":{"query":"London","operator":"and"}}},{"match":{"text":{"query":"Madrid","operator":"and"}}}]}}}
```

- London OR Madrid

Result:

```
{"query":{"bool":{"should":[{"match":{"text":{"query":"London","operator":"and"}}},{"match":{"text":{"query":"Madrid","operator":"and"}}}]}}}
```

- (London OR Madrid) AND Paris

Result:

```
{"query":{"bool":{"must":[{"match":{"text":{"query":"Paris","operator":"and"}}},{"bool":{"should":[{"match":{"text":{"query":"Madrid","operator":"and"}}},{"match":{"text":{"query":"London","operator":"and"}}}]}}]}}}
```

- (((London OR Paris) OR Madrid) AND 'Venture Capital') NOT VC

Result:

```
{"query":{"bool":{"must":[{"match":{"text":{"query":"Venture Capital","operator":"and"}}},{"bool":{"should":[{"match":{"text":{"query":"Madrid","operator":"and"}}},{"bool":{"should":[{"match":{"text":{"query":"Paris","operator":"and"}}},{"match":{"text":{"query":"London","operator":"and"}}}]}}]}}],"must_not":[{"match":{"text":{"query":"VC","operator":"and"}}}]}}}
```

- Paris AND (London OR Madrid)

Result:

```
{"query":{"bool":{"must":[{"match":{"title":{"query":"Paris","operator":"and"}}},{"bool":{"should":[{"match":{"title":{"query":"London","operator":"and"}}},{"match":{"title":{"query":"Madrid","operator":"and"}}}]}}]}}}
```

- VC AND ('Venture Capital' AND (Madrid OR (Paris AND London)))

Result:

```
{"query":{"bool":{"must":[{"match":{"title":{"query":"VC","operator":"and"}}},{"bool":{"must":[{"match":{"title":{"query":"Venture Capital","operator":"and"}}},{"bool":{"should":[{"match":{"title":{"query":"Madrid","operator":"and"}}},{"bool":{"must":[{"match":{"title":{"query":"Paris","operator":"and"}}},{"match":{"title":{"query":"London","operator":"and"}}}]}}]}}]}}]}}}
```

- ((London OR Madrid) NOT VC) NOT 'Venture Capital'

Result:

```
{"query":{"bool":{"should":[{"match":{"title":{"query":"Madrid","operator":"and"}}},{"match":{"title":{"query":"London","operator":"and"}}}],"must_not":[{"match":{"title":{"query":"VC","operator":"and"}}},{"match":{"title":{"query":"Venture Capital","operator":"and"}}}]}}}
```
