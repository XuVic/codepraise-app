# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Homepage' do
  before do
    unless @browser
      CodePraise::ApiGateway.new.delete_all_repos
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
  end

  after do
    @browser.close
    @headless.destroy
  end

  describe 'Empty Homepage' do
    include PageObject::PageFactory
    it '(HAPPY) should see no content' do
      # GIVEN: user is on the home page without any projects
      visit HomePage do |page|
        # THEN: user should see basic headers, no projects and a welcome message
        _(page.title_heading).must_equal 'CodePraise'
        _(page.url_input_element.visible?).must_equal true
        _(page.add_button_element.visible?).must_equal true
        _(page.repos_table_element.exists?).must_equal false
        _(page.success_message).must_include 'Add'
        _(page.warning_message_element.exists?).must_equal false
      end
    end
  end

  describe 'Adding new projects' do
    include PageObject::PageFactory

    it '(HAPPY) should add project with valid URL' do
      # GIVEN: user is on the home page
      visit HomePage do |page|
        # WHEN: user enters a valid URL for a new repo
        page.add_new_repo 'https://github.com/soumyaray/YPBT-app'

        # THEN: user should see their new repo listed in a table
        _(page.success_message).must_include 'added'
        _(page.repos_table_element.visible?).must_equal true
        _(page.listed_repo(page.first_repo)).must_equal(
          owner: 'soumyaray',
          name: 'YPBT-app',
          gh_url: 'https://github.com/soumyaray/YPBT-app',
          num_contributors: 3
        )
      end
    end

    it 'HAPPY: should be add multiple projects' do
      # GIVEN: on the homepage
      visit HomePage do |page|
        # WHEN: user enters a valid URL for two new repos
        page.add_new_repo 'https://github.com/soumyaray/YPBT-app'
        page.add_new_repo 'https://github.com/Mew-Traveler/Time_Traveler-API'

        # THEN: user should see both new repos listed in a table
        _(page.repos_table_element.exists?).must_equal true
        _(page.repos_listed_count).must_equal 2

        _(page.listed_repo(page.first_repo)).must_equal(
          owner: 'soumyaray',
          name: 'YPBT-app',
          gh_url: 'https://github.com/soumyaray/YPBT-app',
          num_contributors: 3
        )

        _(page.listed_repo(page.second_repo)).must_equal(
          owner: 'Mew-Traveler',
          name: 'Time_Traveler-API',
          gh_url: 'https://github.com/Mew-Traveler/Time_Traveler-API',
          num_contributors: 3
        )
      end
    end

    it '(BAD) should not accept incorrect URL' do
      # GIVEN: user is on the home page
      visit HomePage do |page|
        # WHEN: user enters an invalid URL
        page.add_new_repo 'http://bad_url'
        # THEN: user should see an error alert and no table of repos
        _(page.warning_message).must_include 'Invalid'
        _(page.repos_table_element.exists?).must_equal false
      end
    end

    it '(SAD) should not accept duplicate repo' do
      # GIVEN: user is on the home page
      visit HomePage do |page|
        # WHEN: user enters a URL that was previously loaded
        page.add_new_repo 'https://github.com/soumyaray/YPBT-app'
        page.add_new_repo 'https://github.com/soumyaray/YPBT-app'
        # THEN: user should should see an error message and the existing repo
        _(page.warning_message).must_include 'already'
        _(page.repos_listed_count).must_equal 1
      end
    end
  end
end
