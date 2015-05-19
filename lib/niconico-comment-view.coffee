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
    remainData = ""
    closeTag = '</chat>'
    @socket.on 'data', (data) =>
      console.log data
      data = remainData + data
      endIndex = data.lastIndexOf(closeTag)
      if endIndex < 0
        remainData = data
      else
        remainData = data.slice(endIndex + closeTag.length)
        data = data.slice(0, endIndex + closeTag.length)
        dataQuery = cheerio.load data
        dataQuery('chat').each (index, element) =>
          liElement = document.createElement('li')
          $(liElement).text $(element).text()
          @commentList.prepend liElement

  stop: ->
    @socket.end()
    @commentList.html ""
    @socket = null
