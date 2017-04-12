require "metaname/version"
require "metaname/error"
require "metaname/original"
require "metaname/client"

module Metaname
  
  API_VERSION    = "1.1"
  PRODUCTION_URI = "https://metaname.net/api/#{API_VERSION}"
  TEST_URI       = "https://test.metaname.net/api/#{API_VERSION}"
  
  class << self
      attr_accessor :debug
  end

  def self.uri_for(env)
    env == 'production' ? PRODUCTION_URI : TEST_URI
  end

  def self.log(msg)
    puts "[D] #{msg}" if Metaname.debug
  end
end
