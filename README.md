# ニコニコ動画/生放送 パッケージ for Atom

Atomでコーディング中もニコ生の放送が閲覧可能に！
動画だって見えちゃうような気がする！
コメントだって、読み放題かつ書き放題。
もう、Atomさえあれば何もいらない。

という、誰得パッケージです。

使っている物とか

* video-player ぱくって魔改造
* rtmpdump-nico-live 必須
* VLC 必須

当面の目標

* [x] とりあえずログインできるようにする。
* [ ] 生放送を閲覧する。
    rtmpdump-nico-live | VLC | (TCP/IP) | Atom (chromium)
    * [x] ユーザー生放送
    * [ ] コミュ指定
    * [ ] 公式
    * [ ] チャンネル
    * [ ] タイムシフトを閲覧する。
* [ ] コメントを閲覧する。
* [ ] コメントを書き込む。
* [ ] 動画を閲覧する。
* [ ] やっぱ、名前変えたい Atom Nicovideoあたりで

更なる目標

* [ ] shdow dom化

作る物

* [ ] ニコニコ動画の情報を表示/管理する。NiconicoView

問題点とか

* [ ] リロード「ctrl-cmd-r」しないとうまく画面が
* [ ] 画像がでるの遅い
* [ ] 停止するとエラーにナル

    > events.js:141
    > Hide Stack Trace
    > Error: write EPIPE
    >   at Object.exports._errnoException (util.js:734:11)
    >   at exports._exceptionWithHostPort (util.js:757:20)
    >   at WriteWrap.afterWrite (net.js:753:14)

* [x] NLEでの放送だと音声がとぎれるっぽい。
    OGG->WebMに変更したら、画像も綺麗になったし、途切れも無くなった。
    バッファも1000ミリ秒ぐらいあったらイケルっぽい。
* [ ] ラグがひどい。たぶん、無理。
