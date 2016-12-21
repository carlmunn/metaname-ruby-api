module Metaname
  class Client
    class << self
      attr_accessor :initialized
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

    def request(_method, *args)
      Metaname::OriginalAPI.method_missing(_method, *args)
    end

    private
    def log(*args)
      Metaname.log(*args)
    end
  end
end