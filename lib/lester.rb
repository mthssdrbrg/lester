require 'acme-client'
require 'aws-sdk'
require 'json'
require 'pathname'

module Lester
  Error = Class.new(StandardError)
  RequestVerificationError = Class.new(Error)
  RequiredArgumentError = Class.new(Error)
  UnkownCommandError = Class.new(Error)
  UnknownKeyFormatError = Class.new(Error)

  KEY_NAME = 'private_key.pem'.freeze
end

require 'lester/authenticator'
require 'lester/cli'
require 'lester/command'
require 'lester/factory'
require 'lester/private_key'
require 'lester/uploader'
require 'lester/store'
