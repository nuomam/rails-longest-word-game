class GameController < ApplicationController
  def game
    @letters = Array.new(9) { ('A'..'Z').to_a[rand(26)] }
  end

  def included?(guess, grid)
    guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def translation(word)
    systran_api_key = "f844a445-6337-4e99-9631-8e88b428b4d3"
    translation_url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{systran_api_key}&input=#{word}"
    url_serialized = open(translation_url).read
    word_translation = JSON.parse(url_serialized)["outputs"][0]["output"]
    if word.downcase == word_translation.downcase
      return false
    else
      return word_translation.downcase
    end
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, translation, grid, time)
  if included?(attempt.upcase.split(""), grid)
    if translation
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end


  def score
    @time = (params[:end_time].to_i - params[:start_time].to_i) / 1000
    letters = params[:grid].split("")
    @translation = translation(params[:attempt])
    @score_message = score_and_message(params[:attempt], @translation, letters, @time)
  end


end
