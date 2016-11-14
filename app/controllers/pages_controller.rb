require 'open-uri'
require 'json'
require 'Date'

class PagesController < ApplicationController
  def game
    @grid = generate_grid(9).join("")
    @start_time = Time.now
  end

  def score
      @end_time = Time.now
      @grid = params[:grid]
      @attempt = params[:attempt]
      @start_time = DateTime.parse(params[:start_time])
      @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    array = []
    grid_size.times { array << ('A'..'Z').to_a.sample }
    return array
  end



  def get_translate(word)
    url = "https://api-platform.systran.net/translation/text/translate?source="\
          "en&target=fr&key=fc7a0b99-1841-4c17-a4d0-0c491ff853f6&input=#{word}"
    t_word = JSON.parse(open(url).read)
    return t_word["outputs"][0]["output"]
  end

  def word_counter(sentence)
    histogram = Hash.new { 0 }
    sentence.upcase.split("").each do |word|
      histogram[word] += 1
    end
    return histogram
  end

  def check_inclusion?(attempt, grid)
    attempt_bis = Hash.new { 0 }
    word_counter(attempt).each do |letter, count|
      if word_counter(grid)[letter] && count <= word_counter(grid)[letter]
        attempt_bis[letter] = true
      else
        attempt_bis[letter] = false
      end
    end
    return !attempt_bis.value?(false)
  end

  # attempt.upcase.split("").all?{|letter| grid.include?(letter)}

  def run_game(attempt, grid, start_time, end_time)
    h1 = { time: end_time - start_time }
    tl = get_translate(attempt)
    if check_inclusion?(attempt, grid) && tl != attempt
      h2 = { translation: tl, score: attempt.length + (1 / (end_time - start_time).to_i), message: "well done" }
    elsif check_inclusion?(attempt, grid) && tl == attempt
      h2 = { translation: nil, score: 0, message: "not an english word" }
    else
      h2 = { translation: nil, score: 0, message: "not in the grid" }
    end
    return h1.merge(h2)
  end
end

