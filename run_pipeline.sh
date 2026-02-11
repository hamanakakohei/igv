#!/usr/bin/env bash
#
# 0. IGVオート撮影用バッチファイルを作るためのインプット（4列目までのBED）を作る
# - 4列目がその画像の名前に使われる
#
# 1. IGVバッチスクリプトを作る
# - 固定されたbase filesの様々な領域を撮る用（インプットがchrom, start, end, name）
# - IGVにfastaを与える際にファイル名から対応するbuildのRefSeq Selectが読み込まれるらしいので、fastaを与えるときは名をtmp.faとかにしておく
#
# 2. 1で作ったバッチスクリプトを動かして撮影する
set -euo pipefail
eval "$(conda shell.bash hook)"
conda activate misc


# 撮影する領域やアノテーションファイルやらを指定する
IGV_JIKKOU_SCRIPT=~/IGV_Linux_2.19.5/igv.sh
ANALYSIS_NAME=aaa
SNAPSHOT_REGION_DATA=inputs/region.bed
MARGIN=5000
BASE_FILES=(
  inputs/aaa.gtf
  inputs/gencode.v47.primary_assembly.annotation.sorted.gtf
)
REF=inputs/tmp.fa


# 結果やログのディレクトリの準備
IGV_BATCH_SCRIPT=results/01/igv_batch_scripts.$ANALYSIS_NAME.txt

IMAGE_DIR=results/02/$ANALYSIS_NAME
LOG1=logs/01/${ANALYSIS_NAME}.log
LOG2=logs/02/${ANALYSIS_NAME}.log
mkdir -p results/01
mkdir -p $IMAGE_DIR
mkdir -p logs


# 1. IGVバッチスクリプトを作る
scripts/01.py \
  -i $SNAPSHOT_REGION_DATA \
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
