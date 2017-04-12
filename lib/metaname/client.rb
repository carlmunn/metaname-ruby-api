module Metaname
  class Client
    class << self
      attr_accessor :initialized
    end

    # For quick testing
    def self.test_client
      Metaname::Client.new({
        uri: Metaname::TEST_URI,
        account: {
          reference: "xqd7",
          api_key:   "97dV0cIUUjoDkoG7QnhoRWFFVWL3tHQNWh7AH5U94kpulkyJ"
        }
      })
    end

    def initialize(options={})
      if self.class.initialized
        log "initialized already"
      else
        log "Not initialized, initializing with #{options.inspect}"
        self.class.initialized = true
        initialize_metaname(options)
      end
    end

    # Only needs to be done once.
    def initialize_metaname(options)
      Metaname::OriginalAPI.initialize!(options)
    end

    # Makes the call to the original methods. The specific methods below are
    # recommended but if a method is missing use this one.
    #
    # The specific methods use ruby keyword parameters and interpret the results
    def request(_method, *args)
      catch_error do
        Metaname::OriginalAPI.method_missing(_method, *args)
      end
    end

    def balance
      request(:account_balance)
    end

    def domains
      request(:domain_names)
    end

    def domain(name)
      request(:domain_name, name)
    end

    def check(domain: nil, ip: nil)
      request(:check_availability, domain, ip)
    end

    # term = months i.e. 1 to 120 etc for NZ
    def price(domain: nil, term: nil, renewal: false)
      request(:price, domain, term, renewal)
    end

    # contact
    # name:             "Joe Bloggs"
    # email_address:    "joe@example.co.nz"
    # organisation_name: null  # Only for non-.nz names
    # postal_address:
    #   line1:        "15 Example Ave"
    #   line2:         null
    #   city:         "Exampleton"
    #   region:        null
    #   postal_code:  "1234"
    #   country_code: "NZ"
    # phone_number:
    #   country_code: "64"
    #   area_code:    "3"
    #   local_number: "123 456"
    # fax_number: null  # Optional

    # contact structure (optional if default set):
    # {admin: {CONTACT...}, registrant: {CONTACT...}, technical: {CONTACT...}}
    #
    # name_servers structure:
    # {name: '', ip4_address: '114.23.246.97', ip6_address: ''}
    #
    def register(domain: nil, term: nil, contacts: default_contacts, name_servers: nil)
      request(:register_domain_name, domain, term, contacts, name_servers)
    end

    def renew(domain: nil, term: nil)
      request(:renew_domain_name, domain, term)
    end

    private
    # Only logs if the Metaname.debug is set to true
    def log(*args)
      Metaname.log(*args)
    end

    # This will still raise an error. Here to show the structure
    def default_contacts
      #{admin: default_contact, registrant: default_contact, technical: default_contact}
      {}
    end

    # Use for debugging or just checking what the structure is
    def default_contact
      {
        name: 'Carl Munn',
        email_address: 'carl.munn@open2view.com',
        organisation_name: 'Open2view',
        postal_address: {
          line1: '505 Rosebank road',
          line2: '',
          city: 'Auckland',
          region: 'Avondale',
          postal_code: '1026',
          country_code: 'nz'
        },
        phone_number: {
          country_code: '64',
          area_code: '09',
          local_number: '8460220'
        },
        fax_number: nil
      }
    end

    # The original will raise an exception for exceptions and bad user input.
    # Exception for user input isn't what we need, we'll like the user to correct
    # them selves or know what went wrong.
    def catch_error
      result = begin
        {result: yield}
      rescue Metaname::JsonRpc::Error => exp

        error = Metaname::ResponseError.new(exp)
        
        error.raise! if error.important?

        {result: nil, exception: exp, error:  error.message}
      end

      log("RESPONSE: #{result.inspect}")

      result
    end
  end
end