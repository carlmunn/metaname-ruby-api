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
      "#{@exception.message}, #{@exception.data}"
    end

    # re-raise
    def raise!
      raise @exception, message
    end

    # The number range supplied is user error the rest isn't'
    def important?
      !(5..21).include?(code) || zero_balance?
    end

    def zero_balance?
      code == 11
    end

    def code
      @exception.code.abs
    end
  end
end