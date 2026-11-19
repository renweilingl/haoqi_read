# frozen_string_literal: true

# 绘本（picture_book）逐页数据：页图、OCR 文本、朗读窗口与行/token。
# 一本绘本的完整渲染结果同时会导出为 book.json/dict.json 存 OSS，这里是可查询的真相。
#
# 注意：此表与 haoqi_voicebook 项目共享，生产环境由 haiqi_voicebook 写入，
# haoqi_read 后台用于查询和编辑字幕数据。
class PictureBookPage < ApplicationRecord
  belongs_to :book

  validates :page_number, presence: true, uniqueness: { scope: :book_id }

  scope :ordered, -> { order(page_number: :asc) }

  # lines 列虽是 json 类型，但 haoqi_voicebook 写进来的是「JSON 字符串」，
  # ActiveRecord 解一层后仍是 String，需要再解一层；也兼容直接存对象/数组的行。
  # 解析失败返回 nil，便于调用方区分「没有数据」和「数据坏了」。
  def subtitle_payload
    value = self.lines
    value = JSON.parse(value) while value.is_a?(String)
    value
  rescue JSON::ParserError
    nil
  end

  # 逐行字幕：[{"start"=>0.0, "end"=>2.5, "tokens"=>[{"ch"=>"女", "py"=>"nǚ"}]}]
  def subtitle_lines
    payload = subtitle_payload
    return payload if payload.is_a?(Array)
    return payload["lines"] if payload.is_a?(Hash) && payload["lines"].is_a?(Array)

    []
  end

  # 只替换行数据，payload 里的 image/index/start/end/char_times 等其余键保持库中原样，
  # 并保持原来的存储格式（字符串存的仍存字符串），避免 haoqi_voicebook 读不出来。
  def update_subtitle_lines!(new_lines)
    stored_as_string = self.lines.is_a?(String)
    payload = subtitle_payload
    payload = {} unless payload.is_a?(Hash)
    payload["lines"] = new_lines

    update!(lines: stored_as_string ? JSON.generate(payload) : payload)
  end
end
