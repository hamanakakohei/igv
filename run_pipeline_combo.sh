#!/usr/bin/env bash
#
# 0. IGVオート撮影用バッチファイルを作るためのインプット（BED-like）を作る
# - SVとSNV/small InDelを撮る時でスクリプトが違うので注意、引数も結構違う
# - SV撮影時は各SVの必要な情報をjoint vcfから取ってくるのでvcfが必要
# - SNV/small InDelはchr,pos,ref.altのみで十分なので
#
# 1. IGVバッチスクリプトを作る
# - 様々なbam/cramの様々な領域を撮る用(インプットがchrom, start, end, name, data (=bam/cramリスト))
# - IGVにfastaを与える際にファイル名から対応するbuildのRefSeq Selectが読み込まれるらしいので、fastaを与えるときは名をtmp.faとかにしておく
#
# 2. 1で作ったバッチスクリプトを動かして撮影する
#
# 3. 画像をサンプルごとにフォルダに入れる
set -euo pipefail
eval "$(conda shell.bash hook)"
conda activate misc


# 0. 各家系で撮影するbam/cramパスのセットを作るためのもとになるファイル
PROBAND_LIST=inputs/probands.txt
PED=inputs/samples.ped
SAMPLE_CRAM_LIST=inputs/sample_cram.txt


# 撮影する領域やアノテーションファイルやらを指定する
IGV_JIKKOU_SCRIPT=~/IGV_Linux_2.19.5/igv.sh
ANALYSIS_NAME=aaa
SNAPSHOT_REGION_DATA=inputs/region.bed
#JOINT_VCF=inputs/joint.vcf.gz
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


## 0 SV ver.
#scripts/00_make_input_for_igv_SV_ver.py \
#  --probands $PROBAND_LIST \
#  --ped $PED \
#  --sample-cram $SAMPLE_CRAM_LIST \
#  --vcf $JOINT_VCF \
#  --call-dir /betelgeuse10/analysis/wgs/analysis/joint/smoove/results/06/ \
#  --prefix results/00/$ANALYSIS_NAME

# 0 SNV ver.
scripts/00_make_input_for_igv_SNV_ver.py \
  --probands $PROBAND_LIST \
  --ped $PED \
  --sample-cram $SAMPLE_CRAM_LIST \
  --call-file-lists inputs/proband_callFile.list \
  --prefix results/00/$ANALYSIS_NAME \
  --margin 50


# 1
scripts/01_data-region_combo_efficient.py \
  -i results/00/$ANALYSIS_NAME.igv_regions.txt \
  --genome $REF \
  --base-files ${BASE_FILES[@]} \
  -o $IGV_BATCH_SCRIPT \
  -d $IMAGE_DIR \
  --flank $MARGIN \
  --view expand \
  --as_pairs \
  --sort \
  > $LOG1 2>&1

  

# 2
xvfb-run \
  --server-args="-screen 0 2560x3000x24" \
  $IGV_JIKKOU_SCRIPT \
  -b $IGV_BATCH_SCRIPT \
  > $LOG2 2>&1


# 3
TMP_DIR=tmpcopy/
mkdir $TMP_DIR

while read -r PROBAND; do
  mkdir -p ${TMP_DIR}${PROBAND}
done < $PROBAND_LIST 

find results/02 -name "*.png" | while read -r IMG; do
  PROBAND=$(basename $IMG | awk -F"_" '{print $1}')
  cp $IMG ${TMP_DIR}${PROBAND}
done
