#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
#http://qiita.com/okappy/items/be520a3d0cd9aec5b279
module SimilarityGenerator
  #data1,data2に配列かハッシュを渡すと類似度が返る
  def calculate_similarity(data1,data2,type="cosine")
    if data1.class==Array
      calculate_similarity_with_array(data1,data2,type)
    elsif data1.class==Hash
      calculate_similarity_with_hash(data1,data2,type)
    end
  end

  #vector1とvector2に同じ長さの数列(要素が数字の配列)を渡すと類似度が返る
  def calculate_similarity_with_array(vector1,vector2,type="cosine")
    if type=="cosine"
      #コサイン類似度を計算
      similarity = cosine_similarity(vector1,vector2)
    end
    return similarity
  end

  def calculate_similarity_with_hash(hash1,hash2,type="cosine")
    hash3 = hash1.merge(hash2)
  end
end
