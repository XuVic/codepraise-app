# frozen_string_literal: true

module CodePraise
  module Views
    # View object for colelction of Github projects
    class AllProjects
      def initialize(all_repos)
        @all_repos = all_repos
      end

      def none?
        @all_repos.repos.none?
      end

      def any?
        @all_repos.repos.any?
      end

      def collection
        @all_repos.repos.map { |repo| Project.new(repo) }
      end
    end
  end
end
