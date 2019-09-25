# frozen_string_literal: true

require "capybara/dsl"
require "webdrivers"

Capybara.current_driver = :selenium_headless
Capybara.default_max_wait_time = 10
Capybara.app_host = "https://www.w3schools.com"

class Crawler
  include Capybara::DSL

  def categories
    visit "/quiztest"
    all(".quizcontainer").map { |category| category.find(".quizbody a")["href"] }
  end

  def questions_all
    questions = []
    while has_css? ".answerbutton"
      answers = all(".radiocontainer").map { |answer| { content: answer.text.strip, status: false } }
      questions << { content: find("#qtext").text, answers: answers }
      click_on(class: "answerbutton")
    end
    questions
  end

  def answers_correct_all
    answers = []
    result_window = window_opened_by { find("#quizcontainer form input[type='submit']").click }
    within_window result_window do
      all(".radiocontainer.correct").each do |tag|
        answer_correct = tag.text
        answer_correct.slice!("Correct answer")
        answers << answer_correct.strip
      end
    end
    answers
  end

  def question_exits?(question)
    return true if CrawlerQuestion.find_by(question_content: question[:content]).present?

    Question.find_by(question_content: question[:content]).present?
  end

  def set_correct_answer(question, answer_correct)
    question[:answers].each do |answer|
      next unless answer[:content] == answer_correct

      answer[:status] = true
      break
    end
  end

  def insert_db(questions, answers_correct)
    questions.each_with_index do |question, index|
      next if question_exits?(question)

      set_correct_answer(question, answers_correct[index])
      q = CrawlerQuestion.create(question_content: question[:content])
      q.crawler_answers.create(question[:answers])
    end
  end

  def run
    categories.each do |category|
      visit category
      questions = questions_all
      answers_correct = answers_correct_all
      insert_db(questions, answers_correct)
    end
  end
end
