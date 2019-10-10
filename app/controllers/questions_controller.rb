# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :load_question, only: %i[show edit update]
  before_action :load_notification, only: :show

  def index
    @questions = Question.includes(:answers, :category).order(updated_at: :desc).page(params[:page]).per(6)
  end

  def new
    @question = Question.new
    2.times { @question.answers.build }
  end

  def create
    @question = current_user.questions.new question_params
    ActiveRecord::Base.transaction do
      @question.save!
      Notification.import!(%i[user_id question_id notification_content],
                           User.admin.ids.map { |id| [id, @question.id, 0] })
    end
  rescue StandardError
    flash.now[:danger] = t "messages.failed.questions.create"
  end

  def show
    @notification.update_all(notification_status: :seen) if @notification.not_seen.any?
    @versions = @question.versions.page(params[:page]).per(3)
  end

  def edit; end

  def update
    @question.assign_attributes question_params
    Question.skip_callback = false
    ActiveRecord::Base.transaction do
      @question.save!
      unless @question.user == current_user
        notification = Notification.create!(user_id: @question.user_id, question_id: @question.id,
                                            notification_content: 1, other_user: current_user.name)
        NotificationUpdateJob.perform_now(notification)
      end
    end
  rescue StandardError
    flash.now[:danger] = t "messages.failed.questions.create"
  end

  private

  def question_params
    params.require(:question).permit(:question_content,
                                     :level, :category_id,
                                     answers_attributes: %i[id status content _destroy])
  end

  def check_admin
    return if current_user.admin?

    raise ActionController::RoutingError, params[:path]
  end

  def load_question
    @question = Question.find(params[:id])
  end

  def load_notification
    @notification = Notification.where(user_id: current_user.id, question_id: @question.id)
  end
end
