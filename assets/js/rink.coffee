###
#
# routines to render the rink and update game state
#
###

_cvs_wid = 779
_cvs_hgt = 373

_line_wid = 10000.0 / (_cvs_wid / 2.0)                          # about 10 pixels
_player_rad = 70.0
_puck_rad = 70.0 / 2.0
_font_pt = 48

_max_accel = 160.0

class Rink
  # player id used to highlight this player (P1, P2, etc.)
  constructor: (@player_id, @game_state_id) ->
    @is_watching = false
    @loading = null
    @pos = new Pt 0, 0

  start_watching: ->
    unless @is_watching
      @is_watching = true
      @watch_timer_id = setInterval (=> @watch()), 1000 / 30

  stop_watching: ->
    if @is_watching
      @is_watching = false
      clearInterval @watch_timer_id

  watch: ->
    # don't overrun server if request is already pending
    return if @loading? and new Date().getTime() - @loading < 500
    @loading = new Date().getTime()
    $.get "/gs/#{@game_state_id}", (data) =>
      @loading = null
      @render(data)

  send_acceleration_req: (canvas_x, canvas_y) ->
    # convert canvas coords to rink coords
    cwid = $('#playground').width()
    chgt = $('#playground').height();
    acc_x = 160 * ((canvas_x - cwid / 2) * 2000 / cwid - @pos.x) / 479.5
    acc_y = 160 * ((canvas_y - chgt / 2) * 2000 / cwid - @pos.y) / 479.5
    #console.log "accel click: #{acc_x}, #{acc_y}"

    post_data = { x: acc_x, y: acc_y }
    $.post '/gs/23', post_data, (data, status) ->
      #console.log "accel response: #{status} - #{data}"
      null


  # render uses the gamestate (gs) from the server to render all
  # player positions and the puck
  render: (gs) ->
    ctx = $('#playground').get()[0].getContext '2d'
    ctx.clearRect 0, 0, _cvs_wid + 1, _cvs_hgt + 1
    ctx.save()
    ctx.translate _cvs_wid / 2.0, _cvs_hgt / 2.0
    ctx.scale _cvs_wid / 2000.0, _cvs_wid / 2000.0
    ctx.save()

    ##
    # origin is in center of rink. rink extends from -1000.0 to 1000.0 lengthwise
    #

    @render_puck ctx, gs.puck
    @render_player ctx, player, true for player in gs.home_team_players
    @render_player ctx, player, false for player in gs.visiting_team_players
    ctx.restore()
    ctx.restore()

  render_puck: (ctx, puck) ->
    @render_circle ctx, puck.position, _puck_rad, 'rgba(0,0,0,0.55)'

  render_player: (ctx, player, is_homey) ->
    its_me = player.name == @player_id
    @pos = player.position if its_me
    alpha = if its_me then '1.0' else '0.55'
    styl = if is_homey then "rgba(128,128,255,#{alpha})" else "rgba(255,128,128,#{alpha})"
    @render_circle ctx, player.position, _player_rad, styl, player.name
    @render_acceleration ctx, player.position, player.acceleration if its_me

  render_circle: (ctx, pos, rad, styl, lbl) ->
    ctx.save()
    ctx.beginPath()
    ctx.arc pos.x, pos.y, rad - _line_wid / 2.0, 0, 2 * Math.PI, false
    ctx.closePath()
    ctx.lineWidth = _line_wid
    ctx.strokeStyle = styl
    ctx.stroke()
    if lbl?
      ctx.font = "#{_font_pt}pt Calibri"
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillStyle = styl
      ctx.fillText lbl, pos.x, pos.y
    ctx.restore()

  render_acceleration: (ctx, pos, accel) ->
    ctx.save()
    ctx.beginPath()
    ctx.lineWidth = _line_wid / 2
    ctx.strokeStyle = 'rgba(196,196,196,0.4)'
    ctx.translate pos.x, pos.y
    angle = Math.atan2 accel.y, accel.x
    ctx.rotate angle
    magnitude = Math.sqrt(accel.x * accel.x + accel.y * accel.y)
    ctx.moveTo _player_rad + 10, 0
    ctx.lineTo _player_rad + 10 + magnitude * 3, 0
    for x in [magnitude - _max_accel / 14..0] by -_max_accel / 7
      spur = (x - magnitude) / 2
      ctx.moveTo x * 3 + _player_rad + 10, -spur
      ctx.lineTo x * 3 + _player_rad + 10, spur
    ctx.stroke()
    ctx.restore()

class Pt
  constructor: (@x, @y) ->

window.Rink = Rink
window.Pt = Pt
