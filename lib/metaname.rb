require "metaname/version"
require "metaname/original"
require "metaname/client"

module Metaname
  
  API_VERSION    = "1.2"
  PRODUCTION_URI = "https://metaname.net/api/#{API_VERSION}"
  TEST_URI       = "https://test.metaname.net/api/#{API_VERSION}"
  
  class << self
      attr_accessor :debug
  end

  def self.log(msg)
    puts "[D] #{msg}" if Metaname.debug
  end
end
