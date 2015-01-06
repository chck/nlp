#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
require 'natto'

def wakati(text)
  words = []
  nm = Natto::MeCab.new
  nm.parse(text) do |n|
    words << n.surface
  end
  return words
end

def markov_d2(src)
#  wordlist = src
  wordlist = wakati(src)
  markov = {}
  w1 = ""
#  wordlist.split(//).each do |word|
  wordlist.each do |word|
    if w1
      unless markov.include?(w1)
        markov[w1] = []
      end
      markov[w1] << word
    end
    w1=word
  end
  count=0
  sentence=""
  w1=markov.keys.sample
  while count<20
    if markov.has_key?(w1)
      tmp = markov[w1].sample
      sentence += tmp
    end
    w1=tmp
    count+=1
  end
  return sentence
end

def markov_d3(src)
#  wordlist = src
  wordlist = wakati(src)
  markov = {}
  w1 = ""
  w2 = ""
#  wordlist.split(//).each do |word|
  wordlist.each do |word|
    if w1 && w2
      unless markov.include?([w1,w2])
        markov[[w1,w2]] = []
      end
      markov[[w1,w2]] << word
    end
    w1,w2=w2,word
  end
  count=0
  sentence=""
  w1,w2=markov.keys.sample
  while count<20
    if markov.has_key?([w1,w2])
      tmp = markov[[w1,w2]].sample
      sentence += tmp
    end
    w1,w2=w2,tmp
    count+=1
  end
  return sentence
end

def markov_d4(src)
  wordlist = src
#  wordlist = wakati(src)
  markov = {}
  w1 = ""
  w2 = ""
  w3 = ""
  wordlist.split(//).each do |word|
#  wordlist.each do |word|
    if w1 && w2 && w3
      unless markov.include?([w1,w2,w3])
        markov[[w1,w2,w3]] = []
      end
      markov[[w1,w2,w3]] << word
    end
    w1,w2,w3=w2,w3,word
  end
  count=0
  sentence=""
  w1,w2,w3=markov.keys.sample
  while count<20
    if markov.has_key?([w1,w2,w3])
      tmp = markov[[w1,w2,w3]].sample
      sentence += tmp
    end
    w1,w2,w3=w2,w3,tmp
    count+=1
  end
  return sentence
end

dir = "./d2c_201410-11.txt"
dir = "../nlp/nippo/nippos/tech/07/all.txt"

text = open((dir), "r").readlines.uniq.join("").gsub(/\n|\"/,"")
30.times do |i|
  p i
  open("markov.txt","a+") do |f|
#  open("google_parse_d2_res.txt","a+") do |f|
    f.puts markov_d2(text)
  end
end
