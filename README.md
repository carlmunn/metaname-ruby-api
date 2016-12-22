# Metaname Wrapper

This wraps around the original code offered by Metaname (v1.2). Their code was
three basic ruby files, which one of them was `require`d to get the class
for usage. I wanted a gem to detach the code and help with maintainability. The Gem
will wrap their code and give methods to access the original.
The Gem also tests by faking the HTTP responses (RSpec)

[Metaname API link](https://metaname.net/api)

## Useage

```
options = {
    uri: Metaname::TEST_URI,
    account: {reference: STRING, api_key: STRING}
}

client = Metaname::Client.new(options)
client.request(:account_balance)
=> "0.0"
```

Verbose output for debugging use

```
Metaname.debug = true

# Debug the original request/response
Metaname::StdoutTranscript.debug = true
```


## TODO

Add a timeout exception if something happens to the connection