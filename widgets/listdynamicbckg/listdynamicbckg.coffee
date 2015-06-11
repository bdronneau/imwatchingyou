# Base on http://stackoverflow.com/a/22085064/4809513
class Dashing.Listdynamicbckg extends Dashing.Widget
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()

    # This is fired when the widget is done being rendered
    @setColor(@get('status'))

  onData: (data) ->
    @setColor(@get('status'))

  setColor: (status) ->
    switch status
      when 0 then $(@node).css("background-color", "#29a334") #green
      when 1 then $(@node).css("background-color", "#ec663c") #orange
      when 2 then $(@node).css("background-color", "#b80028") #red