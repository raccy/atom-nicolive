RtmpPlayerView = require './rtmp-player-view'

module.exports =
class RtmpPlayer
  constructor: ({@vlcPath, @rtmpdumpPath}) ->

  destroy: ->

  setVlcPath: (@vlcPath) ->

  setRtmpdumpPath: (@rtmpdumpPath) ->
