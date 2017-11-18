# frozen_string_literal: true

require 'dry-validation'

module CodePraise
  module Forms
    UrlRequest = Dry::Validation.Form do
      URL_REGEX = %r{(http[s]?)\:\/\/github\.com\/.*\/.*(?<!git)$}

      required(:url).filled(format?: URL_REGEX)

      configure do
        config.messages_file = File.join(__dir__, 'errors/url_request.yml')
      end
    end
  end
end
