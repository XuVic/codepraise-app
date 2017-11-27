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
    it '(HAPPY) should see no content' do
      skip
      # GIVEN: user is on the home page without any projects
      @browser.goto homepage

      # THEN: user should see basic headers, no projects and a welcome message
      _(@browser.h1(id: 'main_header').text).must_equal 'CodePraise'
      _(@browser.text_field(name: 'url').visible?).must_equal true
      _(@browser.text_field(id: 'url_input').visible?).must_equal true
      _(@browser.button(id: 'repo_form_submit').visible?).must_equal true
      _(@browser.table(id: 'repos_table').exists?).must_equal false

      _(@browser.div(id: 'flash_bar_success').visible?).must_equal true
      _(@browser.div(id: 'flash_bar_success').text).must_include 'Add'
    end
  end

  describe 'Adding new projects' do
    include PageObject::PageFactory

    it '(HAPPY) should add project with valid URL' do
      skip
      # GIVEN: user is on the home page
      @browser.goto homepage

      # WHEN: user enters a valid URL for a new repo
      @browser.text_field(id: 'url_input').set('https://github.com/soumyaray/YPBT-app')
      @browser.button(id: 'repo_form_submit').click
      _(@browser.div(id: 'flash_bar_success').text).must_include 'added'
      _(@browser.div(id: 'flash_bar_danger').exists?).must_equal false

      # THEN: user should see their new repo listed in a table
      table = @browser.table(id: 'repos_table')
      _(@browser.table(id: 'repos_table').exists?).must_equal true

      row = table.rows[1]
      _(table.rows.count).must_equal 2
      _(row.td(id: 'td_owner').text).must_equal 'soumyaray'
      _(row.td(id: 'td_repo_name').text).must_equal 'YPBT-app'
      _(row.td(id: 'td_link').text).include? 'https'
      _(row.td(id: 'td_contributors').text.split(', ').count).must_equal 3
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

    it '(HAPPY) should be able to add multiple valid projects' do
      skip
      # GIVEN: user is on the home page
      @browser.goto homepage

      # WHEN: user enters a valid URL for two new repos
      @browser.text_field(id: 'url_input').set('https://github.com/soumyaray/YPBT-app')
      @browser.button(id: 'repo_form_submit').click

      @browser.text_field(id: 'url_input').set('https://github.com/Mew-Traveler/Time_Traveler-API')
      @browser.button(id: 'repo_form_submit').click

      # THEN: user should see both new repos listed in a table
      table = @browser.table(id: 'repos_table')
      _(@browser.table(id: 'repos_table').exists?).must_equal true

      _(table.rows.count).must_equal 3

      row = table.rows[1]
      _(row.td(id: 'td_owner').text).must_equal 'soumyaray'
      _(row.td(id: 'td_repo_name').text).must_equal 'YPBT-app'
      _(row.td(id: 'td_link').text).include? 'https'
      _(row.td(id: 'td_contributors').text.split(', ').count).must_equal 3

      row = table.rows[2]
      _(row.td(id: 'td_owner').text).must_equal 'Mew-Traveler'
      _(row.td(id: 'td_repo_name').text).must_equal 'Time_Traveler-API'
      _(row.td(id: 'td_link').text).include? 'https'
      _(row.td(id: 'td_contributors').text.split(', ').count).must_equal 3
    end

    it '(BAD) should not accept incorrect URL' do
      skip
      # GIVEN: user is on the home page
      @browser.goto homepage

      # WHEN: user enters an invalid URL
      @browser.text_field(id: 'url_input').set('http://bad_url')
      @browser.button(id: 'repo_form_submit').click

      # THEN: user should see an error alert and no table of repos
      _(@browser.div(id: 'flash_bar_danger').text).must_include 'Invalid'
      _(@browser.table(id: 'repos_table').exists?).must_equal false
    end

    it '(SAD) should not accept duplicate repo' do
      skip
      # GIVEN: user is on the home page
      @browser.goto homepage

      # WHEN: user enters a URL that was previously loaded
      @browser.text_field(id: 'url_input').set('https://github.com/soumyaray/YPBT-app')
      @browser.button(id: 'repo_form_submit').click
      @browser.text_field(id: 'url_input').set('https://github.com/soumyaray/YPBT-app')
      @browser.button(id: 'repo_form_submit').click

      # THEN: user should should see an error alert and the existing repo
      _(@browser.div(id: 'flash_bar_danger').text).must_include 'already loaded'
      _(@browser.table(id: 'repos_table').visible?).must_equal true
      _(@browser.table(id: 'repos_table').rows.count).must_equal 2
    end
  end
end
