# coding: utf-8
#require 'webmock/rspec'
#WebMock.disable_net_connect!
require 'vcr'

VCR.configure do |c|  
  c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/fixtures')
  c.hook_into :webmock
#  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = {
    :match_requests_on => [:method,
      VCR.request_matchers.uri_without_param(:Timestamp,:Signature)]
  }
end

require File.expand_path(File.dirname(__FILE__) + '/../lib/sevennet/api')

Sevennet::Api.configure do |options|
  options[:ApiUserId] = '97F1D0F1A115493491EF3611B61B192E'
  options[:APISecretKey] = '33C87787177D4D86BF344DF5A6AC05EE9CA45D74'
end
