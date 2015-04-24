#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
#http://kitsunemimi9.blog89.fc2.com/blog-entry-20.html
require 'natto'
require 'matrix'
require 'kconv'
require 'benchmark'

class TfIdf
  def initialize
    @EXCLUDE_WORDS = open("./dic/stopword.txt").readlines.map(&:chomp)
    @EXCLUDE_REGEX = /[\d+\.\,\/:\(\);\[\]０-９\-+]|^[\w|ぁ-ん|ァ-ヶ|ー+]|.*[\*\-�◆■△=▼▲]+.*/
    @SAMPLES       = get_samples("./dic/description_samples")
    @mecab         = Natto::MeCab.new("-u ./dic/custom.dic")
  end

  def get_samples(files_path)
    samples_a = `ls #{files_path}`.split("\n").map { |file| NKF.nkf('-wxm0', open("#{files_path}/#{file}").read.gsub(/\n/, "")) }
    return samples_a
  end

  def get_vector(text_a)
    vector_a = []
    tf_idf_a = calc_tf_idf(text_a).values
    wi_h     = gen_word_index(text_a)
    tf_idf_a.each do |tf_idf_h|
      vector = []
      wi_h.values.each do |v|
        if tf_idf_h[v]
          vector << tf_idf_h[v]
        else
          vector << 0
        end
      end
      vector_a << vector
    end
    return vector_a
  end

  def calc_tf_idf(target_text)
    training_text_a = @SAMPLES
    training_text_a.unshift(target_text)

    tf_idf_a = []
    df       = get_df(training_text_a)
    training_text_a.each do |text_s|
      params = get_params(text_s)
      wc     = params[:wc]
      tf_idf = {}
      tf     = {}
      idf    = {}
      fv     = params[:fv_tf]
      fv.keys.each do |key|
        tf[key]     = fv[key]/wc.to_f
        idf[key]    = Math.log(training_text_a.size/df[key].to_f)
        tf_idf[key] = tf[key]*idf[key]
      end
      tf_idf_a << tf_idf #.sort_by { |key, value| -value }
    end
    # return tf_idf_a
    tf_idf_h = tf_idf_a.first
    return tf_idf_h
  end

  private def get_df(text_a)
    df       = {}
    noun_a_a = text_a.map { |text_s| extract_noun(text_s).uniq }
    noun_a_a.each do |noun_a|
      noun_a.each do |noun|
        df[noun] ? df[noun] += 1 : df[noun] = 1
      end
    end
    return df
  end

  #1文章ごとにfv_tf, wcを計算して返す
  private def get_params(text_s)
    fv_tf = {} #各単語の出現回数
    nouns = extract_noun(text_s)
    wc    = nouns.size #単語の総数
    nouns.each do |noun|
      fv_tf[noun] ? fv_tf[noun] += 1 : fv_tf[noun] = 1
    end
    return { wc: wc, fv_tf: fv_tf }
  end

  #名詞のリストを返す(重複有り)
  private def extract_noun(string)
    noun_a = []
    @mecab.parse(string) do |word|
      surface = word.surface
      next if surface.nil?
      surface.scrub!
      next if @EXCLUDE_WORDS.include?(surface)
      next unless word.feature.match("名詞")
      next if surface.size <= 1
      next if surface =~ @EXCLUDE_REGEX
      # p surface
      noun_a << surface
    end
    return noun_a
  end

  private def gen_word_index(text_a)
    all_noun_h = {}
    text_s     = text_a.join(",")
    #uniq_nounでindexを作成
    extract_noun(text_s).uniq.each_with_index { |word, i| all_noun_h[i] = word }
    return all_noun_h
  end

  def calc_similarity(vec1_a, vec2_a)
    vec1       = Vector.elements(vec1_a, copy = true)
    vec2       = Vector.elements(vec2_a, copy = true)
    similarity = vec2.inner_product(vec1)/(vec1.norm * vec2.norm)
    return similarity.round(3)
  end
end

# Benchmark.bm do |x|
#   x.report {
#     ti = TfIdf.new
#     text_a = ti.get_samples("./dic/description_samples")#[0..1]
#     text = "ミニアルバム☆ 新谷良子withPBB「BANDScore」 絶賛発売chu♪ いつもと違い、「新谷良子withPBB」名義でのリリース！！ 全５曲で全曲新録！とてもとても濃い１枚になりましたっ。 PBBメンバーと作り上げた、新たなバンビポップ。 今回も、こだわり抜いて"
#     p h = ti.calc_tf_idf(text)
#     p h.values
#   }
# end

__END__
ti     = TfIdf.new
#text_a = ["ミニアルバム☆ 新谷良子withPBB「BANDScore」 絶賛発売chu♪ いつもと違い、「新谷良子withPBB」名義でのリリース！！ 全５曲で全曲新録！とてもとても濃い１枚になりましたっ。 PBBメンバーと作り上げた、新たなバンビポップ。 今回も、こだわり抜いて", "2012年11月24日 – 2012年11月24日(土)／12:30に行われる、新谷良子が出演するイベント詳細情報です。", "単語記事: 新谷良子. 編集 Tweet. 概要; 人物像; 主な ... その『ミルフィーユ・桜葉』という役は新谷良子の名前を広く認知させ、本人にも大切なものとなっている。 このころは演技も歌も素人丸出し（ ... え、普通のことしか書いてないって？ 「普通って言うなぁ！」", "2009年10月20日 – 普通におっぱいが大きい新谷良子さん』 ... 新谷良子オフィシャルblog 「はぴすま☆だいありー♪」 Powered by Ameba ... 結婚 356 名前： ノイズh(神奈川県)[sage] 投稿日：2009/10/19(月) 22:04:20.17 ID:7/ms/OLl できたっちゃ結婚か", "2010年5月30日 – この用法の「壁ドン（壁にドン）」は声優の新谷良子の発言から広まったものであり、一般的には「壁際」＋「追い詰め」「押し付け」などと表現される場合が多い。 ドンッ. 「……黙れよ」. このように、命令口調で強引に迫られるのが女性のロマンの"]
text_a = open("./sample_data/girlfriend.txt").readlines.map(&:chomp)
test_h = {}
ti.calc_tf_idf(text_a).each do |row_h|
  row_h.each do |k,v|
    test_h[k] = v
  end
end
#p test_h
test_h.sort_by{|k,v| -v}.each do |row|
  puts "#{row[0]},#{row[1].round(3)}"
end
# vec_a  = ti.get_vector(text_a)
# vec_a.combination(2).each do |combi|
#   p ti.calc_similarity(combi[0], combi[1])
# end
