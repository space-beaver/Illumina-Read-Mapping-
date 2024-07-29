#!/bin/sh
# Grid Engine options
#$ -N runTrimReads.sh
#$ -cwd 
#$ -l h_rt=10:00:00
#$ -l h_vmem=8G
#$ -t 1-n #change this value to however many fastqs you have 
#$ -pe sharedmem 2
#$ -e e_trim
#$ -o o_trim 

# Jobscript to run trim_galore

#initialise modules and conda 
. /etc/profile.d/modules.sh

#load modules and conda env
module load roslin/conda/23.7.2
source /exports/applications/apps/community/roslin/conda/4.9.1/etc/profile.d/conda.sh
conda activate trim_galore 

#define dirs
target_dir=/path/to/dir/
sample_list="/path/to/samlist.txt" # see example file samlisttrim.txt

#get filelist
base=`sed -n "$SGE_TASK_ID"p $sample_list | awk '{print $1}'`
R1=`sed -n "$SGE_TASK_ID"p $sample_list | awk '{print $2}'`
R2=`sed -n "$SGE_TASK_ID"p $sample_list | awk '{print $3}'`

#process
echo Processing sample: ${base} on $HOSTNAME
echo Processing $R1
echo Processing $R2

trim_galore --paired --fastqc -q 30 -j 4 $target_dir/$R1 $target_dir/$R2 

#remove original files 
#rm $R1 $R2 #careful with this :) 
