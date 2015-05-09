RtmpPlayerView = require './rtmp-player-view'

module.exports =
class RtmpPlayer
  constructor: ({@vlcPath, @rtmpdumpPath}) ->

  destroy: ->
    @stop

  setVlcPath: (@vlcPath) ->

  setRtmpdumpPath: (@rtmpdumpPath) ->

  play: (rtmpdumpArgs) ->
    if @rtmpPlayerView
      @stop
    @rtmpPlayerView = new RtmpPlayerView(@vlcPath, @rtmpdumpPath)

  stop: ->
    @rtmpPlayerView.destroy
    @rtmpPlayerView = null
