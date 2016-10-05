#!/bin/bash

###############################
#SBATCH --job-name=hadoop
#SBATCH --output=hadoop.out
#SBATCH --error=hadoop.err
#SBATCH --ntasks=2
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:30:00
#SBATCH --account=testproj
#SBATCH --partition=fat
#SBATCH --exclusive
###############################


module load java/1.7.0
module load hadoop/2.7.2
module load myhadoop/0.2

export JAVA_HOME="/apps/compilers/java/1.7.0/jdk1.7.0_80"
export HADOOP_CONF_DIR=$PWD/hadoop-conf.$SLURM_JOBID

myhadoop-configure.sh -c $HADOOP_CONF_DIR -s $WORKDIR/$SLURM_JOBID -i 's/$/-ib/'

start-dfs.sh
start-yarn.sh

# Create the HDFS directories required to execute MapReduce jobs:
hdfs dfs -mkdir  /user
hdfs dfs -mkdir  /user/${USER}

# Copy the input files into the distributed filesystem:
hdfs dfs -put ${HADOOP_HOME}/etc/hadoop input

# Map reduce example

hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar grep input output 'dfs[a-z.]+'

# Copy the output files from the distributed filesystem to the local filesystem
hdfs dfs -get output ./
hdfs dfs -cat output/*

stop-dfs.sh
stop-yarn.sh

myhadoop-cleanup.sh

# need to fix that
srun killall -9 java


