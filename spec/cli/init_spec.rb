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
    run_cli('init', 'fakelanguage', '--skip-enable', '-r', 'travis-ci/travis.rb').should_not be_success
    stderr.should be == "unknown language fakelanguage\n"
  end

  shared_examples_for 'travis init' do |language|
    example "travis init #{language} (empty directory)" do
      File.exist?('.travis.yml').should be false
      run_cli('init', language, '--skip-enable', '-r', 'travis-ci/travis.rb').should be_success
      stdout.should be == ".travis.yml file created!\n"
      File.exist?('.travis.yml').should be true
      File.read('.travis.yml').should include("language: #{language}")
    end

    example "travis init #{language} (.travis.yml already exists, using --force)" do
      File.open(".travis.yml", "w") { |f| f << "old file" }
      run_cli('init', language, '--force', '--skip-enable', '-r', 'travis-ci/travis.rb').should be_success
      stdout.should be == ".travis.yml file created!\n"
      File.read(".travis.yml").should_not be == "old file"
    end

    example "travis init #{language} (.travis.yml already exists, not using --force)" do
      File.open(".travis.yml", "w") { |f| f << "old file" }
      run_cli('init', language, '--skip-enable', '-r', 'travis-ci/travis.rb').should_not be_success
      stderr.should be == ".travis.yml already exists, use --force to override\n"
      File.read('.travis.yml').should be == "old file"
    end
  end

  describe 'travis init c' do
    it_should_behave_like 'travis init', 'c'

    let :result do
      run_cli('init', 'c', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('compiler')
      result['compiler'].should include('clang')
      result['compiler'].should include('gcc')
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
      result.should include('compiler')
      result['compiler'].should include('clang')
      result['compiler'].should include('gcc')
    end
  end

  describe 'travis init erlang' do
    it_should_behave_like 'travis init', 'erlang'

    let :result do
      run_cli('init', 'erlang', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('otp_release')
      result['otp_release'].should include('R16B')
    end
  end

  describe 'travis init go' do
    it_should_behave_like 'travis init', 'go'

    let :result do
      run_cli('init', 'go', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('go')
      result['go'].should include('1.0')
      result['go'].should include('1.3')
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
      result.should include('jdk')
      result['jdk'].should include('oraclejdk7')
      result['jdk'].should include('openjdk6')
    end
  end

  describe 'travis init node_js' do
    it_should_behave_like 'travis init', 'node_js'

    let :result do
      run_cli('init', 'node_js', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('node_js')
      result['node_js'].should include('stable')
      result['node_js'].should include('6')
      result['node_js'].should include('4')
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
      result.should include('perl')
      result['perl'].should include('5.16')
      result['perl'].should include('5.14')
    end
  end

  describe 'travis init php' do
    it_should_behave_like 'travis init', 'php'

    let :result do
      run_cli('init', 'php', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('php')
      result['php'].should include('5.5')
      result['php'].should include('5.4')
    end
  end

  describe 'travis init python' do
    it_should_behave_like 'travis init', 'python'

    let :result do
      run_cli('init', 'python', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('python')
      result['python'].should include('2.7')
      result['python'].should include('3.3')
    end
  end

  describe 'travis init ruby' do
    it_should_behave_like 'travis init', 'ruby'

    let :result do
      run_cli('init', 'ruby', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('rvm')
      result['rvm'].should     include('1.9.3')
      result['rvm'].should     include('2.0.0')
      result['rvm'].should_not include('1.8.7')
    end
  end

  describe 'travis init scala' do
    it_should_behave_like 'travis init', 'scala'

    let :result do
      run_cli('init', 'scala', '--skip-enable', '-r', 'travis-ci/travis.rb')
      YAML.load_file('.travis.yml')
    end

    it 'sets compiler' do
      result.should include('scala')
      result['scala'].should include('2.10.1')
      result['scala'].should include('2.9.3')
    end
  end
end
