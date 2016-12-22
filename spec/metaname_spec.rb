describe Metaname do

  #Metaname.debug = true

  it "has a version number" do
    expect(Metaname::VERSION).not_to be nil
  end

  it "checks the initialization process" do
    expect(Metaname::Client.initialized).to be_nil
    client1 = Metaname::Client.new(test_params)
    expect(Metaname::Client.initialized).to be_truthy
  end
  
  context 'initialized client' do
    
    before do
      @client = Metaname::Client.new(test_params)
    end

    it 'tests the balance check' do
      stub_req("result": "0.00")
      expect(@client.balance[:result]).to eql "0.00"
    end

    it 'tests no credit' do

      stub_req("error":{"message":"Transaction declined","data":"insufficient credit","code":-11})

      expect(->{
        result = @client.register(domain: 'test.nz', term: 1)
      }).to raise_error Metaname::JsonRpc::Error, "Transaction declined"
    end

    it 'tests #renew' do
      skip "waiting for credit on test API"
      result = @client.renew(domain: 'test.nz', term: 1)
    end

    it 'tests #domains' do
      skip "waiting for credit on test API"
      result = @client.domains
    end

    it 'tests #domain' do
      skip "waiting for credit on test API"
      result = @client.domain('test.nz')
    end

    it 'tests #domain - not found' do

      stub_req("error":{
        "message":"Domain name not found",
        "data":"XXX",
        "code":-5
      })

      result = @client.domain('test.nz')

      expect(result[:error]).to match "Domain name not found, XXX"
    end

    it 'tests re-newal of non existent domain' do

      stub_req("error":{
        "message":"Domain name not found",
        "data":"No such domain name in your account: test.nz",
        "code":-5
      })

      result = @client.renew(domain: 'test.nz', term: 1)
    end

    it 'tests #price non-renew' do
      skip "waiting for credit on test API"
      result = @client.renew(domain: 'test.nz', term: 1)
    end

    it 'tests #price renew' do
      skip "waiting for credit on test API"
      result = @client.renew(domain: 'test.nz', term: 1)
    end

    it 'tests #check taken' do
      stub_req("result":"taken")
      response = @client.check(domain: 'test.nz', ip: '0.0.0.0')
      expect(response[:result]).to eql 'taken'
    end

    it 'tests #check available' do
      stub_req("result":"available")
      response = @client.check(domain: 'test.nz', ip: '0.0.0.0')
      expect(response[:result]).to eql 'available'
    end
  end
end
