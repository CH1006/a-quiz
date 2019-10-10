# frozen_string_literal: true

class UpdateQuestionJob < ApplicationJob
  queue_as :update_question

  def perform(question)
    ActionCable.server.broadcast "update_question_channel",
                                 question: render_question(question), id: question.id
  end

  private

  def render_question(question)
    ApplicationController.renderer.render(partial: "questions/question_content",
                                          locals: { question: question })
  end
end
