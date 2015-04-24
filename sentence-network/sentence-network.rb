#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
#テキストデータから文書ネットワーク(neo4j)を作成
require './collocation-similarity'
require 'active_support/core_ext/object/blank'
require 'neography'
require './tf-idf'

class SentenceNetwork
  def initialize(data_name)
    @neo              = Neography::Rest.new
    @cs               = CollocationSimilarity.new
    @ti               = TfIdf.new
    @nodes            = {} #{"文番号"=>"ノード番号"}
    @REGEX_COMMA      = "[、､,]$"
    @REGEX_PERIOD     = "[。．？！!?]"
    @EXCLUDE_TXT_PATH = "./dic/stopword.txt"
#    @exclude_words = get_exclude_words
    @over_dos         = 0.2 #エッジで結ぶ類似度の閾値

    @LABELS = {
      "Test"           => "./sample_data/test.txt",
      "Cocoppa"        => "./sample_data/cocoppa.txt",
      "Decollage"      => "./sample_data/decollage.txt",
      "DragonsShadow"  => "./sample_data/dragonsshadow.txt",
      "PocketLand"     => "./sample_data/pocketland.txt",
      "PuyoPuyo"       => "./sample_data/puyopuyo.txt",
      "ChainChronicle" => "./sample_data/chainchronicle.txt",
      "Canmake"        => "./sample_data/canmake.txt",
      "Haba"           => "./sample_data/haba.txt"
    }
    if @LABELS.key?(data_name)
      @data_name  = data_name
      @input_path = @LABELS[@data_name]
    else
#      @data_name = Time.now.strftime("%Y%m%d%H%M%S").gsub(/^\d\d/,"")
      @data_name  = ARGV[0].gsub(/^.*\/|\.txt$/, "")
      @input_path = data_name
    end
  end

  def get_exclude_words
    stopwords = {}
    open(@EXCLUDE_TXT_PATH).readlines.map(&:chomp).each do |stopword|
      stopwords[stopword] = ""
    end
    return stopwords
  end

  #文章の配列を受け取り、句点終わりの文を次の文と結合させた配列を返す
  def resolve_texts(texts)
    resolved_texts = []
    skip_flag      = {}
    texts.each_with_index do |text, i|
      skip_flag[i] = false
    end
    texts.each_with_index do |text, i|
      next if skip_flag[i]
      if text =~ /#{@REGEX_COMMA}/
        skip_flag[i+1] = true
        resolved_texts << text+texts[i+1]
      else
        resolved_texts << text
      end
    end
    return resolved_texts
  end

  #読点終わりの要素がなくなったらtrue
  def stop?(array)
    array.find_all { |item| item =~ /#{@REGEX_COMMA}/ }
  end

  #入力Stringを解析して文に分割後、配列化
  def get_sentences
    texts = open(@input_path).readlines.map(&:chomp).reject(&:blank?)
    catch(:break_loop) do
      loop do
        texts = resolve_texts(texts)
        throw :break_loop if stop?(texts)
      end
    end
    sentences         = texts.map { |text| text.split(/(?<=#{@REGEX_PERIOD})/) }.flatten
    cleaned_sentences = sentences.map { |sentence|
      sentence
        .gsub(/[『』「」【】\"◆◇■□＊▼▲▽△※“”～●★☆*]|\.{2,}|-{2,}/, "") #飾り文字除去
        .gsub(/^[・　。\)]|[[:blank:]]+/, "") #文頭記号除去
        .gsub(/[A-Za-z0-9]+[\w-]+@[\w\.-]+\.(\w{2,})?/, "") #メルアド除去
    }.reject { |item| item.blank? || item =~ /^#{@REGEX_PERIOD}+$/ } #文頭記号のみは全除去

    result = []
    cleaned_sentences.each.with_index(1) do |text, i|
      result << "#{i}:::#{text}"
    end
    return result
  end

  #str_pairの文を登録しそのノード番号を返す
  def create_node(str_pair)
    #登録済の場合
    if @nodes[str_pair[0]]
      return n = @nodes[str_pair[0]]
    #新規登録の場合
    else
      n = @neo.create_node(:sentence => str_pair[1])
      @neo.add_label(n, @data_name)
      #作成したらそのノード番号を記録
      @nodes[str_pair[0]] = n
      return n
    end
  end

  #全組み合わせのコサイン類似度を出してneo4jに登録
  def main
    sentences_h = {}
    sentences   = get_sentences

    tf_idf_h = {}
    target_text = ""

    doubles = sentences.combination(2).collect { |arr| arr }
    sentences.each do |kuririn_txt|
      pair                    = kuririn_txt.split(":::")
      sentences_h[pair.first] = pair.last
    end

    ###tf-idf版は以下をコメントイン###
    # s_a = sentences_h.values
    # @ti.get_vector(s_a).each_with_index { |vec, i| tf_idf_h[s_a[i]] = vec }
    ###tf-idfここまで###

    ###tf-idf x co-occurrence###実質tf-idf
#    target_text = sentences_h.values.join
#    tf_idf_h    = @ti.calc_tf_idf(target_text)
    ###it-idf x co-occurrenceここまで###

    doubles_num = doubles.size

    #既存のグラフだったら初期化
    @neo.execute_query("MATCH (n:`#{@data_name}`) OPTIONAL MATCH (n)-[r]-() DELETE n,r")

    #全ペアループ
    c=0 #connection count
    doubles.each.with_index(1) do |strs, i|
      str1pair = strs[0].split(":::")
      str2pair = strs[1].split(":::")

      #文をノードとして登録, 登録済ならそのノードを返す
      n1       = create_node(str1pair)
      n2       = create_node(str2pair)

      dos = @cs.calc_score(str1pair[1], str2pair[1], tf_idf_h, target_text) #類似度

      ###tf-idf版は以下をコメントイン###
      # dos = @ti.calc_similarity(tf_idf_h[str1pair[1]], tf_idf_h[str2pair[1]])
      ###tf-idfここまで###

      #ノード間(n1,n2)を類似度で紐付ける
      unless dos<=0.0 || dos.nan?
        if dos >= @over_dos
          puts "#{dos}\t#{i}/#{doubles_num}\t#{c+=1}"
          rel = @neo.create_relationship("dos", n1, n2)
          @neo.set_relationship_properties(rel, { "dos" => dos })
        end
      end
    end

    # CSV形式で出力
    result      = @neo.execute_query("MATCH (n:`#{@data_name}`)-[r:dos]->c RETURN n.sentence, count(r) AS connections ORDER BY connections DESC")
    columns     = result["columns"]
    data        = result["data"]
    output_name = "#{@data_name}_sentence_rank.txt"
    open("result/#{output_name}", "w+") do |f|
      f.puts "#{columns[0]},#{columns[1]}"
      data.each do |sentence, connections|
        f.puts "#{sentence},#{connections}"
      end
    end
    puts "--------------------------"
    puts "`#{output_name}` was created !!"
  end
end

sn = SentenceNetwork.new(ARGV[0])
sn.main

__END__
"Cocoppa" => "./data/cocoppa.txt",
"Decollage" => "./data/decollage.txt",
"DragonsShadow" => "./data/dragonsshadow.txt",
"PocketLand" => "./data/pocketland.txt"
