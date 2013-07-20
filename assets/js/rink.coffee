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

class Rink
  # player id used to highlight this player (P1, P2, etc.)
  constructor: (@player_id) ->

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
    alpha = if player.name == @player_id then '1.0' else '0.55'
    styl = if is_homey then "rgba(128,128,255,#{alpha})" else "rgba(255,128,128,#{alpha})"
    @render_circle ctx, player.position, _player_rad, styl, player.name

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


class Pt
  constructor: (@x, @y) ->

window.Rink = Rink
window.Pt = Pt
