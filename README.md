# Metaname Wrapper

This wraps around the original code offered by Metaname (v1.2). Their code was
three basic ruby files, which one of them was `require`d to get the class
for usage. I wanted a gem to detach the code and help with maintainability. The Gem
will wrap their code and give methods to access the original.
The Gem also tests by faking the HTTP responses (RSpec)

[Metaname API link](https://metaname.net/api)

## About the Metaname service

[Metaname](https://metaname.net/) is a service that offers the ability to purchase domain names using their API.
More information can be found at their website

## Usage

```ruby
options = {
    uri: Metaname::TEST_URI,
    account: {reference: STRING, api_key: STRING}
}

client = Metaname::Client.new(options)
client.request(:account_balance)
=> "0.0"
```

Verbose output for debugging use

```ruby
Metaname.debug = true

# Debug the original request/response
Metaname::StdoutTranscript.debug = true
```

## Tests

I've written tests based on intercepting HTTP communication from their test version API. As the results are hard coded the gem
won't pick up any issues if their API changes.

When testing I had to get Neil Stockbridge from Metaname support (support@metaname.co.nz) to add credit on the test account for me.

## TODO

Add a time out exception if something happens to the connection

interceptor doc