require 'simplecov'
require 'webmock/rspec'
require 'vcr'
require 'stringio'
require 'ostruct'
require 'digest/md5'

require 'support/fake_cloudfront'
require 'support/fake_bucket'
require 'support/fake_iam'
require 'support/acceptance_setup'
require 'support/parameter_validation'

RSpec.configure do |c|
  c.extend(ParameterValidation)
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/cassettes'
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.ignore_localhost = false
  c.default_cassette_options = {record: :none}
  c.allow_http_connections_when_no_cassette = false
end

SimpleCov.start do
  add_group 'Source', 'lib'
  add_group 'Unit tests', 'spec/lester'
  add_filter '/vendor/bundle/'
end

require 'lester'
