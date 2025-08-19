#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path

sys.path.append(str(Path.home() / "github/utils"))
from bed import read_bed_with_auto_header 


def main():
    parser = argparse.ArgumentParser(description="GTFのIGV画像を自動で撮るためのバッチスクリプトを作る")
    parser.add_argument("-i", "--input", required=True, help="撮る領域のBEDファイル (少なくとも chrom, start, end, name 列を含む)")
    parser.add_argument("-o", "--output", required=True, help="出力するIGVバッチファイル名")
    parser.add_argument("--genome", help="ref FASTA、一般的な名前にすると対応するRefSeqが自動で読み込まれるので、適当な名前に変えて指定する")
    parser.add_argument("--base-files", nargs='+', required=True,
                        help="IGV起動時に一度ロードするファイル群 (e.g., GTF, bigWig, VCF)")
    parser.add_argument("-d", "--image_directory", default="results/02/", help="IGV画像の保存先")
    parser.add_argument("--flank", type=int, default=10000, help="Flank size around region [default: 10000]")
    parser.add_argument("--view",choices=["expand", "collapse", "squish"], default="expand", help="IGV表示モード")
    args = parser.parse_args()

    # 出力ディレクトリを用意
    outdir = Path(args.image_directory)
    outdir.mkdir(parents=True, exist_ok=True)

    # 入力BED読み込み
    df = read_bed_with_auto_header(args.input)

    # 初期ロードファイル
    lines = ["new"]
    if args.genome:
        lines.append(f"genome {args.genome}")

    lines += [f"load {path}" for path in args.base_files]
    lines.append(f"snapshotDirectory {outdir}")
    lines.append( 'maxPanelHeight 100000')

    # 各領域でgotoとsnapshot
    for _, row in df.iterrows():
        chrom, start, end, title = row["chrom"], int(row["start"]), int(row["end"]), row["name"]
        region_start = max(0, start - args.flank)
        region_end = end + args.flank
        lines.append(f"goto {chrom}:{region_start}-{region_end}")
        lines.append(args.view)   # expand / collapse / squish を選択
        lines.append("scrollToTop")
        lines.append(f"snapshot {title}.png")

    lines.append("exit")

    # 出力ファイルに書き込み
    Path(args.output).write_text("\n".join(lines))


if __name__ == "__main__":
    main()
