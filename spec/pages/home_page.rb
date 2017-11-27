# frozen_string_literal: true

class HomePage
  include PageObject

  page_url CodePraise::App.config.APP_URL

  text_field(:url_input, id: 'url_input')
  button(:add_button, id: 'repo_form_submit')
  table(:repos_table, id: 'repos_table')

  indexed_property(
    :repos,
    [
      [:span, :owner,        { id: 'repo[%s].owner' }],
      [:a,    :name_link,    { id: 'repo[%s].link' }],
      [:a,    :gh_url,       { id: 'repo[%s].gh_url' }],
      [:span, :contributors, { id: 'repo[%s].contributors' }]
    ]
  )

  def first_repo
    repos[0]
  end

  def second_repo
    repos[1]
  end

  def repos_listed_count
    repos_table_element.rows - 1
  end

  def add_new_repo(github_url)
    self.url_input = github_url
    self.add_button
  end

  def listed_repo(repo)
    {
      owner: repo.owner,
      name: repo.name_link_element.text,
      gh_url: repo.gh_url_element.text,
      num_contributors: repo.contributors.split(',').count
    }
  end
end