#!/usr/bin/env ruby
#-*- coding:utf-8 -*-
require 'neography'
@neo = Neography::Rest.new

# ノード作成
node1 = @neo.create_node(name: "tanaka", age: 20)
node2 = @neo.create_node(name: "suzuki", age: 24)

# ノードにプロパティを追加
@neo.set_node_properties(node1, {weight: '60kg'})

# 関係を追加（node1 -> node2 方向）
@neo.create_relationship(:friend, node1, node2)

# 関係を取得
@neo.get_node_relationships(node1, :out, :friend)
@neo.get_node_relationships(node2, :in, :friend)
