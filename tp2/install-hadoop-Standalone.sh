#installing java
echo "sudo apt update " 
sudo apt update 
echo "sudo apt install openjdk-11-jdk -y " 
sudo apt install openjdk-11-jdk -y 
echo "java -version; javac -version " 
java -version

#adding java environement variables
echo 'export PATH=/bin:/usr/bin' >> ~/.profile
echo 'JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
export JRE_HOME
export PATH' >> ~/.profile

downloading hadoop
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
sudo tar -xf hadoop-3.3.4.tar.gz -C /usr/local/
cd /usr/local
# changing permissions to write in hadoop-env.sh file
sudo chmod a+rw hadoop-3.3.4 hadoop-3.3.4/etc hadoop-3.3.4/etc/hadoop hadoop-3.3.4/etc/hadoop/hadoop-env.sh

cd /usr/local/hadoop-3.3.4

#adding hadoop environement variables
echo 'HADOOP_PREFIX=/usr/local/hadoop-3.3.4
PATH=$HADOOP_PREFIX/bin:$PATH
export HADOOP_PREFIX
export PATH' >> ~/.profile
source ~/.profile

# defining parameters in hadoop-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_PREFIX=/usr/local/hadoop-3.3.4' >> ./etc/hadoop/hadoop-env.sh

#creating wordcount java file
echo 'import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {

  public static class TokenizerMapper
       extends Mapper<Object, Text, Text, IntWritable>{

    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();

    public void map(Object key, Text value, Context context
                    ) throws IOException, InterruptedException {
      StringTokenizer itr = new StringTokenizer(value.toString());
      while (itr.hasMoreTokens()) {
        word.set(itr.nextToken());
        context.write(word, one);
      }
    }
  }

  public static class IntSumReducer
       extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();

    public void reduce(Text key, Iterable<IntWritable> values,
                       Context context
                       ) throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      result.set(sum);
      context.write(key, result);
    }
  }

  public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(TokenizerMapper.class);
    job.setCombinerClass(IntSumReducer.class);
    job.setReducerClass(IntSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}' >> ./WordCount.java

# create wordcount jar file
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class

cd input

# downloading input data
#does not work yet
#wget https://www.gutenberg.org/cache/epub/4300/pg4300.txt 

#test files 
echo 'Hello World Bye World'>> file01
echo 'Hello Hadoop Goodbye Hadoop'>> file02

cd ..

# running the application
hadoop jar wc.jar WordCount input output
hadoop fs -cat /user/joe/wordcount/output/part-r-00000

