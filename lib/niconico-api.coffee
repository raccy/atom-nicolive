fs = require 'fs'
request = require 'request'
FileCookieStore = require 'tough-cookie-filestore'
cheerio = require 'cheerio'

# ニコニコ動画関係のAPI
module.exports =
class NiconicoApi
  @URI: {
    login: 'https://secure.nicovideo.jp/secure/login?site=niconico'
    logout: 'https://secure.nicovideo.jp/secure/logout'
    my: {
      top: 'http://www.nicovideo.jp/my/top'
      community: 'http://www.nicovideo.jp/my/community'
      channel: 'http://www.nicovideo.jp/my/channel'
      live: 'http://www.nicovideo.jp/my/live'
      mylist: 'http://www.nicovideo.jp/my/mylist'
    }
    live: {
      status: 'http://live.nicovideo.jp/api/getplayerstatus/{id}'
    }
  }

  # https://secure.nicovideo.jp/secure/login?show_button_twitter=1&site=niconico&show_button_facebook=1

  constructor: (cookieStoreFile) ->
    # すでに存在しないとエラーになるらしい。けど、修正バージョンのブランチ使う。
    # unless fs.existsSync(cookieStoreFile)
    #   fs.closeSync(fs.openSync(cookieStoreFile, 'w'))
    @requestJar = request.jar(new FileCookieStore(cookieStoreFile))
    @request = request.defaults {
      jar: @requestJar
      followRedirect: false
      headers: {
        'User-Agent': 'Niconico for Atom 0.0.0 / https://github.com/raccy/niconico'
      }
    }

  # ログインする。
  # ログインした情報をcallbackになげる。
  # callback(success, err)
  login: (mail, password, callback) ->
    formData = {
      mail_tel: mail,
      password: password,
    }
    @request.post NiconicoApi.URI.login, {form: formData}, (err, response, body) ->
      if !err and response.statusCode == 302
        if response.headers.location == 'http://www.nicovideo.jp/'
          callback(true, null)
        else
          callback(false, 'メールアドレスまたはパスワードが間違っています。')
      else
        callback(false, err? || '不明なレスポンスが返されました。')

  # ログアウトする。
  logout: (callback) ->
    @request.get NiconicoApi.URI.logout, ->
      callback()

  # トップをとる
  # classback(err, {userId, userName})
  getMyTop: (callback) ->
    @request.get NiconicoApi.URI.my.top, (err, response, body) ->
      if !err
        data = {}
        if response.statusCode == 200
          myTop = cheerio.load body
          data.userName = myTop('.profile h2').contents().text().
              replace(/さんの$/, '')
          data.userId = myTop('.accountNumber span').text()
        callback(null, data)
      else
        callback(err, null)

  # 登録しているチャンネル/コミュニティで放送中の番組一覧を出す。
  getFavoritLiveList: ->

  # 生放送番組の情報を取得する
  getLiveStatus: (lv, callback) ->
    url = NiconicoApi.URI.live.status.slice(0).replace('{id}', lv)
    @request.get url, (err, response, body) ->
      if err
        callback(err, null)
      else
        liveStatus = cheerio.load(body)
        if liveStatus('getplayerstatus').attr('status') == 'ok'
          data = {}
          data.stream = {}
          data.stream.id = liveStatus('stream id').text()
          data.stream.title = liveStatus('stream title').text()
          data.stream.description = liveStatus('stream description').text()
          data.stream.owner_id = liveStatus('stream owner_id').text()
          data.stream.owner_name = liveStatus('stream owner_name').text()
          data.stream.thumb_url = liveStatus('stream thumb_url').text()
          # コメントサーバの情報
          data.comment = {}
          data.comment.addr = liveStatus('ms addr').text()
          data.comment.port = liveStatus('ms port').text()
          data.comment.thread = liveStatus('ms thread').text()
          # RTMPサーバの情報
          data.rtmp = {}
          data.rtmp.url = liveStatus('rtmp url').text()
          data.rtmp.ticket = liveStatus('rtmp ticket').text()
          data.rtmp.contents = liveStatus('contents#main').text().replace(/^rtmp:rtmp:\/\//, 'rtmp://')
          callback(err, data)
        else
          callback(liveStatus('error code').text(), liveStatus)
