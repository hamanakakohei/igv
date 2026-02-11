#!/usr/bin/env python3
import pandas as pd
from pathlib import Path
import argparse


def main():
    parser = argparse.ArgumentParser(description="Prepare IGV snapshot regions for SNV & small InDel")
    parser.add_argument("--probands", required=True)
    parser.add_argument("--ped", required=True)
    parser.add_argument("--sample-cram", required=True, help="サンプル<TAB>CRAMパス")
    parser.add_argument("--call-file-lists", required=True,
                        help="プロバンド名<TAB>コールリストファイルパス（コールリストはchr<tab>pos<tab>ref<tab>altでヘッダーなし）")
    parser.add_argument("--prefix", required=True)
    parser.add_argument("--margin", type=int, nargs="+",
                        default=[1000, 5000])
    args = parser.parse_args()

    # 読み込み
    probands = pd.read_csv(args.probands, header=None, names=["proband"])
    ped = pd.read_csv( args.ped, sep="\t", header=None, names=["FID", "IID", "father", "mother", "sex", "pheno"], dtype=str)
    cram_df = pd.read_csv(args.sample_cram, sep="\t", header=None, names=["IID", "cram"])

    # proband → call file 対応
    call_map = pd.read_csv(args.call_file_lists, sep="\t", header=None, names=["proband", "call_file"]).\
        set_index("proband")\
        ["call_file"].\
        to_dict()


    # 発端者毎に
    records = []

    for _, p_row in probands.iterrows():
        proband_id = p_row["proband"]
        calls = pd.read_csv(call_map[proband_id], sep="\t", header=None, names=["chr", "pos", "ref", "alt"])

        family_id = ped.loc[ped["IID"] == proband_id, "FID"].values[0]
        family_members = ped.loc[ped["FID"] == family_id, "IID"].tolist()

        cram_paths = cram_df.loc[
            cram_df["IID"].isin(family_members),
            "cram"
        ].tolist()
        cram_str = ",".join(cram_paths)

        # バリアントごとに
        for _, v_row in calls.iterrows():
            chrom = str(v_row["chr"])
            pos = int(v_row["pos"])
            ref = str(v_row["ref"])
            alt = str(v_row["alt"])

            if len(ref) > len(alt):  # deletion
                start = pos
                end = pos + len(ref) - 1
            else:  # SNV or insertion
                start = pos
                end = pos

            variant_id = f"{chrom}_{pos}_{ref}_{alt}"

            for m in args.margin:
                region_start = max(1, start - m)
                region_end = end + m
                name = f"{proband_id}_{variant_id}_m{m}"

                records.append([chrom, region_start, region_end, name, cram_str])

    out_df = pd.DataFrame(records, columns=["chr", "start", "end", "name", "cram_paths"])
    out_df.to_csv(f"{args.prefix}.igv_regions.txt", sep="\t", index=False, header=False)

if __name__ == "__main__":
    main()
