{CompositeDisposable} = require 'atom'
NiconicoView = require './niconico-view'
path = require 'path'
RtmpPlayer = require './rtmp-player'

module.exports = Niconico =
  niconicoView: null
  subscriptions: null

  config:
    cookieStoreFile:
      title: 'クッキー保存ファイル'
      description:
        'クッキーを保存しておくファイルのパスを指定しておいてほしいのです。' +
        'あ、中身は生のJSONなんで、セキュリティーとかはお察し下さい。'
      type: 'string'
      default: path.join process.env.ATOM_HOME, 'niconico-cookie.json'
    vlcPath:
      title: 'VLCのパス'
      description:
        'VLCのパスを設定してくれたまえ。' +
        'なお、デフォルトはMacでのパスだ。Windowsは捨てろ、Linuxが推奨だ。'
      type: 'string'
      default: '/Applications/VLC.app/Contents/MacOS/VLC'
    rtmpdumpPath:
      title: 'rtmpdumpのパス'
      description:
        'rtmpdumpは本家のじゃ動かないッス。' +
        'https://github.com/hakatashi/rtmpdump-nico-live の修正版を' +
        '自分でコンパイルいて入れてね。' +
        'やり方は自分で考えろ。'
      type: 'string'
      default: '/usr/local/bin/rtmpdump'

  activate: (state) ->
    @rtmpPlayer =
      new RtmpPlayer
        vlcPath: atom.config.get 'niconico.vlcPath'
        rtmpdumpPath: atom.config.get 'niconico.rtmpdumpPath'
    @niconicoView =
      new NiconicoView
        rtmpPlayer: @rtmpPlayer
        cookieStoreFile: atom.config.get 'niconico.cookieStoreFile'

    @subscriptions = {}

    @subscriptions.commands = new CompositeDisposable
    @subscriptions.commands.add atom.commands.add 'atom-workspace',
      'niconico:show': =>
        @show()

    @subscriptions.observe = {}
    @subscriptions.observe.cookieStoreFile =
      atom.config.observe 'niconico.cookieStoreFile', (newValue) =>
        @niconicoView.setCookieStoreFile(newValue)
    @vlcPathObserveSubscription =
      atom.config.observe 'niconico.vlcPath', (newValue) =>
        @rtmpPlayer.setVlcPath(newValue)
    @rtmpdumpPathObserveSubscription =
      atom.config.observe 'niconico.rtmpdumpPath', (newValue) =>
        @rtmpPlayer.setRtmpdumpPath(newValue)

  show: ->
    atom.workspace.getActivePane().splitRight().addItem @niconicoView
    @niconicoView.render()

  deactivate: ->
    @disposeSubscriptions @subscriptions
    @niconicoView.destroy()
    @rtmpPlayer.destroy()

  disposeSubscriptions: (subscriptinos) ->
    if subscriptinos instanceof Object
      @disposeSubscriptions val for own key, val of subscriptinos
    else if subscriptinos instanceof Array
      @disposeSubscriptions val for val of subscriptinos
    else
      subscriptinos.dspose()

  serialize: ->
