#sentence-network
テキストファイルの単語の共起やtf-idfを元に文章グラフを作る

##Requirements
```
ruby 2.1.2
neo4j 2.1.5
mecab 0.996
```

##Install
```
$ brew install neo4j mecab mecab-ipadic
$ gem install bundler
$ bundle install --path vendor/bundle
```

##Usage
```
$ neo4j start
$ bundle exec ruby sentence_network.rb LABEL(or TEXT_FILE_PATH)
# `@labels` in `sentence_network.rb` explains LABEL(e.g.`bundle exec ruby sentence_network.rb Cocoppa`)
```

- (1) show ranking of sentences
 - please refer to `./xxx_sentence_rank.txt`

- (2) show graph of sentences
 - please access [http://localhost:7474/](http://localhost:7474/)

[Neo4j's query](http://neo4j.com/docs/stable/cypher-query-lang.html) like this:
```
# find nodes whose similarity is over 0.5
MATCH (n:`label_name`)-[r]->(m)
WHERE r.dos > 0.5
RETURN n AS FROM , r AS `->`, m AS to;

# order by connections desc
MATCH (n:`label_name`)-[r:dos]->c
RETURN n.sentence, count(r) AS connections
ORDER BY connections DESC

# delete all nodes
MATCH (n)
OPTIONAL MATCH (n)-[r]-()
DELETE n,r
```

play!

