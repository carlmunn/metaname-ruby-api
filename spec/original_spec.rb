describe Metaname::OriginalAPI do
  
  # The test and production log ons are different
  let(:params) {
    {
      uri: Metaname::TEST_URI,
      account: {
        reference: "xqd7",
        api_key:   "97dV0cIUUjoDkoG7QnhoRWFFVWL3tHQNWh7AH5U94kpulkyJ",
      },
    }
  }

  it 'tests the original code' do

    allow(Metaname::StdoutTranscript).to receive(:next_message_id).and_return('random-date-integer')

    _body = {"id": 'random-date-integer', "result":"0.00", "jsonrpc":"2.0"}
    FakeWeb.register_uri(:post, "https://test.metaname.net/api/1.2", body: _body.to_json)

    #Metaname::StdoutTranscript.debug = true

    Metaname::OriginalAPI.initialize!(params)
    expect(Metaname::OriginalAPI.account_balance).to eql "0.00"
  end
end