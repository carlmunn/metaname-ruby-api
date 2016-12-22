$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'fakeweb'
require "metaname"

FakeWeb.allow_net_connect = false
#Metaname::StdoutTranscript.debug = true

# The test and production log ons are different
def test_params
  {
    uri: Metaname::TEST_URI,
    account: {
      reference: "xqd7",
      api_key:   "97dV0cIUUjoDkoG7QnhoRWFFVWL3tHQNWh7AH5U94kpulkyJ",
    },
  }
end

def stub_req(options={})
  allow(Metaname::StdoutTranscript).to receive(:next_message_id).and_return('random-date-integer')

  _body = {"id": 'random-date-integer', "jsonrpc":"2.0"}.merge!(options)
  FakeWeb.register_uri(:post, "https://test.metaname.net/api/1.1", body: _body.to_json)
end