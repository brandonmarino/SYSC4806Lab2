require 'set'

class Spellchecker

  
  ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

  #constructor.
  #text_file_name is the path to a local file with text to train the model (find actual words and their #frequency)
  #verbose is a flag to show traces of what's going on (useful for large files)
  def initialize(text_file_name)
    #read file text_file_name
    #extract words from string (file contents) using method 'words' below.
    #put in dictionary with their frequency (calling train! method)
    thefile = File.open(text_file_name, "r")
    contents = thefile.read
    thefile.close
    wordList = words(contents)
    train! (wordList)
  end

  def dictionary
    #getter for instance attribute
    return @dictionary 
  end
  
  #returns an array of words in the text.
  def words (text)
    return text.downcase.scan(/[a-z]+/) #find all matches of this simple regular expression
  end

  #train model (create dictionary)
  def train!(word_list)  
    #create @dictionary, an attribute of type Hash mapping words to their count in the text {word => count}. Default count should be 0 (argument of Hash constructor).
    @dictionary = Hash.new 0
    word_list.each do |word|
      if @dictionary.has_key? word
        count = lookup(word)+1
        @dictionary[word] = count
      else
        @dictionary[word] = 1
      end
    end
  end

  #lookup frequency of a word, a simple lookup in the @dictionary Hash
  def lookup(word)
    count = @dictionary[word]
    return count
  end
  
  #generate all correction candidates at an edit distance of 1 from the input word.
  def edits1(word)
    
    deletes    = []
    #all strings obtained by deleting a letter (each letter)
    for i in 0..word.length-1
        str = word.dup
	str.slice!(i)
        deletes.push(str)
    end 
    
    transposes = []
    #all strings obtained by switching two consecutive letters
    count = word.length-2
    if count > 0
       (0..count).each do |i|
	   str = word.dup
	   str[i+1] = word[i]
	   str[i] = word[i+1]
 	   transposes.push(str)
       end
    end
    
    inserts = []
    # all strings obtained by inserting letters (all possible letters in all possible positions)
    for i in 0..word.length
    	ALPHABET.each_char do |e|
           str = word.dup
           str = str.insert(i,e)
	   inserts.push(str)
	end
    end
    
    
    replaces = []
    #all strings obtained by replacing letters (all possible letters in all possible positions)
    for i in 0..word.length-1
    	ALPHABET.each_char do |e|
           str = word.dup
           str[i] = e
	   replaces.push(str)
	end
    end
    
    return (deletes + transposes + replaces + inserts).to_set.to_a #eliminate duplicates, then convert back to array
  end
  

  # find known (in dictionary) distance-2 edits of target word.
  def known_edits2 (word)
    # get every possible distance - 2 edit of the input word. Return those that are in the dictionary.
    s = []
    
    editor1 = edits1(word)
    editor1.each do |e|
   	 s.concat(edits1(e))
    end 

    return known(d2)
  end

  #return subset of the input words (argument is an array) that are known by this dictionary
  def known(words)
    result = words.find_all {true } #find all words for which condition is true,
                                    #you need to figure out this condition
    result.empty? ? nil : result
  end


  # if word is known, then
  # returns [word], 
  # else if there are valid distance-1 replacements, 
  # returns distance-1 replacements sorted by descending frequency in the model
  # else if there are valid distance-2 replacements,
  # returns distance-2 replacements sorted by descending frequency in the model
  # else returns nil 
  def correct(word)
    if (@dictionary.has_key?(word))
      return word
    else
      possibilites = edits1 (word)
      if (possibilities.empty?)
        return possibilities
      else
        possibilites = known_edits2 (word)
        if (possibilities.empty?)
          return possibilities
        end
      end
    end
  end
    
  
end

