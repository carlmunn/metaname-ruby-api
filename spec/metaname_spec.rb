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
    
    def raised_error(str)
      expect(->{
        yield
      }).to raise_error Metaname::JsonRpc::Error, str
    end

    before do
      @client = Metaname::Client.new(test_params)
    end

    it 'tests the balance check' do
      stub_req("result": "0.00")
      expect(@client.balance).to eql "0.00"
    end

    context 'registering' do

      it 'register with no credit' do

        stub_req("error":{"message": "Transaction declined", "data": "insufficient credit", "code": -11})

        raised_error("Transaction declined") do
          result = @client.register(domain: 'test.nz', term: 1)
        end
      end

      it 'register with missing contacts param' do
        stub_req("error": {"code": -32602, "message": "Invalid params", "data": "contacts may not be null"})

        expect(->{
          @client.register(domain: 'xxx.co.nz', term: 1, contacts: nil)
        }).to raise_error Metaname::JsonRpc::Error
      end

      it 'register with missing partial contact details' do
        skip "Need to collect error message still"
        result = @client.register(domain: 'test-efadf2.co.nz', term: 1, contacts: {admin: {}})
        expect(result[:result]).to eql 'IDENTIFIER'
      end

      it 'register with credit' do

        stub_req("result": "IDENTIFIER")

        result = @client.register(domain: 'test-efadf2.co.nz', term: 1)
        expect(result[:result]).to eql 'IDENTIFIER'
      end

      it 'tests a domain that already exists' do

        stub_req("error": {
          "code": -99,
          "message": "test-already-exists.co.nz cannot be registered because it is already registered"
        })

        result = @client.register(domain: 'test-already-exists.co.nz', term: 1)
        expect(result[:error]).to eql "test-already-exists.co.nz cannot be registered because it is already registered"
      end

      # Test test.nz is valid but their system doesn't support it by the looks
      it 'tests a invalid domain (test.nz)' do

        stub_req("error": {
          "code": -32603,
          "message": "Internal error"
        })

        raised_error("Internal error") do
          @client.register(domain: 'invalid.nz', term: 1)
        end
      end
    end

    context 'exceptions' do
      
      it 'return a exception in hash form' do

        _exp = Metaname::JsonRpc::Error.new(5, 'invalid value')
        Metaname::OriginalAPI.stub(:method_missing).and_raise(_exp)
        
        _error = @client.request(:raise_me!)[:error]
        expect(_error).to eql "invalid value"
      end
    end

    context 'intercept' do

      it 'checks balance interception' do

        Metaname::Client.intercepter = ->(*args){
          'intercept-testing'
        }

        expect(@client.balance).to eql 'intercept-testing'

        Metaname::Client.intercepter = nil
      end
    end
    
    it 'tests #domains' do
      skip "seems this just does the same as #domain"
      result = @client.domains
    end

    it '#domain with found domain' do
      nameserver = {
        "ip6_address": nil,
        "ip4_address": nil,
        "name": "test-ns2.metaname.net"
      }

      contact = {
        "organisation_name"=>"Open2view",
        "fax_number"=>nil,
        "email_address"=>"carl.munn@open2view.com",
        "name"=>"Carl Munn",

        "phone_number"=>{
            "local_number"=>"8460220",
            "area_code"=>"9",
            "country_code"=>"64"
        },
        "postal_address"=>{
          "city"=>"Auckland",
          "postal_code"=>"1026",
          "line2"=>"",
          "line1"=>"505 Rosebank road",
          "region"=>"Avondale",
          "country_code"=>"nz"
        }
      }

      hsh_response = {"result": {
        "ds_records": [],
        "auto_renew_term": 1,
        "when_registered": "2017-04-12T13:29:28+12:00",
        "status": "Active",
        "name": "test-efadf2.co.nz",
        "when_paid_up_to": "2017-06-12T13:29:28+12:00",
        "name_servers": [nameserver, nameserver],
        "contacts": {
          technical:  contact,
          admin:      contact,
          registrant: contact
        }
      }}

      stub_req(hsh_response)

      result = @client.domain('test-efadf2.co.nz')[:result]

      expect(result['auto_renew_term']).to eql 1
      expect(result['status']).to eql "Active"
      expect(result['name']).to eql "test-efadf2.co.nz"
    end

    it 'tests #domain - not found' do

      stub_req("error":{
        "message": "Domain name not found",
        "data":    "XXX",
        "code":    -5
      })

      result = @client.domain('test.nz')

      expect(result[:error]).to match "Domain name not found, XXX"
    end

    it 'tests re-newal of non existent domain' do

      stub_req("error":{
        "message": "Domain name not found",
        "data":    "No such domain name in your account: test.nz",
        "code":    -5
      })

      result = @client.renew(domain: 'test.nz', term: 1)
    end

    it 'tests #price renew' do
      stub_req("result": nil)
      result = @client.renew(domain: 'test-efadf2.co.nz', term: 1)
      expect(result[:result]).to be_nil
    end

    it 'tests #check taken' do
      stub_req("result": "taken")
      response = @client.check(domain: 'test-efadf2.co.nz', ip: '0.0.0.0')
      expect(response[:result]).to eql 'taken'
    end

    it 'tests #check available' do
      stub_req("result": "available")
      response = @client.check(domain: 'test.co.nz', ip: '0.0.0.0')
      expect(response[:result]).to eql 'available'
    end
  end
end
