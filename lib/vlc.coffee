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
    if @vlcProcess?
      @vlcProcess.kill 'SIGKILL'
      @vlcProcess = null

  streaming: (readablePipe, errorCallback) ->
    # TODO: mac os only
    # vlc = atom.config.get('video-player.vlcPath')
    # files = inputs.map unorm.nfc
    args = [
      '-'
      '--sout'
      "\#transcode{vcodec=theo,vb=320,scale=1,acodec=vorb,ab=64,channels=2,
      samplerate=44100}:http{mux=ogg,dst=:#{@port}}"
      '--sout-keep'
      '-I'
      'dummy'
    ]
    # args = [
    #   '-',
    #   '--sout-transcode-vcodec', 'theo',
    #   '--sout-transcode-vb', '800',
    #   '--sout-transcode-scale', '1',
    #   '--sout-transcode-acodec', 'vorb',
    #   '--sout-transcode-ab', '128',
    #   '--sout-transcode-channels', '2',
    #   '--sout-transcode-samplerate', '44100',
    #   '--sout-standard-access', 'http',
    #   '--sout-standard-mux', 'ogg',
    #   '--sout-standard-dst', "localhost:#{@port}",
    #   '--sout-keep',
    #   '--intf', 'dummy',
    # ]
    console.log args
    @vlcProcess = spawn @path, args, {stdio: ['pipe', 'ignore', 'pipe']}
    readablePipe.pipe(@vlcProcess.stdin)
    @vlcProcess.on 'exit', () ->
      console.log 'streaming finished'
    @vlcProcess.stderr.on 'data', (data) ->
      console.log data.toString()
      errorCallback data
