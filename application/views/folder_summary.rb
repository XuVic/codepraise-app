# frozen_string_literal: true

module CodePraise
  module Views
    class AssetContribution
      attr_reader :name, :contributions

      def initialize(asset, base_path)
        @base_path = base_path
        @name = asset[0]
        @contributions = asset[1].map.each_with_object({}) do |c, total_c|
          c_view = ContributionView.new(c)
          total_c[c_view.contributor] = c_view.count
        end
      end

      def link
        ''
      end

      # must define #eql? and #hash to judge equality of Ruby objects
      def <=>(other)
        name <=> other.name
      end
    end

    class SubfolderContribution < AssetContribution
      def name
        super
      end

      def link
        [@base_path, name].join '/'
      end
    end

    # Get contributor and count from contribution row:
    #   ["<tearsgundam@gmail.com>", {"name"=>"Yuan Yu", "count"=>63}]
    class ContributionView
      attr_reader :contributor, :count

      def initialize(contribution)
        @contributor ||= ContributorView.new(contribution)
        @count = contribution[1]['count']
      end
    end

    # Extract contributor from contribution row:
    #   ["<tearsgundam@gmail.com>", {"name"=>"Yuan Yu", "count"=>63}]
    class ContributorView
      attr_reader :name, :email

      def initialize(contribution)
        @name = contribution[1]['name']
        @email = contribution[0]
      end

      # must define #eql? and #hash to judge equality of Ruby objects
      def eql?(other)
        (name == other.name) && (email == other.email)
      end

      def hash
        [name, email].join.hash
      end
    end

    # USAGE:
    # app.reload!
    # cd CodePraise
    # json = ApiGateway.new.folder_summary('soumyaray', 'YPBT-app', '').message
    # summary = FolderSummaryRepresenter.new(OpenStruct.new).from_json json
    # s = Views::FolderSummaryView.new(summary)
    # s.contributors
    # s.subfolders.first
    class FolderSummaryView
      def initialize(summary, request_path)
        @summary = summary
        @request_path = request_path
      end

      def name
        @summary.folder_name
      end

      def base_folder
        all_folders[0]
      end

      def subfolders
        all_folders[1..-1] # remove blank base folder
      end

      def base_files
        @summary.base_files.map { |asset| AssetContribution.new(asset, @request_path) }
      end

      def contributors
        @contributors ||=
          uniq_contributors(@summary.subfolders) | uniq_contributors(@summary.base_files)
      end

      private

      def uniq_contributors(asset_summary)
        asset_summary.values.map do |contributions|
          contributions.map { |contribution| ContributorView.new(contribution) }
        end.flatten.uniq
      end

      # sort all folders; base folder '' at index 0
      def all_folders
        @all_folders ||= @summary.subfolders.map do |asset|
          SubfolderContribution.new(asset, @request_path)
        end.sort
      end
    end
  end
end