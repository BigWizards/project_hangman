require 'json'

class Hangman

  attr_accessor :hidden_word, :game_over
  attr_reader :guesses_left, :display_word, :incorrect_letters

  def initialize (display_word=[], hidden_word=[], guesses_left=8, incorrect_letters=[])
    @value = "_"
    @display_word = display_word 
    @hidden_word = hidden_word
    @guesses_left = guesses_left
    @incorrect_letters = incorrect_letters
    @game_over = false
  end

  def generate_array
    (@hidden_word.length).times { @display_word << @value }
  end

  def check_letter(player_guess)
    correct_guess = false
    @hidden_word.each_with_index do |letter, index|
      if letter == player_guess 
        @display_word[index] = player_guess
        correct_guess = true
      end
    end
    if correct_guess == false
      @guesses_left -= 1
      @incorrect_letters << player_guess
    end
  end

  def check_game_over
    if @display_word == @hidden_word
      puts "Congratulations You Win!"
      @game_over = true
    end
  end

  def save_game
    File.open('save_game.json', 'w'){ |file| file.puts self.to_json }
  end

  def load_game
    save_file = File.open('save_game.json')
    save_file.read
  end

  def to_json
    JSON.dump ({
      :display_word => @display_word,
      :hidden_word => @hidden_word,
      :guesses_left => @guesses_left,
      :incorrect_letters => @incorrect_letters
    })
  end

  def self.from_json(string)
    data = JSON.load string
    self.new(data['display_word'], data['hidden_word'], data['guesses_left'], data['incorrect_letters'])
  end

end

dictionary = File.readlines "dictionary.txt"

def get_word(dictionary)
  got_word = false
  word = ""
  until got_word == true
    word = dictionary[rand(61407)]
    if word.length >= 4 && word.length <= 11
      got_word = true
    end
  end
  word
end

def split_word(word)
  word.downcase.split("")[0..(word.length - 3)]
end


def turn(hangman)
  if hangman.incorrect_letters.length > 0
    puts "Previously used letters #{hangman.incorrect_letters}"
  end
  puts "Please enter your guess."
  player_guess = gets.chomp.downcase
  if player_guess == "save"
    hangman.save_game
    puts "Game saved."
    turn(hangman)
  elsif player_guess.length > 1
    puts "Only input 1 letter at a time."
    turn(hangman)
  elsif player_guess == "" || hangman.incorrect_letters.include?(player_guess)
    turn(hangman)
  else
    hangman.check_letter(player_guess)
    p hangman.display_word
    puts "Guesses left #{hangman.guesses_left}" 
  end
end


hidden_word = get_word(dictionary)
hidden_word = split_word(hidden_word)
hangman = Hangman.new 
hangman.hidden_word = hidden_word
hangman.generate_array

if File.exists?('save_game.json')
  puts "Would you like to load the previous save?"
  choice = gets.chomp
  if choice == 'yes'
    hangman = Hangman.from_json(hangman.load_game)
  end
end

puts "Welcome to hangman. You have #{hangman.guesses_left} guesses to guess the word"
puts "Type 'save' if you want to save the game."
print hangman.display_word
puts ""
until hangman.game_over == true
  turn(hangman)
  hangman.check_game_over
  if hangman.guesses_left == 0
    puts "You Lose. The word was #{hangman.hidden_word.join}"
    hangman.game_over = true
  end
end

