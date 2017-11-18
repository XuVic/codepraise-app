# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Homepage' do
  before do
    unless @browser
      CodePraise::ApiGateway.new.delete_all_repos
      @headless = Headless.new
      @browser = Watir::Browser.new
      @browser.goto 'http://localhost:9292'
    end
  end

  after do
    @browser.close
    @headless.destroy
  end

  describe 'Empty Homepage' do
    it '(HAPPY) should see no content' do
      _(@browser.h1(id: 'main_header').text).must_equal 'CodePraise'
      _(@browser.text_field(name: 'url').visible?).must_equal true
      _(@browser.div(id: 'flash_bar_success').visible?).must_equal true
      _(@browser.div(id: 'flash_bar_success').text).must_include 'Add'
      _(@browser.text_field(id: 'url_input').visible?).must_equal true
      _(@browser.button(id: 'repo_form_submit').visible?).must_equal true
    end
  end

  describe 'Add new project' do
    it '(BAD) should not accept incorrect URL' do
      @browser.text_field(id: 'url_input').set('http://bad_url')
      @browser.button(id: 'repo_form_submit').click

      _(@browser.div(id: 'flash_bar_danger').text).must_include 'Invalid'
    end

    it '(SAD) should not accept duplicate repo' do
      @browser.text_field(id: 'url_input').set('https://github.com/soumyaray/YPBT-app')
      @browser.button(id: 'repo_form_submit').click
      @browser.text_field(id: 'url_input').set('https://github.com/soumyaray/YPBT-app')
      @browser.button(id: 'repo_form_submit').click

      _(@browser.div(id: 'flash_bar_danger').text).must_include 'already loaded'
    end

    it '(HAPPY) should add valid URL' do
      @browser.text_field(id: 'url_input').set('https://github.com/soumyaray/YPBT-app')
      @browser.button(id: 'repo_form_submit').click
      _(@browser.div(id: 'flash_bar_success').text).must_include 'added'
      _(@browser.div(id: 'flash_bar_danger').exists?).must_equal false

      table = @browser.table(id: 'repos_table')
      row = table.rows[1]
      _(table.rows.count).must_equal 2
      _(row.td(id: 'td_owner').text).must_equal 'soumyaray'
      _(row.td(id: 'td_repo_name').text).must_equal 'YPBT-app'
      _(row.td(id: 'td_link').text).include? 'https'
      _(row.td(id: 'td_contributors').text.split(', ').count).must_equal 3
    end
  end
end
