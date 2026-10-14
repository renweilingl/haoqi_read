class BookImportJob < ApplicationJob
  queue_as :zheli_high

  def perform(book_id)
    if Rails.env.production?
      url = "https://api.zheliyuedu.cn/api/books/import"

      data = {uuid: AppUser.first.uuid, id: book_id}
      res = HTTParty.post(url, body: data.to_json, headers: {'Content-Type' => 'application/json'}).body
      logger.info "BookImportJob import book_id: #{book_id}, res: #{res}"
    end
  end

end
