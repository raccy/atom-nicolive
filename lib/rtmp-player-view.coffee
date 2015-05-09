# Original code by video-player https://github.com/tyage/video-player
# File: lib/video-player-view.coffee
# Licensed under the MIT License Copyright (c) 2014 tyage
# See https://github.com/tyage/video-player/blob/master/LICENSE.md

{View} = require 'atom-space-pen-views'
VLC = require './vlc'
remote = require 'remote'
dialog = remote.require 'dialog'
# mime = require 'mime'
{spawn} = require 'child_process'

# isCodecSupported = (codec) ->
#   # codec support: http://www.chromium.org/audio-video
#   supportedCodecs = [
#     'audio/ogg', 'application/ogg', 'video/ogg',
#     'video/webm', 'audio/webm',
#     'audio/wav', 'audio/x-wav'
#   ]
#   codecSupported = supportedCodecs.filter (c) -> codec == c
#   codecSupported.length > 0

module.exports =
class RtmpPlayerView extends View
  @content: ->
    @div class: 'rtmp-player', =>
      @video outlet: 'rtmpVideo', autoplay: true

  initialize: ({@vlcPath, @rtmpdumpPath}) ->
    @vlc = new VLC(@vlcPath)
    @playing = false
    # atom.workspaceView.command "video-player:play", => @play()
    # atom.workspaceView.command "video-player:stop", => @stop()
    # atom.workspaceView.command "video-player:toggle-back-forth", => @toggleBackForth()
    # atom.workspaceView.command "video-player:toggle-control", => @toggleControl()
    # atom.workspaceView.command "video-player:reload-source", => @reloadSrc()

  # Tear down any state and detach
  destroy: ->
    @stop()

  setVlcPath: (@vlcPath) ->
    @vlc.path = @vlcPath

  setRtmpdumpPath: (@rtmpdumpPath) ->

  isPlay: ->
    @playing

  stop: ->
    console.log '停止しました。'
    if (@rtmpdumpProcess != null)
      @rtmpdumpProcess.kill 'SIGKILL'
      @rtmpdumpProcess = null
    @vlc.kill()
    @detach()
    @playing = false

  play: (rtmpdumpArgs) ->
    if @playing
      @stop()
    @playing = true
    #   self = this
    #   properties = ['openFile', 'multiSelections']
    #   dialog.showOpenDialog title: 'Open', properties: properties, (files) ->
    #     if files != undefined
    #       self._play files
    #
    # _play: (files) ->


    # @vlc.kill()

    targetPane = null
    for pane in atom.workspace.getPanes()
      console.log pane
      for item in pane.getItems()
        console.log item
        itemDom = atom.views.getView(item)
        console.log itemDom
        if !targetPane and itemDom.tagName == 'atom-text-edtior'
          targetPane = pane
        else if 'rtmp-player' in itemDom.classList
          pane.destroyItem item
    if targetPane
      console.log '再生するためのエディタ領域がないです。'
      return

    #   pane.addItem @
    #
    # itemViews = atom.workspaceView.find('.pane.active .item-views')
    # itemViews.find('.rtmp-player').remove()
    # itemViews.append @
    # addItem @
    # video = atom.workspaceView.find '.rtmp-player video'

    # codecUnsupported = files.filter (file) ->
    #   mimeType = mime.lookup file
    #   !isCodecSupported mimeType
    # if codecUnsupported.length > 0
    #   # when play unsupported file, try to use VLC
    #   this._playWithVlc video, files
    # else
    #   this._playWithHtml5Video video, files

    #_playWithVlc: (video, files) ->
    # self = this

    @rtmpdumpProcess = spawn @rtmpdumpPath, rtmpdumpArgs, {stdio: ['ignore', 'pipe', 'pipe']}
    @rtmpdumpProcess.on 'exit', () =>
      console.log 'streaming finished'
      @stop
    @rtmpdumpProcess.stderr.on 'data', (data) =>
      console.log data.toString()
      @stop

    streamServer = "http://localhost:#{@vlc.port}"
    @rtmpVideo.attr 'src', streamServer
    @vlc.streaming @rtmpdumpProcess.stdout, (data) =>
      @stop
    @rtmpVideo.on 'ended', () =>
      @stop
    @rtmpVideo.on 'suspend', () =>
      @stop

  # _playWithHtml5Video: (video, files) ->
  #   counter = 0
  #   video.attr 'src', files[counter]
  #   video.on 'ended', () ->
  #     ++counter
  #     if (counter < files.length)
  #       video.attr 'src', files[counter]

  # _reloadSrc: (video) ->
  #   src = video.attr 'src'
  #   video.attr 'src', src
  #
  # reloadSrc: ->
  #   video = atom.workspaceView.find '.video-player video'
  #   this._reloadSrc video

  # toggleBackForth: ->
  #   jQuery(this).toggleClass 'front'
  #
  # toggleControl: ->
  #   video = jQuery(this).find 'video'
  #   controls = video.attr 'controls'
  #   video.attr 'controls', !controls
