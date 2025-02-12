name := "Hello ScalaFX"

scalaVersion := "3.6.3"

scalacOptions ++= Seq("-unchecked", "-deprecation", "-Xcheckinit", "-encoding", "utf8")

libraryDependencies ++= Seq(
	"org.scalafx" %% "scalafx" % "22.0.0-R33",
	"org.apache.poi" % "poi-ooxml" % "5.2.3",
	"org.scala-lang.modules" %% "scala-xml" % "2.3.0",
	"org.scalatest" %% "scalatest" % "3.2.19" % "test"
	)

resolvers ++= Opts.resolver.sonatypeOssSnapshots

// Fork a new JVM for 'run' and 'test:run', to avoid JavaFX double initialization problems
fork := true