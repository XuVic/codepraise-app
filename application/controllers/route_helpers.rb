# frozen_string_literal: true

module CodePraise
  # Web App
  class App < Roda
    def folder_name_from(request)
      path = request.remaining_path
      path.empty? ? '' : path[1..-1]
    end
  end
end
