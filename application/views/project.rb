# frozen_string_literal: true

module CodePraise
  module Views
    # View object for a single repo's Github project
    class Project
      def initialize(repo)
        @repo = repo
      end

      def owner
        @repo.owner.username
      end

      def name
        @repo.name
      end

      def link_to_repo
        "/repo/#{owner}/#{name}"
      end

      def github_href
        @github_ref ||= ['https://github.com/', owner, name].join '/'
      end

      def contributors
        @repo.contributors.map(&:username).join(', ')
      end
    end
  end
end
