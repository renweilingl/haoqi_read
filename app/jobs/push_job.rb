class PushJob < ApplicationJob
  queue_as :zheli_high
  sidekiq_options retry: false

  def perform(push_notification_id)
    if Rails.env.production?
      url = "https://api.zheliyuedu.cn/api/push/send"

      pn = PushNotification.find push_notification_id

      logger.info " PushJob: #{push_notification_id}"
      return if pn.nil?

      return if pn.sent?   #已经推送过

      return if pn.push_scope  == 2  #先不针对特殊用户推送

      #type = pn.push_type == 0 ? "system" : "activity"
      type = "url"

      grade_ids = pn.push_scope == 0  ?  pn.grade_ids : Grade.all.pluck(:id)

      data = {uuid: AppUser.first.uuid,
              grade_ids: grade_ids,
              title: pn.title,
              body: pn.body,
              type: type,
              content: {url: pn.link_url}
      }

      res = HTTParty.post(url, body: data.to_json, headers: {'Content-Type' => 'application/json'}).body
      logger.info "PushJob push_notification_id: #{push_notification_id}, res: #{res}"

      pn.update(status: "sent")
    else  #development 
      pn = PushNotification.find push_notification_id
      pn.update(status: "sent")
    end
  end

end
