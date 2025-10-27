#!/usr/bin/env bash

eval "$(conda shell.bash hook)"
conda activate misc


# 0. 撮影時に移すファイルなどを指定する
SNAPSHOT_REGION_DATA=data/region_or_region_and_data.bed
ANALYSIS_NAME=aaa
REF=data/tmp.fa # 名前をこのようにすればRefseq Selectを勝手に読み込まれなくて済む
MARGIN=5000

BASE_FILES=(
  data/aaa.gtf
  data/gencode.v47.primary_assembly.annotation.sorted.gtf
)

IGV_JIKKOU_SCRIPT=~/IGV_Linux_2.19.5/igv.sh
IGV_BATCH_SCRIPT=results/01/igv_batch_scripts.$ANALYSIS_NAME.txt
IMAGE_DIR=results/02/$ANALYSIS_NAME
LOG1=logs/01/${ANALYSIS_NAME}.log
LOG2=logs/02/${ANALYSIS_NAME}.log


# 1. IGVバッチスクリプトを作る
mkdir -p results/01
mkdir -p $IMAGE_DIR
mkdir -p logs

# パターン1（インプットがchrom, start, end, nameのみ）
scripts/01.py \
  -i $SNAPSHOT_REGION_DATA \
  --genome $REF \
  --base-files  ${BASE_FILES[@]}\
  -o $IGV_BATCH_SCRIPT \
  -d $IMAGE_DIR \
  --flank $MARGIN \
  --view expand \
  > $LOG1 2>&1

# パターン2（インプットがchrom, start, end, data）
scripts/01_data-region_combo.py \
  -i $SNAPSHOT_REGION_DATA \
  -o $IGV_BATCH_SCRIPT \
  -d $IMAGE_DIR \
  --flank $MARGIN \
  --view expand \
  --as_pairs \
  --sort \
  > $LOG1 2>&1
  

# 2. そのスクリプト通りに撮影する
xvfb-run \
  --server-args="-screen 0 2560x1440x24" \
  $IGV_JIKKOU_SCRIPT \
  -b $IGV_BATCH_SCRIPT \
  > $LOG2 2>&1

