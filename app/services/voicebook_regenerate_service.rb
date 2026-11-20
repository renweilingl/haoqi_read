# frozen_string_literal: true

require "net/http"
require "json"

class VoicebookRegenerateService
  API_URL = "https://voicebookapi.haoqiniu.com/api/books/regenerate_json"
  API_TOKEN = "hb regenerate2024secret"

  def self.call(book_id)
    new(book_id).call
  end

  def initialize(book_id)
    @book_id = book_id
  end

  def call
    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(api_token: API_TOKEN, book_id: @book_id)

    response = http.request(request)
    result = JSON.parse(response.body) rescue { "error" => "JSON parse error" }

    {
      success: response.code.start_with?("2"),
      code: response.code,
      body: result
    }
  rescue StandardError => e
    { success: false, error: e.message }
  end
end
