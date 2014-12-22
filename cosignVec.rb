#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
#2テキスト間のコサイン類似度を計算する
#http://qiita.com/katco/items/77a9b0a049ed5b8e5650
require 'natto'

class CosignVec

  def initialize
    @freq = {}
  end

  def wakati(text)
    words = []
    nm = Natto::MeCab.new
    nm.parse(text) do |n|
      words << n.surface
    end
    return words
  end

  def to_vec(words)

  end
end

text = "今日は雨だった"

cv = CosignVec.new
p cv.wakati(text)
