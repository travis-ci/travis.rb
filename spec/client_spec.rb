require 'spec_helper'

describe Travis::Client do
  its(:new) { should be_a(Travis::Client::Session) }
end
