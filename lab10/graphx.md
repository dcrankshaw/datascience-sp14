update spark-env.sh, log4j.properties

```scala
import org.apache.spark.graphx._
import org.apache.spark.graphx.lib._
val edgeGraph = GraphLoader.edgeListFile(sc, "/home/saasbook/football_graph/football_edges")


val verts = sc.textFile("/home/saasbook/football_graph/football_verts").map {l =>
  val lineSplits = l.split("\\s+")
  val id = lineSplits(0).trim.toLong
  val data = lineSplits.slice(1, lineSplits.length).mkString(" ")
  (id, data)
}

val g = edgeGraph.outerJoinVertices(verts)({ (vid, _, title) => title.getOrElse("xxxx")})

val prs = PageRank.run(g, 10)
val top10 = g.outerJoinVertices(prs.vertices)({(v, title, r) => (r.getOrElse(0.0), title)}).vertices.top(10)(Ordering.by((entry: (VertexId, (Double, String))) => entry._2._1))

```
