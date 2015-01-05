#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

vec1 = [3.46, 2.00, 1.00]
vec2 = [1.41, 1.00, 1.00, 1.00, 1.00]

def dot_product(vec1, vec2)
  sum = 0.0
  vec1.each_with_index do |val, i|
    if vec2[i].nil?
      vec2_val = 0
    else
      vec2_val = vec2[i]
    end
    sum += val*vec2_val
  end
  return sum
end

#ベクトルノルムを計算	
def normalize(vec)
  Math.sqrt(vec.inject(0.0) { |m,o| m += o**2})
end

dt = dot_product(vec1, vec2)
nm = normalize(vec1) * normalize(vec2)

p dt/nm
