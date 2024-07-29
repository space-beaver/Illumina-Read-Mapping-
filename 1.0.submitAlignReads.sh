#!/bin/sh
#$ -N runBWA.sh 
#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=8G
#$ -P  #add in priority if you have 
#$ -t 1:n # amend to how many samples you have 
#$ -pe sharedmem 4
#$ -hold_jid runTrimReads.sh #script will wait until this job is finished 
#$ -e e_bwa
#$ -o o_bwa 

# Initialise the environment modules
. /etc/profile.d/modules.sh
module load roslin/samtools/1.16

#define vars
bwa_dir=/path/to/bwakit/ #or add to PATH
fastq_dir=/indir/path
out_dir=/outdir/path
sample_list=/path/to/samlist.txt #list of file names 
refgen=/path/to/indexed/genome

#get sample lists
base=`sed -n "$SGE_TASK_ID"p $sample_list | awk '{print $1}'`

#process
echo Processing sample: ${base} on $HOSTNAME

#align 
$bwa_dir/run-bwamem -d -t 4 -o $out_dir/${base} -HR"@RG\tID:${base}\tSM:${base}" $refgen $fastq_dir/${base}_R1_001_val_1.fq.gz $fastq_dir/${base}_R2_001_val_2.fq.gz | sh

#remove unmapped reads
samtools view -b -F 4 $out_dir/${base}_$SGE_TASK_ID.aln.bam  > $out_dir/${base}_$SGE_TASK_ID.aln.map.bam 

#for some reason bwa.kit sort gives an error so do separately
samtools sort $out_dir/${base}_$SGE_TASK_ID.aln.map.bam -o $out_dir/${base}_$SGE_TASK_ID.sorted.bam

#index
samtools index -@ 4 $out_dir/${base}_$SGE_TASK_ID.sorted.bam #change to match file name 

