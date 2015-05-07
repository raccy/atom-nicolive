{CompositeDisposable} = require 'atom'
NiconicoView = require './niconico-view'
path = require 'path'

module.exports = Nicolive =
  niconicoView: null
  subscriptions: null

  config:
    cookieStoreFile:
      title: 'クッキー保存ファイル'
      description: 'クッキーを保存しておくファイルのパスを指定しておいてほしいのです。あ、中身は生のJSONなんで、セキュリティーとかはお察し下さい。'
      type: 'string'
      default: path.join process.env.ATOM_HOME, 'niconico-cookie.json'
    vlcPath:
      title: 'VLCのパス'
      description: 'VLCのパスを設定してくれたまえ。なお、デフォルトはMacでのパスだ。Windowsは捨てろ、Linuxが推奨だ。'
      type: 'string'
      default: '/Applications/VLC.app/Contents/MacOS/VLC'
    rtmpdumpPath:
      title: 'rtmpdumpのパス'
      description: 'rtmpdumpは本家のじゃ動かないッス。https://github.com/meronpan3419/rtmpdump_nicolive または https://github.com/hakatashi/rtmpdump-nico-live の修正版を自分でコンパイルいて入れてね。やり方は自分で考えろ。'
      type: 'string'
      default: '/usr/local/bin/rtmpdump'



  activate: (state) ->
    @niconicoView = new NiconicoView(
        atom.config.get('niconico.cookieStoreFile'))
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'niconico:show': => @show()

  show: ->
    atom.workspace.getActivePane().splitRight().addItem @niconicoView
    @niconicoView.render()

  deactivate: ->
    @subscriptions.dispose()
    @niconicoView.destroy()

  serialize: ->
