## Scala Instructions   
### 1. Optimization Ideas   
Since Scala is the native API of Spark, I wanted to try using Scala on Spark for all parts of our architecture except the URL scraping. It is true that this performance is very noticeable when using CLI/REPL (pyspark versus spark-shell), but did not try using spark-submit with .py files for a benchmark. Based on what I have studied so far, Scala is bound to have some advantage with performance, but Python has its own advantages for having an easier learning curve. Since Spark exposes Scala as well as Python API, there are some interesting issues to consider:

- when using RDDs, or tools like Zeppelin, I noticed Scala's awesomeness; definitely a better experience than pyspark
- when using DataFrames,  the difference between the CLIs becomes less noticeable; since DataFrames are far easier to work with than RDDs, Scala may not have that big of an edge over Python here
- when you want Data Science libraries, Python beats Scala hands down; you name a need, there is a pip install for that!
- when you have to tweak Spark at a lower level, Scala would become a natural choice
- when you want to use AWS JDK, Scala works well; since Scala and Java run on JVMs there is a lot of interoperability. It is not very difficult to look at a Java implementation involving the Hadoop-AWS ecosystem and converting it to Scala code. In fact with minor syntax modifications, I could copy/paste AWS Java SDK to test functionality on scala REPL or spark-shell
- the biggest disadvantage was the difficulty in building the Scala code. You need a jar file and the dependencies must be clarified in excruciating detail. Writing the first build.sbt and working with sbt-assembly plug-in was the death of me during the week of thanksgiving. Some familiarity with functional programming style would definitely make life easier. I advise anyone to first get quite familiar with the Scala syntax to save yourself the grief.
- on the other hand, if you are using the Python API, you just need to supply a .py file for spark-submit :)
- finally, I would say that you cannot go wrong with Scala on Spark; you get a lot of flexibility and the fantastic JVM platform to work with; occasionally there will be something that Spark Scala API allows that Python API will not or cannot (example: in Spark Streaming, Scala supports a more generic FileStream as a source whereas Python API only supports TextFileStream).
- given the rate at which the Spark community as well as the code base is growing, these differences between APIs may become more trivial and we will end up choosing for 1) performace and 2) skill set of the developer/data scientist

### 2. Build & Deploy on Spark   
These instructions are for those who wish to work on the source, test it and build it for themselves. For simply invoking the script to test the application as part of the project architecture, see instructions in the section 3 (Scripts for the Scala/Spark App).   
##### Install SBT   
SBT is the build tool for scala. You can of course use maven or some other tool you are familiar with. Since SBT seems tightly integrated with Scala, I decided to learn it as well.   
```
> curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo   
> sudo yum install sbt   
> export PATH=/data/sbt/bin/sbt:$PATH   
```

##### Config
Build tools such as SBT and MAVEN assume a certain directory structure. A lot of information is available elsewhere, and I will not focus on that here. The only point worth emphasizing is this: its not worth it to tinker with the way the project is set-up unless you are familiar with building applications like these.   

```
<top-level-directory>
    <spark-submit invoking script>
    build.sbt
    +src
        +main
            +scala
                +<your package directory 1..n, usually not more than 3 or 4>
                    <your scala class>
    +project
        assembly.sbt
    +target
        +scala<version>
            <jar files>
```

__build.sbt__   
This requires a special mention. This is the blue print sbt needs to package the scala app into a jar. This means, we have to specify where to find libraries and how to resolve dependencies in the correct order. Sometimes, conflicting versions of a library or a class could exist within the same project and resolving strategies must be specified. A cleaner approach would be look into clashes and adjust dependencies to remove those clashes. However, due to time constraints, I have taken the approach of specifying "take the first one"  or  "take the last one" or "merge if no conflict" etc. This is copy/paste from various resources and not super thoughtful on my part. So, it may mention libraries that are not even used by our app. (Will clean up if time permits).

__assembly.sbt__    
This files is stored under the project folder so that sbt can recognize this as a plug-in. This plug-in makes life simple by resolving the clashes and dependencies between libraries I mentioned above. If you want to learn more about it, you should look up sbt-assembly (github repo).

__Commands__   
In order to build the project, I followed a two step process. This may not be needed for all kinds of scala apps or scala/spark apps. This is just something that worked for me and felt intuitive.   
```
> rm target/scala-2.11/*.jar
> sbt package
> sbt assemblyPackageDependency
```
The two commands will generate two jar files. One is the app packaged as a jar. The other is all the external dependencies packaged as single fat jar making it super easy to invoke spark-submit with necessary libraries.   
SBT will put these jar files in <project top level directory>/target/scala<version given in build.sbt>/. Take a moment and notice the naming pattern of these jar files. Once you are familiar with that you can easily write scripts without having to refer back to the jar file names.   
Note: SBT will create many other files/folders under target as well as project. No need to worry about them. They are cached libraries etc to make things faster for SBT. However, please do not check them into github. 

__JAR Files__   
In order to make it easy for everyone to not have to build, and because I am not too savvy yet with managing builds across users who have their own environments, I have simply added the jars into github repo with a .mask extension. Again, if time permits, we can add SBT to either the AMI or to the provisioning script and that should simply build all the necessary jars for us.

__Spark-Submit Scripts__   
These scripts simply invoke spark-submit. You have to supply some information for the SparkConf(remember we are outside of the spark-shell or pyspark CLI and we need to start SparkContext, SQLContext, StreamingContext and HiveContext in our program. 

### 3. Scripts for the Scala/Spark App
In order to test the apps individually or to invoke them as part of a scheduler, simply invoke the scripts below:
(I used the DataBricks Spark reference implementation to build this out.)
> Collect Tweets:   
```
> cd /data/<w205Project_HOME>/spark/scala/collect_tweets/
> su w205
> bash start-tweet-collection.sh
```
> TODO - Currently running on Zeppelin NB    
> Train Model:
```
> cd /data/<w205Project_HOME>/spark/scala/learn_spam/
> su w205
> bash start-training-model.sh
```
> TODO - Needs cleanup & testing 
> Classify Tweets:
```
> cd /data/<w205Project_HOME>/spark/scala/classify_tweets/
> su w205
> bash start-streaming-classification.sh
```   
__Spark Process Monitoring__   
You can monitor the spark jobs by using the EC2 public DNS:
http://<aws ec2 instance>.compute-1.amazonaws.com:4040/jobs/

### 4. A Zeppelin Dashboard
Using Zeppelin it is easy to create a nice report. However Zeppelin does not work well with different versions on Spark installations. I had to get the code from github and rebuild the source (the fix applied on Nov 22, 2015 will allow us to run zepellin from our AMI).
