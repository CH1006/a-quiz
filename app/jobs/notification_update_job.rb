# frozen_string_literal: true

class NotificationUpdateJob < ApplicationJob
  queue_as :notification_update

  def perform(notification)
    counter = Notification.where(user_id: notification.user_id).not_seen.size
    ActionCable.server.broadcast "notification_update_channel_#{notification.user_id}",
                                 notification: render_notification(notification, notification.user),
                                 counter: render_counter(counter)
  end

  private

  def render_notification(notification, current_user)
    ApplicationController.renderer.render(partial: "shared/notification",
                                          locals: { notification: notification, current_user: current_user })
  end

  def render_counter(counter)
    ApplicationController.renderer.render(partial: "shared/counter",
                                          locals: { counter: counter })
  end
end
