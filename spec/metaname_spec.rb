describe Metaname do

  #Metaname.debug = true

  # The test and production log ons are different
  let(:params) {
    {
      uri: Metaname::TEST_URI,
      account: {
        reference: "xqd7",
        api_key:   "97dV0cIUUjoDkoG7QnhoRWFFVWL3tHQNWh7AH5U94kpulkyJ"
      }
    }
  }

  it "has a version number" do
    expect(Metaname::VERSION).not_to be nil
  end

  it "checks the initialization process" do
    expect(Metaname::Client.initialized).to be_nil
    client1 = Metaname::Client.new(params)
    expect(Metaname::Client.initialized).to be_truthy
  end
  
  context 'initialized client' do
    before do
      @client = Metaname::Client.new(params)
    end

    it 'tests the balance check' do
      expect(@client.request(:account_balance)).to eql "0.00"
    end
  end
end
