module Metaname
  # This class handles the Metaname errors. checks,
  # re-raises with a better message etc
  class ResponseError

    ERRORS = {
      # Exceptions
      '1':  "Authentication failed",
      
      # Nothing specified in API documentation
      '2':  "",
      '3':  "",

      # Result Errors
      '4':	"Invalid domain name",
      '5':	"Domain name not found",
      '6':	"No account default contact",
      '7':	"Invalid term",
      '8':	"Invalid contact",
      '9':	"Invalid name server",
      '10': "Invalid URI",
      '11':	"Transaction declined",
      '12':	"DNS hosting not enabled",
      '13':	"HTTP redirection is enabled",
      '14':	"Domain name already exist",
      '15':	"Invalid UDAI",
      '16':	"Invalid DNS record",
      '17':	"DNS record not found",
      '18':	"Upstream error",
      '19': "Invalid name server",
      '20':	"Invalid data",
      '21':	"Invalid zone name",

      # Exceptions
      '32700': "Parse error",
      '32600': "Invalid Request",
      '32601': "Method not found",
      '32602': "Invalid params",
      '32603': "Internal error"
    }

    def initialize(exception)
      @exception = exception

      # The exception has the error message already, the table visibly helps
      #msg = ERRORS[exception.code.abs.to_s]
    end

    def message
      [@exception.message, @exception.data].reject{ |v| _blank?(v) }.join(', ')
    end

    # re-raise
    def raise!
      raise @exception, message
    end

    # The number range supplied is user error the rest isn't'
    def important?
      !safe_error_codes.include?(code)
    end

    # 11 = zerp balance
    # 99 = domain already taken
    def safe_error_codes
      (4..21).to_a + [99] - [11]
    end

    def code
      @exception.code.abs
    end

    def to_hash
      {result: nil, exception: self.inspect, error:  self.message, code: self.code}
    end

  private
    def _blank?(val)
      [nil, ""].include?(val)
    end
  end
end