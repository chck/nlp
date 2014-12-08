#!/usr/bin/env python
# -*- coding: utf-8 -*-
#twitterBot.py
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
#use python-twitter
import twitter
import MeCab
import random
import re
import yaml

_var = open("../API.yaml").read()
_yaml = yaml.load(_var)
api = twitter.Api(
    consumer_key = _yaml["consumer_key0"],
    consumer_secret = _yaml["consumer_secret0"],
    access_token_key = _yaml["access_token0"],
    access_token_secret = _yaml["access_token_secret0"]
    )

def wakati(text):
  t = MeCab.Tagger("-Owakati")
  m = t.parse(text)
  result = m.rstrip(" \n").split(" ")
  return result

def markov(src):
  wordlist = wakati(src)
  markov = {}
  w1=''
  for word in wordlist:
    if w1:
      if(w1)not in markov:
        markov[(w1)] = []
      markov[(w1)].append(word)
    w1=word
  count = 0
  sentence=''
  w1=random.choice(markov.keys())
  #カウント数はおこのみで
  while count < 50:
    if markov.has_key((w1))==True:
      tmp = random.choice(markov[(w1)])
      sentence += tmp
    w1=tmp
    count += 1
  return sentence

def tweet_friends():
  i=0
  j=0
  friends = api.GetFriends()
  tweets = ''
  for i in range(len(friends)):
    friend_timeline = api.GetUserTimeline(screen_name=friends[i].screen_name)
    for j in range(len(friend_timeline)):
      #他の人へのツイートは除外
      if "@" not in friend_timeline[j].text:
        tweets+=friend_timeline[j].text
      tweets=str(tweets)
      tweets=re.sub('https?://[\w/:%#\$&\?\(\)~\.=\+\-]+',"",tweets)
    FriendsTweet = marcov(tweets)
    return FriendsTweet

def tweet_own():
  i=0
  own = api.GetUserTimeline(screen_name='geo_ebi',count=100)
  print type(own)
  tweets=''
  for i in range(len(own)):
    if "@" not in own[i].text:
      tweets+=own[i].text
    tweets=str(tweets)
    tweets=re.sub('https?://[\w/:%#\$&\?\(\)~\.=\+\-]+',"",tweets)
#  OwnTweet = markov(tweets)
#  return OwnTweet
  return tweets

print(tweet_own())

#if random.random()<0.5:
#Bot = tweet_own()
#print(Bot)
#  status = api.PostUpdate(Bot)
#else:
#Bot = tweet_friends()
#print(Bot)
#  status = api.PostUpdate(Bot)

