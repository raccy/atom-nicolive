NicoliveView = require './nicolive-view'
{CompositeDisposable} = require 'atom'

module.exports = Nicolive =
  nicoliveView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @nicoliveView = new NicoliveView(state.nicoliveViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @nicoliveView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'nicolive:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @nicoliveView.destroy()

  serialize: ->
    nicoliveViewState: @nicoliveView.serialize()

  toggle: ->
    console.log 'Nicolive was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
