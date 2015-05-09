RtmpPlayerView = require './rtmp-player-view'

module.exports =
class RtmpPlayer
  constructor: ({@vlcPath, @rtmpdumpPath}) ->
    @rtmpPlayerView = new RtmpPlayerView
      vlcPath: @vlcPath
      rtmpdumpPath: @rtmpdumpPath

  destroy: ->
    @stop()
    @rtmpPlayerView.destroy()

  setVlcPath: (@vlcPath) ->
    @rtmpPlayerView.setVlcPath @vlcPath

  setRtmpdumpPath: (@rtmpdumpPath) ->
    @rtmpPlayerView.setRtmpdumpPath @rtmpdumpPath

  play: (rtmpdumpArgs) ->
    console.log ['配信開始', rtmpdumpArgs]
    if @rtmpPlayerView.isPlay()
      @rtmpPlayerView.stop()
    @rtmpPlayerView.play(rtmpdumpArgs)

  stop: ->
    console.log '配信停止'
    @rtmpPlayerView.stop()
