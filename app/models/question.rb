# frozen_string_literal: true

class Question < ApplicationRecord
  cattr_accessor :skip_callback
  belongs_to :category
  has_many :answers, dependent: :destroy, inverse_of: :question
  has_many :results
  belongs_to :user
  has_many :notifications, dependent: :destroy

  has_paper_trail on: :update

  before_save :check_to_create_version, if: :persisted?
  after_commit :show_question, on: :create
  after_commit :update_for_question, on: :update

  accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: :all_blank
  validates :level, presence: true
  validates :question_content, presence: true, length: { minimum: 5, maximum: 255 }
  validate :valid_answer, :valid_correct, :count_answer, :question_exist
  enum level: %i[easy hard]

  def self.getquestion(exam)
    hard = exam.master? ? 10 : 5
    questions = includes(:category).where(level: "hard", category_id: exam.category_id).sample(hard)
    questions += includes(:category).where(level: "easy", category_id: exam.category_id).sample(20 - hard)
    questions.shuffle
  end

  def convert_attributes(crawler_question)
    self.question_content = crawler_question.question_content
    self.level = crawler_question.level
    crawler_question.crawler_answers.each { |answer| answers.new content: answer.content, status: answer.status }
  end

  private

  def valid_correct
    correct = new_record? ? answers.select(&:status).size : answers.select { |a| a.status && !a._destroy }.size
    errors.add(:base, I18n.t("model.question.no_correct")) if correct.zero?
    errors.add(:base, I18n.t("model.question.no_wrong")) if correct == answers.collect { |a| a.content unless a._destroy }.compact.size
  end

  def count_answer
    total_answer = new_record? ? answers.size : answers.reject(&:_destroy).size
    errors.add(:base, I18n.t("model.question.less_than")) if total_answer < 2
  end

  def valid_answer
    answer = answers.collect { |a| a.content unless a._destroy }.compact
    errors.add(:base, I18n.t("model.question.not_same")) unless answer.compact.uniq.size == answer.size
  end

  def question_exist
    questions = Question.joins(:answers).where(question_content: question_content,
                                               category_id: category_id, level: level,
                                               answers: { content: answers.map { |a| a.content unless a._destroy } }).map(&:id)
    errors.add(:base, I18n.t("model.question.exist")) if new_record? && questions.present?
    return unless persisted?

    questions.delete(id)
    errors.add(:base, I18n.t("model.question.exist")) if questions.present?
  end

  def show_question
    QuestionBroadcastJob.perform_now(Notification.where(question_id: self.id, notification_content: 0))
  end

  def update_for_question
    skip_callback = false
    UpdateQuestionJob.perform_now(self)
  end

  def check_to_create_version
    return if skip_callback
    raise StandardError if !changed? && !answers.any? { |e| e.new_record? || e.marked_for_destruction? || e.changed? }
    return if Question.where(id: id, category_id: category_id, question_content: question_content, level: level).blank?

    version = paper_trail.record_update(force: true, in_after_callback: false, is_touch: false)
    version.update_columns created_at: Time.zone.now
  end
end
