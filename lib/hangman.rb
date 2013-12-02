require 'sinatra/base'

class Hangman < Sinatra::Base

  set :root, File.expand_path('../../', __FILE__)

  get '/' do
    @random_word = pick_random_word.scan(/\w/).join(' ')
    @blanks_array = make_blanks_array(@random_word)
    make_gallow(0)
    erb :main
  end

  post '/' do
    @letters = []
    @wrong_letters = [" "]
    @random_word = params[:random_word]
    @guess = params[:guess]
    @letters = params[:letters]
    @wrong_letters = params[:wrong_letters]
    make_gallow(@wrong_letters.length)
    # Check for repeat guesses
    @guess_validation = validate_guess(@letters, @guess)
    @blanks_array = params[:blanks]
    if @random_word.include?(@guess)
      index_list = get_indices(@guess, @random_word)
      index_list.each do |i|
      @blanks_array[i] = @guess
      end
    else
      if not @wrong_letters.include?(@guess)
        @wrong_letters << @guess
      @feedback = "Wrong letter. Pick again:"
      end
    end
    state = determine_state(@blanks_array)
    # Who won?
    if state == 'computer wins'
      @feedback = "YOU KILLED HIM. The secret word was #{@random_word.to_s.gsub(/\s+/, '')}."
    elsif state == 'user wins'
      @feedback = 'Congratulations! You have guessed the word!'
    end
    erb :main
  end

  def validate_guess(array, guess)
    if not array.include?(guess)
      @letters << guess
      return nil
    else
      "You already guessed #{guess}."
    end
  end

  # The file contains one fruit per line
  def pick_random_word
    file = open('./lib/fruits.txt')
    file.readlines.sample.downcase
  end

  # This method returns the number of blanks which is the ceiling of the secret word length / 2.
  def make_blanks_array(secret_word)
    blanks_array = ['_'] * (secret_word.length.to_f / 2).ceil
    blanks_array.join' '
  end

  # Returns an array containing the indices of all occurrences of a letter in a word
  def get_indices(letter, word)
    index_list = []
    (0..word.length).each do |i|
      if word[i] == letter
        index_list << i
      end
    end
    index_list
  end

  def determine_state(blank)
    state = 'in progress'
    # Left leg is the last body part
    if @gallow == 'hang6'
      return 'computer wins'
    end
    # User has filled out the blanks
    if not blank.include?('_')
      return 'user wins'
    end
    state
  end

  def make_gallow(i)
    @gallow = "hang#{i}"
    STDERR.puts(@gallow)
  end

end


#  # Interactive Section
#  while state == 'in progress'
#    puts "You get #{6 - penalty} chance(s). Don't make me kill this sucka."

#def is_valid(guess)
#  if guess.count > 1
#    return false
#  end
#  if guess <='A' and guess <='Z'
#  end