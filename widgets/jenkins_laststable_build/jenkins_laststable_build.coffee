class Dashing.LastBuild extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.last_build isnt data.current_build	
      audio = new Audio('/tada.wav')
      audio.play()
