#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
sys.path.append(str(Path.home() / "github/utils"))
from bed import read_bed_with_auto_header 


def main():
    parser = argparse.ArgumentParser(description="GTFのIGV画像を自動で撮るためのバッチスクリプトを作る")
    parser.add_argument("-i", "--input", required=True, 
                        help="chrom, start, end, name, score列からなる、nameは画像名、score列はscoreでもなんでもなく撮影したい複数データのパスをカンマでつないだもの")
    parser.add_argument("-o", "--output", required=True, help="出力するIGVバッチファイル名")
    parser.add_argument("--genome", help="ref FASTA、一般的な名前にすると対応するRefSeqが自動で読み込まれるので、適当な名前に変えて指定する")
    parser.add_argument("--base-files", nargs='+', default=False,
                        help="IGV起動時に一度ロードするファイル群 (e.g., GTF, bigWig, VCF)")
    parser.add_argument("-d", "--image_directory", default="results/02/", help="IGV画像の保存先")
    parser.add_argument("--flank", type=int, default=10000, help="Flank size around region [default: 10000]")
    parser.add_argument("--view",choices=["expand", "collapse", "squish"], default="expand", help="IGV表示モード")
    parser.add_argument("--as_pairs", action='store_true')
    parser.add_argument("--sort", action='store_true')
    parser.add_argument("--sleep_time", type=int, default=1000, help="撮影前にxxxミリ秒休む")
    args = parser.parse_args()

    # 出力ディレクトリを用意
    outdir = Path(args.image_directory)
    outdir.mkdir(parents=True, exist_ok=True)

    # 入力BED読み込みscore列でソート（同じcramセットをまとめる）
    df = read_bed_with_auto_header(args.input)
    df = df.sort_values("score")

    # 初期ロードファイル
    lines = ["new"]
    if args.genome:
        lines.append(f"genome {args.genome}")

    #if args.base_files:
    #  lines += [f"load {path}" for path in args.base_files]
    #  lines.append("expand") 
    
    lines.append(f"snapshotDirectory {outdir}")
    lines.append( 'maxPanelHeight 1000000')

    # 各領域でsnapshot
    prev_score = None
    for _, row in df.iterrows():
        chrom, start, end, title, score = row["chrom"], int(row["start"]), int(row["end"]), row["name"], row["score"]

        # cramファイルセットが同じ限り新たなsessionを開いたりcramをロードし直したりしない
        if score != prev_score:
            lines.append("new")
            ## genomeファイル読み込み
            #if args.genome:
            #    lines.append(f"genome {args.genome}")

            # baseファイル読み込み
            if args.base_files:
              lines += [f"load {path}" for path in args.base_files]

            # bam/cramファイル読み込み
            lines += [f"load {path}" for path in score.split(",")]

            # bam/cramファイルを読み込む毎に一度だけする設定
            lines.append(args.view) 
            if args.as_pairs:
                lines.append("viewaspairs")

            prev_score = score

        # 各バリアントの撮影操作
        if args.sort:
            lines.append("sort position")

        region_start = max(0, start - args.flank)
        region_end = end + args.flank

        lines.append(f"goto {chrom}:{region_start}-{region_end}")
        lines.append("scrollToTop")
        lines.append(f"setSleepInterval {args.sleep_time}")
        lines.append(f"snapshot {title}.png")

    lines.append("exit")

    # 出力ファイルに書き込み
    Path(args.output).write_text("\n".join(lines))


if __name__ == "__main__":
    main()
