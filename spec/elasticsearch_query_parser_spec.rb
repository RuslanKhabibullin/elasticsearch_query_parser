require_relative "../elasticsearch_query_parser"

RSpec.describe ElasticsearchQueryParser do
  subject(:parser) { described_class.new(query) }

  describe "#call" do
    context "when query is nil" do
      let(:query) { nil }

      it { expect(parser.call).to eq({}) }
    end

    context "when query is empty" do
      let(:query) { "" }

      it { expect(parser.call).to eq({}) }
    end

    context "when query contains only 1 simple term" do
      let(:query) { "London" }
      let(:expected_response) do
        {
          query: {
            bool: {
              should: [{
                match: { text: { query: "London", operator: "and" } }
              }]
            }
          }
        }
      end

      it { expect(parser.call).to eq expected_response }
    end

    context "when query contains multiple simple terms" do
      let(:query) { "London Madrid" }
      let(:expected_response) do
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
      end

      it { expect(parser.call).to eq expected_response }
    end

    context "when query contains term inside quotes" do
      let(:query) { "'John Wick'" }
      let(:expected_response) do
        {
          query: {
            bool: {
              should: [{
                match: { text: { query: "John Wick", operator: "and" } }
              }]
            }
          }
        }
      end

      it { expect(parser.call).to eq expected_response }
    end

    context "when query contains OR operator" do
      let(:query) { "London OR Madrid" }
      let(:expected_response) do
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
      end

      it { expect(parser.call).to eq expected_response }
    end

    context "when query contains AND operator" do
      let(:query) { "London AND Madrid" }
      let(:expected_response) do
        {
          query: {
            bool: {
              must: [
                { match: { text: { query: "London", operator: "and" } } },
                { match: { text: { query: "Madrid", operator: "and" } } }
              ]
            }
          }
        }
      end

      it { expect(parser.call).to eq expected_response }
    end

    context "when query contains nested structure(left to right)" do
      let(:query) { "Paris AND (London OR Madrid)" }
      let(:expected_response) do
        {
          query: {
            bool: {
              must: [
                { match: { text: { query: "Paris", operator: "and" } } },
                {
                  bool: {
                    should: match_array(
                      [
                        { match: { text: { query: "London", operator: "and" } } },
                        { match: { text: { query: "Madrid", operator: "and" } } }
                      ]
                    )
                  }
                }
              ]
            }
          }
        }
      end

      it { expect(parser.call).to match expected_response }
    end

    context "when query contains nested strucutr(right to left)" do
      let(:query) { "(London OR Madrid) AND Paris" }
      let(:expected_response) do
        {
          query: {
            bool: {
              must: [
                { match: { text: { query: "Paris", operator: "and" } } },
                {
                  bool: {
                    should: match_array(
                      [
                        { match: { text: { query: "London", operator: "and" } } },
                        { match: { text: { query: "Madrid", operator: "and" } } }
                      ]
                    )
                  }
                }
              ]
            }
          }
        }
      end

      it { expect(parser.call).to match expected_response }
    end

    context "when query contains NOT operator" do
      let(:query) { "(London OR Madrid) NOT Paris" }
      let(:expected_response) do
        {
          query: {
            bool: {
              should: match_array(
                [
                  { match: { text: { query: "London", operator: "and" } } },
                  { match: { text: { query: "Madrid", operator: "and" } } }
                ]
              ),
              must_not: [
                { match: { text: { query: "Paris", operator: "and" } } }
              ]
            }
          }
        }
      end

      it { expect(parser.call).to match expected_response }
    end
  end
end
