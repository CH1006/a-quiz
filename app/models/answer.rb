# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :question, touch: true
  has_many :results
  has_paper_trail

  validates :content, presence: true, length: { minimum: 1, maximum: 255 }
end
