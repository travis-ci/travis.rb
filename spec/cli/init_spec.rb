require 'spec_helper'

describe Travis::CLI::Init do
  old_path = Dir.pwd
  tmp_path = File.expand_path('travis-spec-init', Dir.tmpdir)

  before(:each) do
    FileUtils.mkdir_p(tmp_path)
    Dir.chdir(tmp_path)
    FileUtils.rm('.travis.yml') if File.exist?('.travis.yml')
  end

  after(:each) do
    Dir.chdir(old_path)
  end

  example "travis init fakelanguage" do
    expect(run_cli('init', 'fakelanguage', '--skip-enable', '-r', 'travis-ci/travis.rb')).not_to be_success
    expect(stderr).to eq("unknown language fakelanguage\n")
  end

  shared_examples_for 'travis init' do |language|
    example "travis init #{language} (empty directory)" do
      expect(File.exist?('.travis.yml')).to be_falsey
      expect(run_cli('init', language, '--skip-enable', '-r', 'travis-ci/travis.rb')).to be_success
      expect(stdout).to eq(".travis.yml file created!\n")
      expect(File.exist?('.travis.yml')).to be_truthy
      expect(File.read('.travis.yml')).to include("language: #{language}")
    end

    example "travis init #{language} (.travis.yml already exists, using --force)" do
      File.open(".travis.yml", "w") { |f| f << "old file" }
      expect(run_cli('init', language, '--force', '--skip-enable', '-r', 'travis-ci/travis.rb')).to be_success
      expect(stdout).to eq(".travis.yml file created!\n")
      expect(File.read(".travis.yml")).not_to eq("old file")
    end

    example "travis init #{language} (.travis.yml already exists, not using --force)" do
      File.open(".travis.yml", "w") { |f| f << "old file" }
      expect(run_cli('init', language, '--skip-enable', '-r', 'travis-ci/travis.rb')).not_to be_success
      expect(stderr).to eq(".travis.yml already exists, use --force to override\n")
      expect(File.read('.travis.yml')).to eq("old file")
    end
  end

  describe 'travis init c' do
    it_should_behave_like 'travis init', 'c'

    let :result do
      run_cli('init', 'c', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('compiler')
      expect(result['compiler']).to include('clang')
      expect(result['compiler']).to include('gcc')
    end
  end

  describe 'travis init clojure' do
    it_should_behave_like 'travis init', 'clojure'
  end

  describe 'travis init cpp' do
    it_should_behave_like 'travis init', 'cpp'

    let :result do
      run_cli('init', 'cpp', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('compiler')
      expect(result['compiler']).to include('clang')
      expect(result['compiler']).to include('gcc')
    end
  end

  describe 'travis init erlang' do
    it_should_behave_like 'travis init', 'erlang'

    let :result do
      run_cli('init', 'erlang', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('otp_release')
      expect(result['otp_release']).to include('R16B')
    end
  end

  describe 'travis init go' do
    it_should_behave_like 'travis init', 'go'

    let :result do
      run_cli('init', 'go', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('go')
      expect(result['go']).to include('1.0')
      expect(result['go']).to include('1.3')
    end
  end

  describe 'travis init groovy' do
    it_should_behave_like 'travis init', 'groovy'
  end

  describe 'travis init haskell' do
    it_should_behave_like 'travis init', 'haskell'
  end

  describe 'travis init java' do
    it_should_behave_like 'travis init', 'java'

    let :result do
      run_cli('init', 'java', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('jdk')
      expect(result['jdk']).to include('oraclejdk7')
      expect(result['jdk']).to include('openjdk6')
    end
  end

  describe 'travis init node_js' do
    it_should_behave_like 'travis init', 'node_js'

    let :result do
      run_cli('init', 'node_js', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('node_js')
      expect(result['node_js']).to include('0.11')
      expect(result['node_js']).to include('0.10')
    end
  end

  describe 'travis init objective-c' do
    it_should_behave_like 'travis init', 'objective-c'
  end

  describe 'travis init perl' do
    it_should_behave_like 'travis init', 'perl'

    let :result do
      run_cli('init', 'perl', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('perl')
      expect(result['perl']).to include('5.16')
      expect(result['perl']).to include('5.14')
    end
  end

  describe 'travis init php' do
    it_should_behave_like 'travis init', 'php'

    let :result do
      run_cli('init', 'php', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('php')
      expect(result['php']).to include('5.5')
      expect(result['php']).to include('5.4')
    end
  end

  describe 'travis init python' do
    it_should_behave_like 'travis init', 'python'

    let :result do
      run_cli('init', 'python', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('python')
      expect(result['python']).to include('2.7')
      expect(result['python']).to include('3.3')
    end
  end

  describe 'travis init ruby' do
    it_should_behave_like 'travis init', 'ruby'

    let :result do
      run_cli('init', 'ruby', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('rvm')
      expect(result['rvm']).to     include('1.9.3')
      expect(result['rvm']).to     include('2.0.0')
      expect(result['rvm']).not_to include('1.8.7')
    end
  end

  describe 'travis init scala' do
    it_should_behave_like 'travis init', 'scala'

    let :result do
      run_cli('init', 'scala', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      expect(result).to include('scala')
      expect(result['scala']).to include('2.10.1')
      expect(result['scala']).to include('2.9.3')
    end
  end
end
