require 'travis/cli'
require 'launchy'

module Travis
  module CLI
    class Open < RepoCommand
      description "opens a build or job in the browser"

      on('-g', '--github', 'Open the corresponding project, compare view or pull request on GitHub')
      on('-p', '--print',  'Print out the URL instead of opening it in a browser')

      def run(number = nil)
        url = url_for(number)
        if print?
          say url, "web view: %s"
        else
          Launchy.open(url)
        end
      end

      private

        def url_for(number)
          return repo_url unless number
          entity = job(number) || build(number)
          error "could not find job or build #{repository.slug}##{number}" unless entity
          github ? entity.commit.compare_url : "#{repo_url}/#{entity.class.many}/#{entity.id}"
        end

        def repo_url
          "https://#{host}/#{slug}"
        end

        def host
          github ? "github.com" : session.config['host']
        end
    end
  end
end
