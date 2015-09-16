require 'travis/cli/setup'

module Travis
  module CLI
    class Setup
      class PyPI < Service
        description "automatic deployment to PyPI"

        def run
          deploy 'pypi', 'release' do |config|
            config['user']     ||= ask("Username: ").to_s
            config['password'] ||= ask("Password: ") { |q| q.echo = "*" }.to_s

            on("release only tagged commits? ", config, 'tags' => true)
            # the default of pypi `setup.py build` is the `sdist`
            on("deploy as wheel file too? ", config, 'distributions' => 'sdist bdist_wheel')
          end
        end
      end
    end
  end
end
