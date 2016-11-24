#!/bin/bash

###############################
#SBATCH --job-name=myspark
#SBATCH --output=myspark.out
#SBATCH --error=myspark.err
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:30:00
#SBATCH --account=testproj
#SBATCH --partition=fat
#SBATCH --exclusive
###############################

module load java/1.7.0
module load hadoop/2.7.2
module load myhadoop/0.2
module load spark/2.0.0

export JAVA_HOME="/apps/compilers/java/1.7.0/jdk1.7.0_80"
export HADOOP_CONF_DIR=$PWD/hadoop-conf.$SLURM_JOBID
export SPARK_CONF_DIR=$PWD/spark-conf.$SLURM_JOBID

myhadoop-configure.sh -c $SPARK_CONF_DIR -s $WORKDIR/$SLURM_JOBID -i 's/$/-ib/'

source $SPARK_CONF_DIR/spark-env.sh
myspark start

spark-submit --master $MASTER $SPARK_HOME/examples/src/main/python/pi.py 100
spark-submit \
        --class org.apache.spark.examples.SparkPi \
        --master $MASTER_NODE \
#        --total-executor-cores 120 \
        $SPARK_HOME/examples/jars/spark-examples_2.11-2.0.0.jar \
        100

myspark stop
myhadoop-cleanup.sh

# need to fix that
srun killall -9 java
