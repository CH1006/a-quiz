# frozen_string_literal: true

class NotificationUpdatesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification_update_channel_#{current_user.id}"
  end
end
