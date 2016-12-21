$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'fakeweb'
require "metaname"

FakeWeb.allow_net_connect = false
