module ElasticsearchQueryParser
  module Grammar
    class Parser < ::Parslet::Parser
      rule(:lparen) { str("(") >> space? }
      rule(:rparen) { str(")") >> space? }
      rule(:quotes) { str("'") }
      rule(:space) { match("\s").repeat(1) }
      rule(:space?) { space.maybe }

      rule(:operator) {
        (
          str("AND") | str("and") | str("OR") | str("or") | str("NOT") | str("not")
        ).as(:operator) >> space
      }
      rule(:operator?) { operator.maybe }

      rule(:single_term) { match("[a-zA-z]").repeat(1).as(:term) }
      rule(:phrase_term) { quotes >> match("[^']").repeat(1).as(:term) >> quotes }
      rule(:term) { (phrase_term | single_term) >> space? }

      rule(:clause) { term >> operator >> query }
      rule(:paren_clause) { lparen >> query >> rparen }
      rule(:query) { (paren_clause | clause | term).repeat.as(:query) }

      root(:query)
    end
  end
end
