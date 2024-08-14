#!/bin/sh
# SGE options (lines prefixed with #$)
#$ -N runMarkDups.sh
#$ -cwd
#$ -l h_rt=48:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 4 
#$ -hold_jid runBWA.sh
#$ -t 1:n # amend to how many samples you have
#$ -P #add in priority if applicable 
#$ -e e_dups
#$ -o o_dups

# Initialise the environment modules
. /etc/profile.d/modules.sh
source /exports/applications/apps/community/roslin/conda/4.9.1/etc/profile.d/conda.sh
conda activate mapstats 

#load modules 
module load roslin/samtools/1.16
module load roslin/bedtools/2.29.2

#define dirs
target_dir=/path/to/input/dir
picard=/path/to/picard.jar

#define vars 
sample_list=/path/to/samlist.txt

#define sample name 
base=`sed -n "$SGE_TASK_ID"p $sample_list | awk '{print $1}'`

#process
echo Processing sample: ${base} on $HOSTNAME

#mark dups
java -Xmx10g -jar $picard MarkDuplicates \
INPUT=$target_dir/${base}.aln.map.sorted.bam \
OUTPUT=$target_dir/${base}.aln.map.sorted.dedup.bam  \
REMOVE_DUPLICATES=true \
METRICS_FILE=$target_dir/${base}.metrics.txt \
TMP_DIR=tmp

#index 
samtools index $target_dir/${base}.aln.map.sorted.dedup.bam
 
#getstats  
samtools flagstat $target_dir/${base}.aln.map.sorted.dedup.bam > $target_dir/${base}.flagstat.txt
bedtools genomecov -ibam $target_dir/${base}.aln.map.sorted.dedup.bam > $target_dir/${base}.cov.txt
mosdepth -n -t 4 -Q30 $target_dir/${base} $target_dir/${base}.aln.map.sorted.dedup.bam 
#multiqc $target_dir
