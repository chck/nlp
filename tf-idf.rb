#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
#http://kitsunemimi9.blog89.fc2.com/blog-entry-20.html
require 'natto'

#文書集合のサンプル 
text = ["ミニアルバム☆ 新谷良子withPBB「BANDScore」 絶賛発売chu♪ いつもと違い、「新谷良子withPBB」名義でのリリース！！ 全５曲で全曲新録！とてもとても濃い１枚になりましたっ。 PBBメンバーと作り上げた、新たなバンビポップ。 今回も、こだわり抜いて", "2012年11月24日 – 2012年11月24日(土)／12:30に行われる、新谷良子が出演するイベント詳細情報です。", "単語記事: 新谷良子. 編集 Tweet. 概要; 人物像; 主な ... その『ミルフィーユ・桜葉』という役は新谷良子の名前を広く認知させ、本人にも大切なものとなっている。 このころは演技も歌も素人丸出し（ ... え、普通のことしか書いてないって？ 「普通って言うなぁ！」", "2009年10月20日 – 普通におっぱいが大きい新谷良子さん』 ... 新谷良子オフィシャルblog 「はぴすま☆だいありー♪」 Powered by Ameba ... 結婚 356 名前： ノイズh(神奈川県)[sage] 投稿日：2009/10/19(月) 22:04:20.17 ID:7/ms/OLl できたっちゃ結婚か", "2010年5月30日 – この用法の「壁ドン（壁にドン）」は声優の新谷良子の発言から広まったものであり、一般的には「壁際」＋「追い詰め」「押し付け」などと表現される場合が多い。 ドンッ. 「……黙れよ」. このように、命令口調で強引に迫られるのが女性のロマンの"] 

txt_num = text.size
puts "total texts: #{txt_num}"

custom_dic_path = "./dic/custom.dic"
fv_tf = []	#文書中の単語の出現回数
fv_df = {}	#単語の出現文書数
word_count = []	#単語の総出現回数

fv_tf_idf = []	#文書中の単語の特徴量

count_flag = {}	#fv_dfを計算する上で必要なフラグ

#各文書の形態素解析と単語の出現回数を計算
text.each.with_index(1) do |txt, txt_id|
  tagger = Natto::MeCab.new("-u #{custom_dic_path}")

  fv = {}	#単語の出現回数
  words = 0

  fv_df.keys.each do |word|
    count_flag[word] = false
  end

  tagger.parse(txt) do |node|
    surface = node.surface
    next if surface =~ %r(^[+-.$()?*/&%!"'_,;:\]]+)    
    next if surface =~ /^[-.0-9]+$/
    next unless node.feature.match("名詞")

    words += 1

    fv[surface] ? fv[surface] += 1 : fv[surface] = 1  #surfaceが既にあれば+1,なければ1で初期化

    if fv_df.has_key?(surface) && count_flag[surface] == false
      fv_df[surface] += 1  #出現文書数+1
      count_flag[surface] = true
    else
      fv_df[surface] = 1  #出現文書数初期値
      count_flag[surface] = true
    end
  end

  fv_tf << fv
  word_count << words
end

#tf, idf, tf-idfの計算
fv_tf.each.with_index(1) do |fv, txt_id|
  tf = {}
  idf = {}
  tf_idf = {}
  fv.keys.each do |key|
    tf[key] = fv[key]/word_count[txt_id].to_f  #tfの計算
    idf[key] = Math.log(txt_num/fv_df[key].to_f)  #idfの計算
    tf_idf[key] = tf[key]*idf[key], tf[key], idf[key], fv[key], fv_df[key] #tf-idfなどの計算
  end
  tf_idf.delete(nil)
  tf_idf = tf_idf.sort_by{|key, value| -value[0]}  #tf-idfで降順ソート
  fv_tf_idf << tf_idf
end

#出力
fv_tf_idf.each.with_index(1) do |fv, txt_id|
  puts "This is the tf-idf of text #{txt_id}"
  puts "total words: #{word_count[txt_id]}"

  fv.each do |word, tf_idf|
    puts "\t#{word}\t#{tf_idf[0]}\t#{tf_idf[1]}\t#{tf_idf[2]}\t#{tf_idf[3]}\t#{tf_idf[4]}"
  end
end
