#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate misc


# 0. 撮影時に移すファイルなどを指定する
BED_SNAPSHOT=data/region_of_interest.bed
#BED_SNAPSHOT=data/tx_genic_mono-exon_918.bed
#BED_SNAPSHOT=data/tx_genic_multi-exon_237.bed
#BED_SNAPSHOT=data/tx_nnc_ir_2764.bed
#BED_SNAPSHOT=data/tx_nnc_new_ss_14197.bed
ANALYSIS_NAME=aaa
REF=data/tmp.fa # 名前をこのようにすればRefseq Selectを勝手に読み込まれなくて済む
MARGIN=5000

BASE_FILES=(
  data/aaa.gtf
  data/gencode.v47.primary_assembly.annotation.sorted.gtf
  data/gm24_gencodev47.chr.scaffold.444141isoforms.geneid_corrected.novel_55580.sorted.gtf
  data/gm24_gencodev47.chr.scaffold.444141isoforms.geneid_corrected.nnc_ir_2764.sorted.gtf
  data/gm24_gencodev47.chr.scaffold.444141isoforms.geneid_corrected.nnc_new_ss_14197.sorted.gtf
  data/gm24_gencodev47.chr.scaffold.444141isoforms.geneid_corrected.nnc_new_ss_14197.mod.sorted.gtf
  data/gm24_gencodev47.chr.scaffold.444141isoforms.geneid_corrected.novel_loci_2202.gsorted.tf
  data/gm24_gencodev47.chr.scaffold.444141isoforms.geneid_corrected.genic_mono-exon_918.sorted.gtf
  data/gm24_gencodev47.chr.scaffold.444141isoforms.geneid_corrected.genic_multi-exon_237.sorted.gtf
)

IGV_JIKKOU_SCRIPT=~/IGV_Linux_2.19.5/igv.sh
IGV_BATCH_SCRIPT=results/01/igv_batch_scripts.$ANALYSIS_NAME.txt
IMAGE_DIR=results/02/$ANALYSIS_NAME
LOG1=logs/01.${ANALYSIS_NAME}.log
LOG2=logs/02.${ANALYSIS_NAME}.log


# 1. IGVバッチスクリプトを作る
mkdir -p results/01
mkdir -p $IMAGE_DIR
mkdir -p logs

scripts/01.py \
  -i $BED_SNAPSHOT \
  --genome $REF \
  --base-files  ${BASE_FILES[@]}\
  -o $IGV_BATCH_SCRIPT \
  -d $IMAGE_DIR \
  --flank $MARGIN \
  --view expand \
  > $LOG1 2>&1


# 2. そのスクリプト通りに撮影する
xvfb-run \
  --server-args="-screen 0 2560x1440x24" \
  $IGV_JIKKOU_SCRIPT \
  -b $IGV_BATCH_SCRIPT \
  > $LOG2 2>&1

