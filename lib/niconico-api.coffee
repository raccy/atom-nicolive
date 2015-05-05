fs = require 'fs'
request = require 'request'
FileCookieStore = require 'tough-cookie-filestore'

# ニコニコ動画関係のAPI
module.exports =
class NiconicoApi
  @URI: {
    login: 'https://secure.nicovideo.jp/secure/login?site=niconico',
  }

  # https://secure.nicovideo.jp/secure/login?show_button_twitter=1&site=niconico&show_button_facebook=1

  constructor: (cookieStoreFile) ->
    @errorMessage = null
    # すでに存在しないとエラーになるらしい。
    unless fs.existsSync(cookieStoreFile)
      fs.closeSync(fs.openSync(cookieStoreFile, 'w'))
    @requestJar = request.jar(new FileCookieStore(cookieStoreFile))
    @request = request.defaults({jar: @requestJar})

  # セッションが有効かどうかを確認する
  isValidSession: ->
    false

  # ログインする。
  # ログインした情報をcallbackになげる。
  # callback(success, err)
  login: (username, password, callback) ->
    console.log request
    formData = {
      mail_tel: username,
      password: password,
    }
    @request.post NiconicoApi.URI.login, {followRedirect: false, form: formData}, (err, response,body) ->
      if !err and response.statusCode == 302
        if response.headers?.location? == 'http://www.nicovideo.jp/'
          callback(true, null)
        else
          callback(false, 'メールアドレスまたはパスワードが間違っています。')
      else
        callback(false, err? || '不明なレスポンスが返されました。')

  # ログアウトする。
  logout: ->
    @userSession = null

  # ユーザ情報を取得する。
  getUserInfo: (userId) ->

  # 登録しているチャンネル/コミュニティで放送中の番組一覧を出す。
  getFavoritLiveList: ->

  # 生放送番組の情報を取得する
  getLiveStatus: (lv) ->

  getErrorMessage: ->
    @errorMessage
