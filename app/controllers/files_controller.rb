class FilesController < ApplicationController
  before_action :require_login

  def json_file
    file = params[:file]
    content = File.read(file.path)
    render json: {code: 0, content: content}
  end

  def upload_media
    file = params[:file]

    if file.blank?
      render json: { code: 1, msg: '请选择要上传的文件' }
      return
    end

    extension = File.extname(file.original_filename).downcase.delete('.')
    allowed_extensions = %w[wav mp3 mp4 mov]

    unless allowed_extensions.include?(extension)
      render json: { code: 1, msg: '不支持的文件格式，请上传 wav、mp3、mp4、mov格式的文件' }
      return
    end

    begin
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      random_str = SecureRandom.hex(8)

      new_filename = "#{timestamp}_#{random_str}.#{extension}"
      oss_path  = "mp4MultibitrateIn36f860fc1279e41828398ffb29c2a7a8/#{new_filename}"

      tmp_file_path = file.tempfile.path
      mime = `file --brief --mime-type "#{tmp_file_path}"`.strip

      temp_dir = Rails.root.join('tmp', 'uploads')
      FileUtils.mkdir_p(temp_dir)
      persistent_path = temp_dir.join(new_filename).to_s
      FileUtils.cp(tmp_file_path, persistent_path)

      MediaVideoUploadJob.perform_later(oss_path, persistent_path, mime)

      render json: {
        code: 0,
        msg: '上传已提交，正在后台处理',
        data: {
          file_url: "#{oss_base_url}/#{oss_path}",
          file_type: extension,
          file_name: file.original_filename,
          file_size: file.size,
          duration: nil,
          file_size_desc: ActiveSupport::NumberHelper.number_to_human_size(file.size)
        }
      }
    rescue => e
      Rails.logger.error "文件上传失败: #{e.message}"
      render json: { code: 1, msg: '文件上传失败，请重试' }
    end
  end

  def upload
    file = params[:file]

    if file.blank?
      render json: { code: 1, msg: '请选择要上传的文件' }
      return
    end

    extension = File.extname(file.original_filename).downcase.delete('.')
    allowed_extensions = %w[epub pdf]

    unless allowed_extensions.include?(extension)
      render json: { code: 1, msg: '不支持的文件格式，请上传 epub、pdf格式的文件' }
      return
    end

    begin
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      random_str = SecureRandom.hex(8)
      new_filename = "#{timestamp}_#{random_str}.#{extension}"

      tmp_file_path = file.tempfile.path
      mime = `file --brief --mime-type "#{tmp_file_path}"`.strip

      temp_path = save_temp_file(file, new_filename)
      FileUploadJob.perform_later(new_filename, temp_path, mime)
                                                                                 
      render json: {
        code: 0,
        msg: '上传成功',
        data: {
          file_url: "#{oss_base_url}/#{new_filename}",
          file_type: extension,
          file_name: file.original_filename,
          file_size: file.size,
          file_size_desc: ActiveSupport::NumberHelper.number_to_human_size(file.size)
        }
      }
    rescue => e
      Rails.logger.error "文件上传失败: #{e.message}"
      render json: { code: 1, msg: '文件上传失败，请重试' }
    end
  end

  def upload_img 
    file = params[:file]
    if file.blank?
      render json: { success: false, message: '请选择文件' }
      return
    end

    allowed_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
    unless allowed_types.include?(file.content_type)
      render json: { success: false, message: '仅支持 JPG、PNG、GIF、WebP 格式' }
      return
    end

    extension = File.extname(file.original_filename).downcase.delete('.')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    random_str = SecureRandom.hex(8)
    new_filename = "#{timestamp}_#{random_str}.#{extension}"

    tmp_file_path = file.tempfile.path
    mime = `file --brief --mime-type "#{tmp_file_path}"`.strip

    oss_path = AliyunOss.instance.put(new_filename, File.open(file.tempfile.path), {'content_type': mime})

    render json: {
      success: true,
      url: oss_path,
      preivew_url: FileMap.new(oss_path, "img").secrity_src,
      name: file.original_filename,
      size: file.size
    }
  end

  def upload_open_img
    file = params[:file]
    if file.blank?
      render json: { success: false, message: '请选择文件' }
      return
    end

    allowed_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
    unless allowed_types.include?(file.content_type)
      render json: { success: false, message: '仅支持 JPG、PNG、GIF、WebP 格式' }
      return
    end

    if file.size > 5.megabytes
      render json: { success: false, message: '文件大小不能超过 5MB' }
      return
    end

    extension = File.extname(file.original_filename).downcase.delete('.')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    random_str = SecureRandom.hex(8)
    new_filename = "#{timestamp}_#{random_str}.#{extension}"

    tmp_file_path = file.tempfile.path
    mime = `file --brief --mime-type "#{tmp_file_path}"`.strip

    oss_path = AliyunOssOpen.instance.put(new_filename, File.open(tmp_file_path), {'content_type': mime})

    render json: {
      success: true,
      url: oss_path,
      name: file.original_filename,
      size: file.size
    }
  end
  
  private

  def oss_base_url
    bucket = ENV["ALIYUN_OSS_BUCKET"]
    area = ENV["ALIYUN_OSS_ENDPOINT"].to_s.sub(/^oss-/, '').sub(/\.aliyuncs\.com$/, '')
    "https://#{bucket}.oss-#{area}.aliyuncs.com"
  end

  def save_temp_file(file, filename)
    temp_dir = Rails.root.join('tmp', 'uploads')
    FileUtils.mkdir_p(temp_dir) unless Dir.exist?(temp_dir)
    temp_path = temp_dir.join(filename)
    FileUtils.cp(file.tempfile.path, temp_path.to_s)
    temp_path.to_s
  end

end
