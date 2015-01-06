#!/usr/bin/env python
# -*- coding: utf-8 -*-
import MeCab
import sys
import random
import re
import pprint
import yaml
import pandas as pd

def pp(obj):
  pp = pprint.PrettyPrinter(indent=4, width=160)
  str = pp.pformat(obj)
  return re.sub(r"\\u([0-9a-f]{4})", lambda x: unichr(int("0x"+x.group(1), 16)), str)

def wakati(text):
  t = MeCab.Tagger("-Owakati")
  m = t.parse(text)
  result = m.rstrip(" \n").split(" ")
  return result

def markov_d1(src):
  wordlist = src#wakati(src)
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
  #出力description数
  while count < 20:
    if markov.has_key((w1))==True:
      tmp = random.choice(markov[(w1)])
      sentence += tmp
    w1=tmp
    count += 1
  return sentence

def markov_d2(src):
  wordlist = src#wakati(src)
  markov = {}
  w1=''
  w2=''
  for word in wordlist:
    if w1 and w2:
      if(w1, w2)not in markov:
        markov[(w1, w2)] = []
      markov[(w1, w2)].append(word)
    w1,w2=w2,word
  count = 0
  sentence=''
  w1,w2=random.choice(markov.keys())
  #出力description数
  while count < 20:
    if markov.has_key((w1,w2))==True:
      tmp = random.choice(markov[(w1,w2)])
      sentence += tmp
    w1=tmp
    count += 1
  return sentence


def markov_d3(src):
  wordlist = src#wakati(src)
  markov = {}
  w1=''
  w2=''
  w3=''
  for word in wordlist:
    if w1 and w2 and w3:
      if(w1, w2, w3)not in markov:
        markov[(w1, w2, w3)] = []
      markov[(w1, w2, w3)].append(word)
    w1,w2,w3=w2,w3,word
  count = 0
  sentence=''
  w1,w2,w3=random.choice(markov.keys())
  #出力description数
  while count < 20:
    if markov.has_key((w1,w2,w3))==True:
      tmp = random.choice(markov[(w1,w2,w3)])
      sentence += tmp
    w1=tmp
    count += 1
  return sentence


#df = pd.read_csv("./d2c_201410-11.csv", encoding="cp932")
#print df.values
#texts = []
#f = open("./d2c_201410-11.csv", "rb")
#texts = texts.fromfile(f)
#print texts

with open("./d2c_201410-11.txt", "rb") as f:
  texts = f.readlines()
texts.pop(0)

#print(pp(texts[0]))
print(len(texts))
print(len(wakati("".join(texts))))

#print(markov_d2(texts))
