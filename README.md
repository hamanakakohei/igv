# igv

01.sh：あるファイルについて、多くの領域のigv画像を作るスクリプト。インプットはBEDで4列目（撮影画像名）までを使うが、それ以上の列があっても問題ない。
01_data_region_combo.sh：複数のファイルと複数の撮影領域の組み合わせがある場合。インプットはBEDでも何でも無いがBED風の5列で、4列目が撮影画像名、5列目が撮りたい複数ファイルを「,」でつなげたもの。


参考：
- 似たような物がすでにあった、https://cmatkhan.github.io/brentlabRnaSeqTools/reference/createIgvBatchscript.html
- https://github.com/andreykuzin70/batch_igv
- https://t-arae.blog/posts/2024/2024-12-25-igv-batch-script/
- https://github.com/stevekm/IGV-snapshot-automator
- https://janbio.home.blog/2020/09/16/igv-batch-snapshot-from-command-line/
- https://gist.github.com/stevekm/ac76c0c2fa4ee89db8ce2421cc6fbffc
- https://igv.org/doc/desktop/#UserGuide/tools/batch/
- etc.
調べればいくらでも出てきそう、自分で作る必要なかった、、、
