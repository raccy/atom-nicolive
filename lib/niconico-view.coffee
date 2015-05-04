# {View} = require 'atom'
{$, $$$, ScrollView} = require 'atom'
module.exports =
class NiconicoView extends ScrollView
  @content: ->
    @div class: 'niconico-view'

  constructor: () ->
    super
    # # Create root element
    # @element = document.createElement('div')
    # @element.classList.add('nicolive')
    #
    # # Create message element
    # message = document.createElement('div')
    # message.textContent = "The Nicolive package is Alive! It's ALIVE!"
    # message.classList.add('message')
    # @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  # serialize: ->
  # Tear down any state and detach
  destroy: ->
    # @element.remove()

  # ニコニコ動画にログイン
  login: ->
    console.log $$$
    @html $$$ ->
      console.log @
      @h2 'ニコ生にログインしてね！'
      # @frame =>
      #   # @label 'ログイン'
      #   @input type: 'text'
      #   # @label 'パスワード'
      #   @input type: 'password'

  getTitle: ->
    "ニコニコ動画"
