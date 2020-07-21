# Elasticsearch query parser

User input examples:
- I can search “London” and it will return everyone with “London”
- And then a complex example could be a boolean search such as: ((‘London’ OR ‘Paris’ OR ‘Madrid’) AND ‘Venture Capital’) NOT ‘VC’


Client query examples:

- London
- London Madrid
- London OR Madrid
- (London OR Madrid) AND Paris
- (((London OR Paris) OR Madrid) AND 'Venture Capital') NOT VC
- Paris AND (London OR Madrid)
- VC AND ('Venture Capital' AND (Madrid OR (Paris AND London)))
- ((London OR Madrid) NOT VC) NOT 'Venture Capital'
