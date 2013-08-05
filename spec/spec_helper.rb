# coding: utf-8
require 'webmock/rspec'
WebMock.disable_net_connect!
require 'vcr'

VCR.configure do |c|  
  c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/fixtures')
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = {
    :match_requests_on => [:method,
      VCR.request_matchers.uri_without_param(:Timestamp,:Signature)]
  }
end

require File.expand_path(File.dirname(__FILE__) + '/../lib/sevennet/api')

Sevennet::Api.configure do |options|
  options[:ApiUserId] = 'your api user id'
  options[:APISecretKey] = 'your api secret key'
end
