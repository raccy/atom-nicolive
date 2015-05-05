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

  activate: (state) ->
    console.log atom.config.get('niconico.cookieStoreFile')
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
