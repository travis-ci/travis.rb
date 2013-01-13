require 'support/fake_api'
require 'support/fake_github'
require 'support/helpers'

require 'fileutils'
require 'travis'

RSpec.configure do |c|
  c.include Helpers
  c.before do
    temp_dir = File.expand_path('../tmp', __FILE__)
    FileUtils.rm_rf(temp_dir)
    FileUtils.mkdir_p(temp_dir)
    ENV['TRAVIS_CONFIG_PATH'] = File.expand_path('travis', temp_dir)
  end
end
