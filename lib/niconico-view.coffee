{$, $$$, ScrollView} = require 'atom-space-pen-views'
NiconicoApi = require './niconico-api'
NicovideCommentView = require './Niconico-comment-view'
fs = require 'fs'

module.exports =
class NiconicoView extends ScrollView
  @content: ->
    @div {
      class: 'niconico-view native-key-bindings block'
      overflow: 'auto'
      tabindex: -1
    }, =>
      @div outlet: 'topPanel', =>
        @text 'ID:'
        @span outlet: 'userId', '-'
        @text ' '
        @span outlet: 'userName', '未ログイン'
        @button
          outlet: 'logoutButton', click: 'clickLogout', style: 'display:none',
          'ログアウト'
      @div outlet: 'alertPanel', style: 'display:none', class: 'alert'
      @div outlet: 'loginPanel', style: 'display:none', =>
        # @h2 'ニコニコ動画ログイン'
        @form =>
          @fieldset =>
            @legend 'ニコニコ動画ログイン'
            @div =>
              @label 'メールアドレス'
              @input
                outlet: 'loginMail', name: 'mail_tel', type: 'text',
                placeholder: 'hoge@example.jp'
            @div =>
              @label 'パスワード'
              @input
                outlet: 'loginPassword', name: 'password', type: 'password',
                placeholder: 'password'
            @div =>
              @button click: 'clickLogin', 'ログイン'
      @div outlet: 'menuPanel', style: 'display:none', =>
        @form =>
          @fieldset =>
            @legend 'クイック視聴'
            @input
              outlet: 'quickMovie', name: 'quick_movie', type: 'text',
              placeholder: 'lv... / co... / sm...'
            @button click: 'clickQuickPlay', '視聴'
        @div =>
          @h3 '生放送中一覧'
          @ul =>
            @li '現在放送中の番組はありません。'
        @p 'あとは、マイリスト一覧とか選択できるようにしたいっす。'
      @div outlet: 'mylistPanel', style: 'display:none'
      @div outlet: 'playPanel', style: 'display:none', =>
        @button click: 'closePlay', '閉じる'
        @span class: 'movie-title'
        @span class: 'owner-name'
        @subview 'commentView', new NicovideCommentView()
      @div outlet: 'processPanel', style: 'display:none', class: 'overlayout'

  # constructor: ({@rtmpPlayer, cookieStoreFile}) ->
  #   super
  #   @niconicoApi = new NiconicoApi(cookieStoreFile)
  #   console.log "constructor! NiconicoView"

  setCookieStoreFile: (cookieStoreFile) ->
    @niconicoApi.setCookieStoreFile(cookieStoreFile)
    # TODO: セッション切れた後の処理をしないと

  initialize: ({@rtmpPlayer, cookieStoreFile}) ->
    @niconicoApi = new NiconicoApi(cookieStoreFile)
    @active = null

  attached: ->
    @active = true

  detached: ->
    @active = false

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @niconicoApi.destroy()
    # @element.remove()

  isActive: ->
    @active

  getTitle: ->
    "ニコニコ動画"

  render: ->
    @startProcess 'ログイン状態を確認しています。'
    @niconicoApi.getMyTop (err, data) =>
      @stopProcess()
      if !err?
        if data.userId?
          @setTopPanel(data.userId, data.userName)
          @showMenu()
        else
          @showLogin()
      else
        @showAlert err
        @showLogin()

  # ニコニコ動画にログイン
  showLogin: ->
    @loginPanel.show()

  showMenu: ->
    @menuPanel.show()

  # 初期状態に戻す
  clearAll: ->
    @clearAlert()
    @loginPanel.hide()
    @menuPanel.hide()
    @mylistPanel.hide()
    @playPanel.hide()
    @unsetTopPanel()
    @stopProcess()

  startProcess: (message) ->
    @processPanel.text message
    @processPanel.show()

  stopProcess: ->
    @processPanel.hide()

  setTopPanel: (userId, userName) ->
    @userId.text userId
    @userName.text userName
    @logoutButton.show()

  unsetTopPanel: ->
    @userId.text '-'
    @userName.text '未ログイン'
    @logoutButton.hide()

  showAlert: (message) ->
    @alertPanel.text message
    @alertPanel.show()

  clearAlert: ->
    @alertPanel.hide()
    @alertPanel.text ''

  # クリックイベント
  clickLogin: (event, element) ->
    @clearAlert()
    unless @loginMail.val()
      @showAlert 'メールアドレスを入力して下さい。'
      return
    unless @loginPassword.val()
      @showAlert 'パスワードを入力して下さい。'
      return
    @startProcess 'ログイン中です・・・'
    @niconicoApi.login @loginMail.val(), @loginPassword.val(), (err, data) =>
      @stopProcess()
      if err
        # パスワードだけ初期化
        @loginPassword.val('')
        @showAlert err
      else
        @loginPanel.hide()
        @loginMail.val('')
        @loginPassword.val('')
        # 再度rederからやり直す
        @render()

  clickLogout: (event, element) ->
    @startProcess 'ログアウト中です・・・'
    @niconicoApi.logout =>
      @clearAll()
      @showLogin()



  clickQuickPlay: (event, element) ->
    @clearAlert()
    movieId = @quickMovie.val()
    console.log "#{movieId} を再生します。"
    if !movieId
      @showAlert '番組IDを入力して下さい。'
    else if /^lv\d+$/.test movieId
      @startProcess '番組情報を取得中'
      @niconicoApi.getLiveStatus movieId, (err, data) =>
        @stopProcess()
        if err
          @showAlert err
        else
          @playMovie data
    else
      @showAlert '未実装です。'

  playMovie: (data) ->
    console.log data
    rtmpdumpArgs = [
      '-v',
      '-r', "#{data.rtmp.url}/#{data.stream.id}",
      '-C', "S:#{data.rtmp.ticket}",
      '-N',  data.rtmp.contents,
    ]
    # @rtmpPlayer.play(rtmpdumpArgs)

    @playPanel.find('.movie-title').text(data.stream.title)
    @playPanel.find('.owner-name').text(data.stream.owner_name)

    @commentView.start(data.comment)

    @playPanel.show()

  closePlay: ->
    @rtmpPlayer.stop()
    @commentView.stop()
    @playPanel.hide()
