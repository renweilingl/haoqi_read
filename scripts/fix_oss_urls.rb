# frozen_string_literal: true

# 修复 OSS URL 双重 oss- 和双重 .aliyuncs.com 的 bug
# 用法: rails runner scripts/fix_oss_urls.rb

def fix_url_column(model_class, column)
  return unless model_class.column_names.include?(column)

  broken = model_class.where("#{column} LIKE ?", "%oss-oss-%")
                       .or(model_class.where("#{column} LIKE ?", "%.aliyuncs.com.aliyuncs.com%"))
  count = broken.count
  return 0 if count.zero?

  broken.find_each do |record|
    url = record.public_send(column)
    next if url.blank?

    fixed = url
            .gsub(".oss-oss-", ".oss-")
            .gsub(".aliyuncs.com.aliyuncs.com", ".aliyuncs.com")
            .gsub("http://oss-", "http://")  # edge case
    record.update_column(column, fixed)
  end

  puts "  #{model_class.name}.#{column}: fixed #{count} rows"
  count
end

total = 0

puts "Fixing books..."
total += fix_url_column(Book, "file_url")
total += fix_url_column(Book, "content_file_url")

puts "Fixing chapters..."
total += fix_url_column(Chapter, "content_file_url")
total += fix_url_column(Chapter, "ld_file_path")
total += fix_url_column(Chapter, "hd_file_path")
total += fix_url_column(Chapter, "sd_file_path")

puts "Done. Total fixed: #{total}"
