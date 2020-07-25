require_relative "../lib/elasticsearch_query_parser"

RSpec.describe ElasticsearchQueryParser do
  describe "#configuration" do
    subject(:parse_config) { described_class.configuration }

    it { is_expected.to respond_to :elastic_field_name }
    it { expect(parse_config.elastic_field_name).to eq :text }
  end

  describe "#parse_query" do
    subject(:parse_result) { described_class.parse_query(query) }

    context "when query is nil" do
      let(:query) { nil }

      it { is_expected.to eq({}) }
    end

    context "when query is empty" do
      let(:query) { "" }

      it { is_expected.to eq({}) }
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

      it { is_expected.to eq expected_response }
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

      it { is_expected.to eq expected_response }
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

      it { is_expected.to eq expected_response }
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

      it { is_expected.to eq expected_response }
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

      it { is_expected.to eq expected_response }
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

      it { is_expected.to match expected_response }
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

      it { is_expected.to match expected_response }
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

      it { is_expected.to match expected_response }
    end

    context "when elastic field changed" do
      let(:query) { "London" }
      let(:expected_response) do
        {
          query: {
            bool: {
              should: [{
                match: { title: { query: "London", operator: "and" } }
              }]
            }
          }
        }
      end

      before do
        described_class.configure do |config|
          config.elastic_field_name = :title
        end
      end

      it { is_expected.to eq expected_response }
    end
  end

  describe "#configure" do
    before do
      described_class.configure do |config|
        config.elastic_field_name = :title
      end
    end

    it { expect(described_class.configuration.elastic_field_name).to eq :title }
  end
end
