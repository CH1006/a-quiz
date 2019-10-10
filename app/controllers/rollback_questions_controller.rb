# frozen_string_literal: true

class RollbackQuestionsController < ApplicationController
  before_action :find_question, :limit_access

  def index
    version = @question.versions.find(params[:version])
    Question.skip_callback = true
    if version.reify(has_many: true).save
      Question.skip_callback = false
    else
      flash.now[:danger] = t "messages.failed.questions.create"
    end
  end

  private

  def find_question
    @question = Question.find(params[:question_id])
  end

  def limit_access
    return if current_user.id == @question.user_id

    flash[:danger] = t "messages.failed.questions.limit"
    redirect_to @question
  end
end
