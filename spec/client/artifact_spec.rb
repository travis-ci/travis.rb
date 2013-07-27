require 'spec_helper'
require 'pusher-client'
require 'travis'

describe Travis::Client::Artifact do
  let(:session) do
    Travis::Client.new
  end
  subject :log do
    session.log(3168318)
  end
  its(:job_id) { should be == 4125096 }
  its(:body) { should be == "$ export GEM=railties\n" }


  before do
    Travis::Tools::Stream::PUSHER_KEY = 'blah'
  end

  describe :stream_body do
    example do
      on_data = double
      on_finished = double

      data = {"id" => 1, "_log" => "Test log!", "number" => 1, "final" => true}
      on_data.should_receive(:call).with(data)
      on_finished.should_receive(:call)
      log.stream_body(on_data, on_finished)
      log.stream.socket['job-4125096'].dispatch('job:log', data)
      log.stream.socket['job-4125096'].dispatch('job:finished', {})
    end
  end
end
