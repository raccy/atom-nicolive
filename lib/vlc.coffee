# Original code by video-player https://github.com/tyage/video-player
# File: lib/vlc.coffee
# Licensed under the MIT License Copyright (c) 2014 tyage
# See https://github.com/tyage/video-player/blob/master/LICENSE.md

{spawn} = require 'child_process'
# unorm = require 'unorm'

module.exports =
class VLC
  # streaming: streaming
  # kill: kill
  # port: port

  # なんとなくオリジナルより1つだけデフォルトポートを増やす
  constructor: (@path, @port = 9531) ->
    @vlcProcess = null

  kill: ->
    if (@vlcProcess != null)
      @vlcProcess.kill 'SIGKILL'
      @vlcProcess = null

  streaming: (readablePipe, errorCallback) ->
    # TODO: mac os only
    # vlc = atom.config.get('video-player.vlcPath')
    # files = inputs.map unorm.nfc
    args = [
      '-'
      '--sout'
      "\#transcode{vcodec=theo,vb=800,scale=1,acodec=vorb,ab=128,channels=2,
      samplerate=44100}:http{mux=ogg,dst=:#{@port}}"
      '--sout-keep'
    ]
    @vlcProcess = spawn @path, args, {stdio: ['pipe', 'ignore', 'pipe']}
    readablePipe.pipe(@vlcProcess.stdin)
    @vlcProcess.on 'exit', () ->
      console.log 'streaming finished'
    @vlcProcess.stderr.on 'data', (data) ->
      console.log data.toString()
      errorCallback data
