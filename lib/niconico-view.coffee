{$, $$$, ScrollView} = require 'atom-space-pen-views'
NiconicoApi = require './niconico-api'
fs = require 'fs'

module.exports =
class NiconicoView extends ScrollView
  @content: ->
    @div class: 'niconico-view', tabindex: -1, =>
      @div outlet: 'topPanel', =>
        @text 'ID:'
        @span outlet: 'userID', '-'
        @text ' '
        @span outlet: 'userName', '未ログイン'
        @button outlet: 'logoutButton', click: 'clickLogout', style: 'display:none', 'ログアウト'
      @div outlet: 'alertPanel', style: 'display:none', class: 'alert'
      @div outlet: 'loginPanel', style: 'display:none', =>
        # @h2 'ニコニコ動画ログイン'
        @p 'メールアドレスとパスワードを入れて、ログインしてください。'
        @form =>
          @div =>
            @label 'メールアドレス'
            @input outlet: 'loginUsername', name: 'mail_tel', type: 'text'
          @div =>
            @label 'パスワード'
            @input outlet: 'loginPassword', name: 'password', type: 'password'
          @div =>
            @button click: 'clickLogin', 'ログイン'
      @div outlet: 'menuPanel', style: 'display:none', =>
        @text 'ここにメニューが表示されます。'
      @div outlet: 'mylistPanel', style: 'display:none'
      @div outlet: 'commentPanel', style: 'display:none'
      @div outlet: 'processPanel', style: 'display:none', class: 'overlayout'

  constructor: (cookieStoreFile) ->
    super
    @niconicoApi = new NiconicoApi(cookieStoreFile)

    # # Create root element
    # @element = document.createElement('div')
    # @element.classList.add('nicolive')
    #
    # # Create message element
    # message = document.createElement('div')
    # message.textContent = "The Nicolive package is Alive! It's ALIVE!"
    # message.classList.add('message')
    # @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Returns an object that can be retrieved when package is activated
  # serialize: ->
  # Tear down any state and detach
  destroy: ->
    # @element.remove()

  getTitle: ->
    "ニコニコ動画"

  render: ->
    if @niconicoApi.isValidSession()
      @showMenu()
    else
      @showLogin()

  # ニコニコ動画にログイン
  showLogin: ->
    @loginPanel.show()
    # @html $$$ ->
    #   @h2 'ニコニコ動画ログイン'
    #   @p 'ユーザ名とパスワード入れてログインしてください。'
    #   @div outlet: 'loginAlert', class: 'alert'
    #   @form =>
    #     @div =>
    #       @label 'メールアドレス'
    #       @input outlet: 'loginUsername', name: 'mail_tel', type: 'text'
    #     @div =>
    #       @label 'パスワード'
    #       @input outlet: 'loginPassword', name: 'password', type: 'password'
    #     @div =>
    #       @button click: 'clickLogin', 'ログイン'

  clickLogin: (event, element) ->
    @alertPanel.hide()
    unless @loginUsername.val()
      @alertPanel.show()
      @alertPanel.text 'メールアドレスを入力して下さい。'
      return
    unless @loginPassword.val()
      @alertPanel.show()
      @alertPanel.text 'パスワードを入力して下さい。'
      return
    @startProcess 'ログイン中です。。。'
    @niconicoApi.login @loginUsername.val(), @loginPassword.val(), (success, error) =>
      @stopProcess()
      if success
        @loginUsername.val('')
        @loginPassword.val('')
        @loginPanel.hide()
        @showMenu()
      else
        # パスワードだけ初期化
        @loginPassword.val('')
        @alertPanel.show()
        @alertPanel.text error

  showMenu: ->
    @menuPanel.show()

  startProcess: (message) ->
    @processPanel.text message
    @processPanel.show()

  stopProcess: ->
    @processPanel.hide()
