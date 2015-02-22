#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
require 'natto'
require 'twitter'
require 'yaml'

class AnalyzeFollower
  def initialize
    @EXCLUDE_WORDS = open("./dic/stopword.txt","r").readlines.map(&:chomp)
    @mecab = Natto::MeCab.new("-u ./dic/custom.dic")
    @YAML_PATH = "../secret/API.yml"
  end

  def get_twitter_client(num=0)
    conf = YAML::load_file(@YAML_PATH)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = conf["tw_consumer_key#{num}"]
      config.consumer_secret = conf["tw_consumer_secret#{num}"]
      config.access_token = conf["tw_access_token#{num}"]
      config.access_token_secret = conf["tw_access_token_secret#{num}"]
    end
    @client
  end

  #REST::Client#follower_ids...5000ids/api
  #REST::Client#users...100ids/api(limit: x180/15min)
  def get_followers(twitter_id)
    token_num = 0
    followers = []
    begin
      get_twitter_client(token_num)
      follower_ids = @client.follower_ids(twitter_id).to_a ##follower
      #follower_ids = @client.friend_ids(twitter_id).to_a    ##follow
      loop_count = (follower_ids.size - 1) / 100 + 1
      loop_count.times do
        ids_temp = follower_ids.pop(100) #末尾100アカウントを毎回取って使用
        accounts_temp = @client.users(ids_temp)
        followers << accounts_temp
      end
      followers.flatten!.each.with_index(1) {|fwer,i| puts "#{i}: #{fwer.screen_name}"}
    rescue Twitter::Error::TooManyRequests => error
      sec = error.rate_limit.reset_in
      p "wait #{sec}"
      p "No.#{token_num}"
      if token_num > 51
        token_num = 0
      else
        token_num += 1
      end
      retry
    ensure
      return followers
    end
  end

  #頻出語抽出
  def get_freq_words(text)
    word_h = {}
    @mecab.parse(text) do |word|
      if word.feature.match("名詞") && !@EXCLUDE_WORDS.include?(word.surface)
        word = word.surface
        word_h[word] = word_h[word] ? word_h[word] + 1 : 1
      end
    end
    return word_h.sort_by{|word,count| count}
  end

  def get_fwer_fw(twitter_id)
    puts "-----GET FOLLOWERS-----"
    followers = get_followers(twitter_id)
    puts "-----GET FOLLOWER DESCRIPTION-----"
    profile_texts = followers.map{|fwer| fwer.description}.join
    puts "-----ANALYZE FREQ_WORDS-----"
    return get_freq_words(profile_texts)
  end
end

twitter_id = ARGV[0]
af = AnalyzeFollower.new
af.get_fwer_fw(twitter_id).each do |k,v|
  puts "#{k}\t\t\t#{v}"
end
