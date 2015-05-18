{$, $$$, View} = require 'atom-space-pen-views'
net = require 'net'
xmlbuilder = require 'xmlbuilder'
cheerio = require 'cheerio'

module.exports =
class NiconicoCommentView extends View
  @content: ->
    @div class: 'niconico-comment-view', tabindex: -1, =>
      @ul outlet: 'commentList'

  initialize: () ->
    @version = '20061206'
    @socket = null

  attached: ->

  detached: ->

  start: (commentData) ->
    if @sokcet?
      @stop()
    @socket = net.connect(parseInt(commentData.port, 10), commentData.addr)
    @socket.on 'connect', ->
      @setEncoding 'utf-8'
      doc = xmlbuilder.create 'thread'
      doc.att 'thread', commentData.thread
      doc.att 'res_from', '-1000'
      doc.att 'version', '20061206'
      @write doc.toString(pretty: true)
      @write "\0"
    @socket.on 'data', (data) =>
      console.log data
      dataQuery = cheerio.load data
      dataQuery('chat').each (index, element) =>
        liElement = document.createElement('li')
        $(liElement).text $(element).text()
        @commentList.append liElement

  stop: ->
    @socket.end()
    @commentList.html ""
    @socket = null
