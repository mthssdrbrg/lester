require 'acme-client'
require 'aws-sdk'
require 'json'
require 'pathname'
require 'logger'

module Lester
  Error = Class.new(StandardError)
  RequestVerificationError = Class.new(Error)
  RequiredArgumentError = Class.new(Error)
  UnkownCommandError = Class.new(Error)
  UnknownKeyFormatError = Class.new(Error)
end

require 'lester/authenticator'
require 'lester/cli'
require 'lester/command'
require 'lester/factory'
require 'lester/logger'
require 'lester/private_key'
require 'lester/s3_store'
require 'lester/uploader'
