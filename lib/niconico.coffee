{CompositeDisposable} = require 'atom'
NiconicoView = require './niconico-view'

module.exports = Nicolive =
  niconicoView: null
  # nicoliveView: null
  # modalPanel: null
  subscriptions: null

  activate: (state) ->
    @niconicoView = new NiconicoView()
    # @nicoliveView = new NicoliveView(state.nicoliveViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @nicoliveView.getElement(), visible: false)
    #
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'niconico:show': => @show()

  show: ->
    console.log "ニコ生のボタンを押したな！"
    atom.workspace.getActivePane().splitRight().addItem @niconicoView
    # @niconicoView.render()
    @niconicoView.login()

  deactivate: ->
    # @modalPanel.destroy()
    # @subscriptions.dispose()
    # @nicoliveView.destroy()
    @niconicoView.destroy()

  serialize: ->
    # nicoliveViewState: @nicoliveView.serialize()

  # toggle: ->
  #   console.log 'Nicolive was toggled!'
  #
  #   if @modalPanel.isVisible()
  #     @modalPanel.hide()
  #   else
  #     @modalPanel.show()
