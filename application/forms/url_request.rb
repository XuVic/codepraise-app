# frozen_string_literal: true

require 'dry-validation'

UrlRequest = Dry::Validation.Form do
  URL_REGEX = %r{https\:\/\/}

  required(:repo_url).filled(format?: URL_REGEX)

  configure do
    config.messages_file = File.join(__dir__, 'errors/url_request.yml')
  end
end
