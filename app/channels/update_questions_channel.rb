# frozen_string_literal: true

class UpdateQuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "update_question_channel"
  end
end
