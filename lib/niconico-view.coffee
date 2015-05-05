{$, $$$, ScrollView} = require 'atom-space-pen-views'
NiconicoApi = require './niconico-api'
fs = require 'fs'

module.exports =
class NiconicoView extends ScrollView
  @content: ->
    @div class: 'niconico-view', tabindex: -1

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
      @menu()
    else
      @login()

  # ニコニコ動画にログイン
  login: ->


    @html $$$ ->
      @h2 'ニコニコ動画ログイン'
      @p 'ユーザ名とパスワード入れてログインしてください。'
      @div id: 'niconico-login-alert', class: 'alert'
      @form =>
        @div =>
          @label 'メールアドレス'
          @input id: 'niconico-login-username', type: 'text'
        @div =>
          @label 'パスワード'
          @input id: 'niconico-login-password', type: 'password'
        @div =>
          @input id: 'niconico-login-button', type: 'button', value: 'ログイン'
    $('#niconico-login-button').click =>
      usernameInput = $('#niconico-login-username')
      passwordInput = $('#niconico-login-password')
      $('#niconico-login-alert').text 'ログイン中です。。。'
      @niconicoApi.login usernameInput.val(), passwordInput.val(),
        (success, error) =>
          if success
            @menu
          else
            # パスワードだけ初期化
            passwordInput.val('')
            $('#niconico-login-alert').text error


  menu: ->
    @html $$$ ->
      @h2 'ニコニコ動画にようこそ'
