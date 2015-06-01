#! /usr/bin/env ruby -S rspec
dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

# So everyone else doesn't have to include this base constant.
module PuppetSpec
  FIXTURE_DIR = File.join(dir = File.expand_path(File.dirname(__FILE__)), "fixtures") unless defined?(FIXTURE_DIR)
end

require 'puppet'
require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet_spec/verbose'
require 'puppet_spec/files'
require 'puppet_spec/settings'
require 'puppet_spec/fixtures'
require 'puppet_spec/matchers'
require 'puppet_spec/database'
require 'monkey_patches/alias_should_to_must'
require 'mocha/api'

# hack to enable all the expect syntax (like allow_any_instance_of) in rspec-puppet examples
RSpec::Mocks::Syntax.enable_expect(RSpec::Puppet::ManifestMatchers)

RSpec.configure do |config|
  config.add_setting :puppet_future
  #config.puppet_future = (ENV['FUTURE_PARSER'] == 'yes' or Puppet.version.to_f >= 4.0)
  config.puppet_future = Puppet.version.to_f >= 4.0

  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter.clear
    Facter.clear_messages

    Puppet[:parser] = 'future' if ENV['FUTURE_PARSER'] == 'yes'

    RSpec::Mocks.setup
  end

  config.after :each do
    RSpec::Mocks.verify
    RSpec::Mocks.teardown
  end
end
