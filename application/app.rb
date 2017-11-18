# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module CodePraise
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'presentation/views'
    plugin :assets, css: 'style.css', path: 'presentation/assets'
    plugin :flash

    use Rack::Session::Cookie, secret: config.SESSION_SECRET

    route do |routing|
      routing.assets

      # GET / request
      routing.root do
        repos_json = ApiGateway.new.all_repos
        all_repos = CodePraise::ReposRepresenter.new(OpenStruct.new)
                                                .from_json repos_json
        if all_repos.repos.count == 0
          flash.now[:notice] = 'Add a Github project to get started'
        end

        view 'home', locals: { repos: all_repos.repos }
      end

      routing.on 'repo' do
        routing.post do
          create_request = Forms::UrlRequest.call(routing.params)
          if create_request.success?
            ownername, reponame = create_request[:url].split('/')[-2..-1]
            begin
              ApiGateway.new.create_repo(ownername, reponame)
              flash[:notice] = 'New Github project added!'
            rescue StandardError => error
              flash[:error] = error.to_s
            end
          else
            flash[:error] = create_request.errors.values.join('; ')
          end
          routing.redirect '/'
        end
      end
    end
  end
end
