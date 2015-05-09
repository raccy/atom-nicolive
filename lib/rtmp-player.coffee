

module.exports =
class RtmpPlayer
  constructor: ({@vlcPath, @rtmpdumpPath}) ->

  destroy: ->
    @vlcPathObserveSubscription.dispose()

  setVlcPath: (@vlcPath) ->

  setRtmpdumpPath: (@rtmpdumpPath) ->
