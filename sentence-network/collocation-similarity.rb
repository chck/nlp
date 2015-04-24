#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
#単語の共起で文間の類似度計算
require 'natto'
require 'matrix'
require './get-freq-words'

class CollocationSimilarity
  def initialize
    @nm = Natto::MeCab.new("-u ./dic/custom.dic")
  end

  def calc_score(str1, str2, tfidf_h = {}, str_all_s = "")
    vector       = []
    vector1      = []
    vector2      = []
    flag_vector1 = []
    flag_vector2 = []
    noun_a1      = []
    noun_a2      = []

    @nm.parse(str1) do |node1|
      if node1.feature.match("名詞")
        vector1 << node1.surface
      end
    end

    @nm.parse(str2) do |node2|
      if node2.feature.match("名詞")
        vector2 << node2.surface
      end
    end

    vector1.delete(nil)
    vector2.delete(nil)

    vector += vector1
    vector += vector2

    vector.uniq!

    vector.each do |word|
      if vector1.include?(word)
        flag_vector1 << 1
        noun_a1 << word
      else
        flag_vector1 << 0
        noun_a1 << nil
      end

      if vector2.include?(word)
        flag_vector2 << 1
        noun_a2 << word
      else
        flag_vector2 << 0
        noun_a2 << nil
      end
    end

    unless tfidf_h.empty?
      flag_vector1 = noun_a1.map { |noun| tfidf_h[noun] ? tfidf_h[noun] : 0 }
      flag_vector2 = noun_a2.map { |noun| tfidf_h[noun] ? tfidf_h[noun] : 0 }

      unless str_all_s.empty?
        gfw = GetFreqWords.new
        freq_h = gfw.main(str_all_s)
        freq_a1 = noun_a1.map { |noun| freq_h[noun] ? freq_h[noun] : 0 }
        freq_a2 = noun_a2.map { |noun| freq_h[noun] ? freq_h[noun] : 0 }

        flag_vector1 = flag_vector1.zip(freq_a1).map { |f, s| f * s }
        flag_vector2 = flag_vector2.zip(freq_a2).map { |f, s| f * s }
      end
    end

    vector1_final = Vector.elements(flag_vector1, copy = true)
    vector2_final = Vector.elements(flag_vector2, copy = true)

    result = vector2_final.inner_product(vector1_final)/(vector1_final.norm * vector2_final.norm)
    return result.round(3)
  end
end

__END__
str1    = "昨日昨日は結構雨が降って寒かった"
str2    = "今朝はそんなに眠くなかったが雨が降った"
tfidf_h = { "昨日" => 0.2, "雨" => 0.3, "今朝" => 0.4, "なかった" => 0.5 }
# tfidf_h = {}

cs = CollocationSimilarity.new
p cs.calc_score(str1, str2, tfidf_h, true)
