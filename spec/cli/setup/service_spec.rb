require 'spec_helper'

describe Travis::CLI::Setup::Service do
  subject :service do
    repository = double('repository',{:slug => 'test_slug'})
    setup = double('Setup', :repository => repository)
    described_class.new(setup)
  end
  
  describe '#deploy' do
  
    subject :deploy_config do
      {'provider' => 'dummy'}
    end
    
    before do
      allow(service).to receive(:configure).and_yield(deploy_config)
      allow(service).to receive(:on).and_return(nil)
    end
  
    context 'with no existing deploy section' do
    
      it 'creates section contents without optional items' do
        service.send(:deploy, 'dummy') { |_| }
        expect(deploy_config).to include(
            'provider'      => 'dummy',
            'skip_cleanup'   => 'true'
        )
      end
    end
    
    context 'with existing deploy section' do
      it 'doesn\'t overwrite existing skip_cleanup' do
        deploy_config['skip_cleanup']='false'
        service.send(:deploy, 'dummy') { |_| }
        expect(deploy_config).to include('skip_cleanup'   => 'false')
      end

      it 'doesn\'t set skip_cleanup for v2' do
        deploy_config['edge']='true'
        service.send(:deploy, 'dummy') { |_| }
        expect(deploy_config).not_to include('skip_cleanup')
      end
      
      it 'sets skip_cleanup for explicit v1' do
        deploy_config['edge']='false'
        service.send(:deploy, 'dummy') { |_| }
        expect(deploy_config).to include('skip_cleanup'   => 'true')
      end
    end
    
  end
end
