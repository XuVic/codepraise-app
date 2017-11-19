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
        all_repos = ReposRepresenter.new(OpenStruct.new).from_json repos_json
        projects = Views::AllProjects.new(all_repos)
        if projects.none?
          flash.now[:notice] = 'Add a Github project to get started'
        end

        view 'home', locals: { projects: projects }
      end

      routing.on 'repo' do
        routing.post do
          create_request = Forms::UrlRequest.call(routing.params)
          result = AddProject.new.call(create_request)

          if result.success?
            flash[:notice] = 'New project added!'
          else
            flash[:error] = result.value
          end

          routing.redirect '/'
        end
      end
    end
  end
end
