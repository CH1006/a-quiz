# frozen_string_literal: true

class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "question_channel_#{current_user.id}"
  end
end
