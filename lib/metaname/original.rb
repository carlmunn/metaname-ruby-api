# Using this as a reference, it's not going to be required
# There is some code changes for testing purposes and syntax changes
# Original can be found at https://test.metaname.net/api/ruby
module Metaname

  require "date"
  require "json"
  require "net/https"

  class StdoutTranscript

    class << self
      attr_accessor :debug
    end
    
    def is_recorded
      false
    end

    # CHANGED:
    def self.next_message_id
      sleep 1 # to ensure uniqueness of the below id
      Time.now.strftime "%Y%m%d%H%M%S"
    end

    def request_made request_as_json
      self.class.log("  >> #{request_as_json}")
    end

    def response_received response_as_json
      self.class.log("  << #{response_as_json}")
    end

    def self.log(msg)
      puts "[D] #{msg}" if self.debug
    end
  end

  module JsonRpc

    class Error < StandardError
      attr_reader :code, :message, :data

      def initialize code, message, data = nil
        @code = code
        @message = message
        @data = data
      end
    end

    class Client

      JSON_RPC_VERSION = "2.0"

      def initialize endpoint
        @endpoint = endpoint
      end

      def transcript
        @transcript ||= StdoutTranscript.new
      end

      attr_writer :transcript

      def invoke_method method_name, *args

        request = {
          jsonrpc: JSON_RPC_VERSION,
          id:      StdoutTranscript.next_message_id,
          method:  method_name,
          params:  args
        }

        request_as_json = request.to_json

        transcript.request_made request_as_json

        if transcript.is_recorded
          response_as_json = transcript.next_response
        else
          # Make the HTTP request
          url = URI.parse @endpoint

          http_request              = Net::HTTP::Post.new  url.path
          http_request.content_type = "application/json"
          http_request.body         = request_as_json

          server             = Net::HTTP.new  url.host, url.port
          server.use_ssl     = "https" == url.scheme
 
          # Curious about this security skipping
          server.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http_response      = server.request  http_request

          case http_response
          when Net::HTTPSuccess
            response_as_json = http_response.body
          else
            raise StandardError.new  http_response.inspect
          end
        end

        transcript.response_received  response_as_json

        # Check that what comes back from the server is JSON:
        begin
          response = JSON.parse response_as_json
        rescue JSON::ParserError
          raise Error.new -32603, "Bad JSON received"
        end

        # Check that the ID of the response matches the ID of the request:
        if not transcript.is_recorded and response["id"] != request[:id]
          raise Error.new -32603, "Unexpected message ID"
        end

        # If there was an error on the server..
        if er = response["error"]
          raise Error.new  er["code"], er["message"], er["data"]
        elsif ! response.has_key? "result"
          raise Error.new  -32603, "Neither result nor error present"
        end

        response["result"]
      end
    end
  end

  # CHANGED:
  class OriginalAPI

    class << self

      #  uri:      Use https://test.metaname.net/api/1.2 for Test or
      #            https://metaname.net/api/1.2 for Production
      #  account:  A map with keys:
      #              :reference: Four-digit account reference
      #              :api_key:   The API key
      #
      def initialize! params
        @remote = JsonRpc::Client.new  params[:uri]
        @account_reference = params[:account][:reference]
        @api_key =           params[:account][:api_key]
      end

      def method_missing method_name, *args
        args.unshift @account_reference, @api_key
        @remote.invoke_method  method_name, *args
      end

    end # of class methods
  end
end

=begin

  params = {
    :uri => "https://test.metaname.net/api/1.1",
    :account => {
      :reference => "j4kk",
      :api_key => "kzfEfpxwzcCJlYnids8se03o24htCWvB9kDCkhKRriA5ENQK",
    },
  }

  Metaname.initialize! params


  puts Metaname.account_balance.inspect
=end