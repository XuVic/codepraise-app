# frozen_string_literal: true

require 'http'

module CodePraise
  class ApiGateway
    def initialize(config = CodePraise::App.config)
      @config = config
    end

    def all_repos
      call_api(:get, 'repo')
    end

    def repo(username, reponame)
      call_api(:get, ['repo', username, reponame])
    end

    def create_repo(username, reponame)
      call_api(:post, ['repo', username, reponame])
    end

    def call_api(method, resources)
      url_route = [@config.api_url, resources].flatten.join'/'

      result = HTTP.send(method, url_route)
      raise(result.to_s) if result.code >= 300
      result.to_s
    end
  end
end