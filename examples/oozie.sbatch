#!/bin/bash

###############################
#SBATCH --job-name=oozie
#SBATCH --output=oozie.out
#SBATCH --error=oozie.err
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
module load oozie/4.2.0

export JAVA_HOME="/apps/compilers/java/1.7.0/jdk1.7.0_80"
export HADOOP_CONF_DIR=$PWD/hadoop-conf.$SLURM_JOBID

myhadoop-configure.sh -c $HADOOP_CONF_DIR -s $WORKDIR/$SLURM_JOBID -i 's/$/-ib/'

hdfs getconf -namenodes

start-dfs.sh
start-yarn.sh

hdfs dfs -mkdir  /user
hdfs dfs -mkdir  /user/${USER}

hdfs dfs -put ${OOZIEROOT}/examples examples


ooziedb.sh create -sqlfile oozie.sql -runValidate DB Connection.
oozied.sh start

ozie admin -oozie http://localhost:11000/oozie -status
#oozie job -oozie http://localhost:11000/oozie -config examples/apps/spark/job.properties -run
oozie job -oozie http://localhost:11000/oozie -config examples/apps/map-reduce/job.properties -run

oozied.sh stop
stop-dfs.sh
stop-yarn.sh

myhadoop-cleanup.sh

# need to fix that
srun killall -9 java


