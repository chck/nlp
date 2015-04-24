#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
require 'natto'

class GetFreqWords
  def main(text)
    @mecab         = Natto::MeCab.new("-u ./dic/custom.dic")
    @EXCLUDE_WORDS = open("./dic/stopword.txt").readlines.map(&:chomp)
    word_h         = {}
    @mecab.parse(text) do |word|
      surface = word.surface
      next if @EXCLUDE_WORDS.include?(surface)
      next unless word.feature.match("名詞")
      word         = word.surface
      word_h[word] = word_h[word] ? word_h[word] + 1 : 1
    end
    word_h.sort_by
    return word_h#.sort_by { |word, count| -count }
  end
end

# text = open("./sample_data/girlfriend.txt").read.gsub(/\n/,"")
# get_freq_words(text).each_with_index do |row,i|
#   puts "#{row[0]},#{row[1]}"
# end
