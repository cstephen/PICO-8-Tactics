pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

-- prefix global variables with g_
g_select = {x = 18, y = 0}
g_friendlymoving = false
g_enemymoving = false
g_attacking = false
g_enemyattacking = false
g_enemyendturn = false
g_back = false
g_turnover = false
g_gridsize = {x = 128, y = 32}
g_alternate = 20
g_moveanimation = nil
g_playerturn = true
enemymovecounter = 0

g_units = {
  good = {},
  evil = {}
}

g_mapcorner = {
  x = 18,
  y = 0
}

g_mapanimatecounter = 0

g_mapanimations = {
  {192, 193},
  {194, 195},
  {196, 197},
  {198, 199},
  {200, 201},
  {202, 203},
  {204, 205},
  {206, 207},
  {208, 209},
  {210, 211},
  {212, 213},
  {214, 215},
  {216, 217},
  {218, 219}
}

g_colors = {
  good = 11,
  evil = 14
}

g_sprites = {
  knight = {
    good = 1,
    evil = 17
  },
  dwarf = {
    good = 2,
    evil = 18
  },
  lancer = {
    good = 3,
    evil = 19
  },
  archer = {
    good = 4,
    evil = 20
  }
}

g_knight = {
  name = "knight",
  speed = 2,
  attackmin = 0,
  attackmax = 1,
  might = 3,
  maxhp = 10,
  hp = 10,
  xp = 0,
  level = 1
}

g_dwarf = {
  name = "dwarf",
  speed = 2,
  attackmin = 0,
  attackmax = 1,
  might = 4,
  maxhp = 15,
  hp = 15,
  xp = 0,
  level = 1
}

g_lancer = {
  name = "lancer",
  speed = 3,
  attackmin = 0,
  attackmax = 2,
  might = 2,
  maxhp = 10,
  hp = 10,
  xp = 0,
  level = 1
}

g_archer = {
  name = "archer",
  speed = 4,
  attackmin = 1,
  attackmax = 2,
  might = 1,
  maxhp = 5,
  hp = 5,
  xp = 0,
  level = 1
}

function _init()
  g_bg = gridinit()
  g_breadcrumbs = gridinit()
  g_typemask = gridinit()

  gridclear(g_bg, {sprite = 0})
  gridclear(g_breadcrumbs, {})
  gridclear(g_typemask, "neutral")

  add(g_units.good, createunit(g_knight, "good", 18, 0))
  add(g_units.good, createunit(g_dwarf, "good", 18, 3))
  add(g_units.evil, createunit(g_dwarf, "evil", 19, 1))
end

function _update()
  if g_playerturn == true then
    playerturn()
  else
    enemyturn()
  end
end

function _draw()
  cls()

  mapanimate()
  map(g_mapcorner.x, g_mapcorner.y, 0, 0, 16, 16)

  griddraw(g_bg)
  unitdraw()
  selectdraw()

  if g_moveanimation != nil then
    moveanimate()
  end

  if g_battleanimation != nil then
    battleanimate()
  end
end

function playerturn()
  if btnp(0) then
    if g_select.x > 0
    and g_battleanimation == nil then
      g_select.x -= 1
      if g_select.x - g_mapcorner.x < 0 then
        g_mapcorner.x -= 1
        mapsliceanimate(0, nil)
      end
    end
  end

  if btnp(1) then
    if g_select.x < 127
    and g_battleanimation == nil then
      g_select.x += 1
      if g_select.x - g_mapcorner.x > 15 then
        g_mapcorner.x += 1
        mapsliceanimate(15, nil)
      end
    end
  end

  if btnp(2) then
    if g_select.y > 0
    and g_battleanimation == nil then
      g_select.y -= 1
      if g_select.y - g_mapcorner.y < 0 then
        g_mapcorner.y -= 1
        mapsliceanimate(nil, 0)
      end
    end
  end

  if btnp(3) then
    if g_select.y < 31
    and g_battleanimation == nil then
      g_select.y += 1
      if g_select.y - g_mapcorner.y > 15 then
        g_mapcorner.y += 1
        mapsliceanimate(nil, 15)
      end
    end
  end

  if btnp(4) and g_moveanimation == nil then
    if g_friendlymoving == false
    and g_attacking == false then
      g_chosen = getunit(g_select.x, g_select.y)
      if g_chosen != nil
      and g_chosen.alignment == "good"
      and g_chosen.actionover == false then
        movespaces(g_chosen.x, g_chosen.y, {"good", "neutral"}, {"evil"})
      end
    elseif g_friendlymoving == true
    and g_attacking == false
    and g_valid[g_select.x] != nil
    and g_valid[g_select.x][g_select.y] != nil then
      if g_typemask[g_select.x][g_select.y] == "neutral"
      or (g_select.x == g_chosen.x and g_select.y == g_chosen.y) then
        move(g_select.x, g_select.y, {"good", "neutral"}, {"evil"})
      end
    elseif g_friendlymoving == false
    and g_attacking == true then
      if g_bg[g_select.x][g_select.y].sprite == 253 then
        attack({
          x = g_select.x,
          y = g_select.y
        })
      elseif g_select.x == g_chosen.x and g_select.y == g_chosen.y then
        gridclear(g_bg, {sprite = 0})
        g_friendlymoving = false
        g_attacking = false
        endturn()
      end
    end
  end

  if btnp(5) then
    if g_friendlymoving == true
    and g_attacking == false then
      gridclear(g_bg, {sprite = 0})
      g_friendlymoving = false
      modifyunit(g_chosen, {
        moving = false
      })
    elseif g_friendlymoving == false
    and g_attacking == true then
      g_back = true
      gridclear(g_bg, {sprite = 0})
      move(g_lastspace.x, g_lastspace.y, {"good", "neutral"}, {"evil"})
      movespaces(g_chosen.x, g_chosen.y, {"good", "neutral"}, {"evil"})
      g_friendlymoving = true
      g_attacking = false
    end
  end
end

function enemyturn()
  if g_enemymoving == false and g_enemyattacking == false and g_enemyendturn == false then
    for unit in all(g_units.evil) do
      g_chosen = getunit(unit.x, unit.y)
      movespaces(g_chosen.x, g_chosen.y, {"evil", "neutral"}, {"good"})
      for xspace, yspaces in pairs(g_valid) do
        for yspace, steps in pairs(yspaces) do
          enemymovecounter += 1
          if steps == 0 and enemymovecounter == 9 then
            g_select = {
              x = xspace,
              y = yspace
            }
            g_enemymoving = true
            enemymovecounter = 0
            move(g_select.x, g_select.y, {"evil", "neutral"}, {"good"})
            return
          end
        end
      end
    end
  elseif g_enemymoving == false and g_enemyattacking == true and g_enemyendturn == false then
    for xspace, yspaces in pairs(g_attackvalid) do
      for yspace, steps in pairs(yspaces) do
        if g_bg[xspace][yspace].sprite == 253 then
          attack({
            x = xspace,
            y = yspace
          })
          g_enemyattacking = false
          g_enemyendturn = true
          return
        end
      end
    end
  end
end

function copy(src)
  local dest = {}
  for key, value in pairs(src) do
    dest[key] = value
  end
  return dest
end

function statprint(text, x, y, color, width)
  rectfill(x, y, x + width, y + 8, 0)
  print(text, x + 2, y + 2, color)
end

function gridinit()
  local grid = {}
  for i=0, g_gridsize.x do
    grid[i] = {}
  end
  return grid
end

function gridclear(grid, value)
  for i=0, g_gridsize.x do
    for j=0, g_gridsize.y do
      grid[i][j] = value
    end
  end
end

function griddraw(grid)
  for i=g_mapcorner.x, g_mapcorner.x + 16 do
    for j=g_mapcorner.y, g_mapcorner.y + 16 do
      local pos = spritepos(grid[i][j].sprite)
      sspr(pos.x * 8, pos.y * 8, 8, 8, (i - g_mapcorner.x) * 8, (j - g_mapcorner.y) * 8)
    end
  end
end

function unitdraw()
  for alignment, units in pairs(g_units) do
    for unit in all(units) do
      if unit.moving == false then
        local pos = spritepos(unit.sprite)
        sspr(pos.x * 8, pos.y * 8, 8, 8, (unit.x - g_mapcorner.x) * 8, (unit.y - g_mapcorner.y) * 8)
      end
    end
  end
end

function mapanimate()
  for i=g_mapcorner.x, g_mapcorner.x + 16 do
    for j=g_mapcorner.y, g_mapcorner.y + 16 do
      if g_mapanimatecounter % g_alternate == 0 then
        for mapanimation in all(g_mapanimations) do
          for k=1, #mapanimation do
            if mget(i, j) == mapanimation[k]
            and g_mapanimatecounter == k * g_alternate then
              mset(i, j, mapanimation[k % #mapanimation + 1])
              break
            end
          end
        end
      end
    end
  end

  if g_mapanimatecounter == g_alternate * 2 then
    g_mapanimatecounter = 0
  end

  g_mapanimatecounter += 1
end

function mapsliceanimate(x, y)
  for idx=0, 15 do
    for mapanimation in all(g_mapanimations) do
      for k=1, #mapanimation do
        local sprite

        if x != nil then
          sprite = mget(g_mapcorner.x + x, g_mapcorner.y + idx)
        elseif y != nil then
          sprite = mget(g_mapcorner.x + idx, g_mapcorner.y + y)
        end

        if sprite == mapanimation[#mapanimation - (k - 1)]
        and g_mapanimatecounter >= (k - 1) * g_alternate
        and g_mapanimatecounter <= k * g_alternate then
          if x != nil then
            mset(g_mapcorner.x + x, g_mapcorner.y + idx, mapanimation[k])
          elseif y != nil then
            mset(g_mapcorner.x + idx, g_mapcorner.y + y, mapanimation[k])
          end
        end
      end
    end
  end
end

function spritepos(s)
  local sprite = {}
  sprite.x = s % 16
  sprite.y = flr(s / 16)
  return sprite
end

function selectdraw()
  local screenpos = {
    x = g_select.x - g_mapcorner.x,
    y = g_select.y - g_mapcorner.y
  }

  spr(255, screenpos.x * 8, screenpos.y * 8)

  local unit = getunit(g_select.x, g_select.y)
  if unit != nil then
    local screen = {
      pos = {
        x = 100,
        y = 1
      },
      width = 26
    }

    if g_battleanimation == nil then
      showstats(unit, screen)
    end
  end
end

function battleanimate()
  g_battleanimation.frame += 1

  local frame = g_battleanimation.frame
  local counterattack = g_battleanimation.counterattack
  local friendly = g_battleanimation.friendly
  local enemy = g_battleanimation.enemy

  if frame > 30 and frame < 116 then
    local friendlystats = {
      pos = {
        x = 16,
        y = 69
      },
      width = 31
    }
    showstats(g_chosen, friendlystats)

    local enemystats = {
      pos = {
        x = 82,
        y = 69
      },
      width = 31
    }
    showstats(g_enemy, enemystats)
  end

  if frame <= 30 then
    zoom(0, 1)
  elseif frame > 60 and frame <= 63 then
    nudge("friendly", 1)
  elseif frame > 63 and frame <= 66 then
    damage("enemy")
    nudge("friendly", -1)
  elseif frame > 81 and frame <= 83 then
    if counterattack == true then
      nudge("enemy", -1)
    end
  elseif frame > 83 and frame <= 86 then
    if counterattack == true then
      damage("friendly")
      nudge("enemy", 1)
    end
  elseif frame > 116 and frame <= 146 then
    zoom(116, -1)
  elseif frame > 146 then
    if g_chosen.hp == 0 then
      die(g_chosen)
    else
      g_chosen.sprite = friendly.sprite
    end

    if g_enemy.hp == 0 then
      die(g_enemy)
    else
      g_enemy.sprite = enemy.sprite
    end

    g_battleanimation = nil
    endturn()
    return
  end

  local pos = spritepos(friendly.sprite)
  sspr(pos.x * 8, pos.y * 8, 8, 8, friendly.move.x, friendly.move.y, friendly.size.x, friendly.size.y)

  pos = spritepos(enemy.sprite)
  sspr(pos.x * 8, pos.y * 8, 8, 8, enemy.move.x, enemy.move.y, enemy.size.x, enemy.size.y)
end

function zoom(baseframe, direction)
  local progress

  if direction > 0 then
    progress = g_battleanimation.frame - baseframe
  else
    progress = 30 - (g_battleanimation.frame - baseframe)
  end

  local scale = 8 + 8 * (progress / 15)

  g_battleanimation.friendly.size = {
    x = scale,
    y = scale
  }

  g_battleanimation.friendly.move = {
    x = ((g_chosen.x - g_mapcorner.x) * 8 + (((29 - (g_chosen.x - g_mapcorner.x) * 8) / 30) * progress)) - g_battleanimation.friendly.size.x / 2 + 4,
    y = ((g_chosen.y - g_mapcorner.y) * 8 + (((40 - (g_chosen.y - g_mapcorner.y) * 8) / 30) * progress)) - g_battleanimation.friendly.size.y / 2 + 4
  }

  g_battleanimation.enemy.size = {
    x = scale,
    y = scale
  }

  g_battleanimation.enemy.move = {
    x = ((g_enemy.x - g_mapcorner.x) * 8 + (((95 - (g_enemy.x - g_mapcorner.x) * 8) / 30) * progress)) - g_battleanimation.enemy.size.x / 2 + 4,
    y = ((g_enemy.y - g_mapcorner.y) * 8 + (((40 - (g_enemy.y - g_mapcorner.y) * 8) / 30) * progress)) - g_battleanimation.enemy.size.y / 2 + 4
  }
end

function nudge(alignment, direction)
  g_battleanimation[alignment].move = {
    x = g_battleanimation[alignment].move.x + direction,
    y = g_battleanimation[alignment].move.y
  }
end

function damage(alignment)
  if alignment == "friendly"
  and g_enemy.hp > 0 then
    g_chosen.hp -= g_enemy.might / 3
    if g_chosen.hp < 1 then
      g_chosen.hp = 0
    end
  elseif alignment == "enemy"
  and g_chosen.hp > 0 then
    g_enemy.hp -= g_chosen.might / 3
    if g_enemy.hp < 1 then
      g_enemy.hp = 0
    end
  end
end

function die(unit)
  g_typemask[unit.x][unit.y] = "neutral"
  unit = {sprite = 0}
end

function endturn()
  g_chosen.actionover = true
  g_turnover = true

  for unit in all(g_units.good) do
    if unit.actionover == false then
      g_turnover = false
    end
  end

  if g_turnover == true then
    g_playerturn = false
  end
end

function showstats(unit, screen)
  statprint(unit.name, screen.pos.x, screen.pos.y, g_colors[unit.alignment], screen.width)
  statprint("lvl: 1", screen.pos.x, screen.pos.y + 8, g_colors[unit.alignment], screen.width)
  statprint("hp: " .. flr(unit.hp + 0.5), screen.pos.x, screen.pos.y + 16, g_colors[unit.alignment], screen.width)
end

function createunit(base, alignment, x, y)
  local new = copy(base)
  new.x = x
  new.y = y
  new.alignment = alignment
  new.sprite = g_sprites[base.name][alignment]
  g_typemask[x][y] = alignment
  new.moving = false
  new.actionover = false
  return new
end

function modifyunit(unit, modifications)
  for key, value in pairs(modifications) do
    unit[key] = value
  end
end

function moveunit(unit, x, y)
  modifyunit(unit, {
    x = x,
    y = y
  })
  unit.moving = false
  g_typemask[g_lastspace.x][g_lastspace.y] = "neutral"
  g_typemask[x][y] = unit.alignment
end

function getunit(x, y)
  for alignment, units in pairs(g_units) do
    for unit in all(units) do
      if unit.x == x and unit.y == y then
        return unit
      end
    end
  end
  return nil
end

function movespaces(x, y, passable, obstacles)
  g_friendlymoving = true
  explorerange(g_chosen.x, g_chosen.y, g_chosen.speed, 254, passable, obstacles)
end

function moveanimate()
  local segment = g_moveanimation.segment
  local select = g_moveanimation.select
  local begin = g_moveanimation.begin
  local finish = g_moveanimation.finish
  local pixelpos = g_moveanimation.pixelpos
  local sprite = g_moveanimation.sprite
  local attacktargets = g_moveanimation.attacktargets

  local currentcell = {
    x = pixelpos.x / 8,
    y = pixelpos.y / 8
  }

  if currentcell.x == begin.x
  and currentcell.y == begin.y then
    gridclear(g_bg, {sprite = 0})
  end

  if segment - 1 < #g_breadcrumbs[select.x][select.y] then
    if currentcell.x == g_breadcrumbs[select.x][select.y][segment].x
    and currentcell.y == g_breadcrumbs[select.x][select.y][segment].y then
      g_previousspace = {
        x = g_breadcrumbs[select.x][select.y][segment].x,
        y = g_breadcrumbs[select.x][select.y][segment].y
      }
      g_moveanimation.segment += 1
    else
      pixelpos.x += g_breadcrumbs[select.x][select.y][segment].x - g_previousspace.x
      pixelpos.y += g_breadcrumbs[select.x][select.y][segment].y - g_previousspace.y
    end

    local movescreenpos = {
      x = pixelpos.x - (g_mapcorner.x * 8),
      y = pixelpos.y - (g_mapcorner.y * 8)
    }

    spr(sprite, movescreenpos.x, movescreenpos.y)
  end

  if currentcell.x == finish.x
  and currentcell.y == finish.y then
    moveunit(g_chosen, finish.x, finish.y)
    g_friendlymoving = false
    g_enemymoving = false
    g_moveanimation = nil
    attackspaces(attacktargets)
  end
end

function move(x, y, friendlies, enemies)
  if g_back == false then
    g_lastspace = {
      x = g_chosen.x,
      y = g_chosen.y
    }

    g_moveanimation = {
      segment = 1,
      select = {
        x = g_select.x,
        y = g_select.y
      },
      begin = {
        x = g_chosen.x,
        y = g_chosen.y
      },
      finish = {
        x = x,
        y = y
      },
      pixelpos = {
        x = g_chosen.x * 8,
        y = g_chosen.y * 8
      },
      sprite = g_chosen.sprite,
      attacktargets = enemies
    }

    modifyunit(g_chosen, {
      moving = true
    })
  else
    g_typemask[g_chosen.x][g_chosen.y] = "neutral"
    moveunit(g_chosen, g_lastspace.x, g_lastspace.y)
    modifyunit(g_chosen, {
      moving = false
    })
    g_back = false
  end
end

function attackspaces(targets)
  local goodspaces = explorerange(g_chosen.x, g_chosen.y, g_chosen.attackmax, 253, targets, {})
  g_attackvalid = copy(g_valid)
  local badspaces = explorerange(g_chosen.x, g_chosen.y, g_chosen.attackmin, 0, targets, {})
  if goodspaces - badspaces > 0 then
    if g_playerturn == true then
      g_attacking = true
    else
      g_enemyattacking =  true
    end
  else
    endturn()
  end
end

function attack(target)
  g_enemy = getunit(target.x, target.y)

  gridclear(g_bg, {sprite = 0})

  if playerturn == true then
    g_attacking = false
  else
    g_enemyattacking = false
  end

  g_battleanimation = {
    frame = 0,
    friendly = {
      sprite = g_chosen.sprite
    },
    enemy = {
      sprite = g_enemy.sprite
    }
  }

  local counteralignment = nil
  if target.alignment == "good" then
    counteralignment = {"evil"}
  else
    counteralignment = {"good"}
  end

  explorerange(g_enemy.x, g_enemy.y, g_enemy.attackmax, 253, counteralignment, {})
  explorerange(g_enemy.x, g_enemy.y, g_enemy.attackmin, 0, counteralignment, {})

  if g_bg[g_chosen.x][g_chosen.y].sprite == 253 then
    g_battleanimation.counterattack = true
  else
    g_battleanimation.counterattack = false
  end

  gridclear(g_bg, {sprite = 0})
  g_chosen.sprite = 0
  g_enemy.sprite = 0
end

function explorerange(x, y, steps, sprite, alignments, obstacles)
  g_valid = {}
  g_spaces = 0
  crawlspace(x, y, steps, sprite, alignments, obstacles, {})
  return g_spaces
end

function crawlspace(x, y, steps, sprite, alignments, obstacles, breadcrumb)
  if g_valid[x] == nil then
    g_valid[x] = {}
  end

  if g_valid[x][y] == nil
  or g_valid[x][y] < steps then
    g_valid[x][y] = steps
  else
    return
  end

  for alignment in all(alignments) do
    if g_typemask[x][y] == alignment then
      g_bg[x][y] = {sprite = sprite}
      g_spaces += 1
    end
  end

  add(breadcrumb, {
    x = x,
    y = y
  })

  g_breadcrumbs[x][y] = copy(breadcrumb)

  if validspace(x - 1, y, steps, obstacles) then
    crawlspace(x - 1, y, steps - 1, sprite, alignments, obstacles, copy(breadcrumb))
  end

  if validspace(x + 1, y, steps, obstacles) then
    crawlspace(x + 1, y, steps - 1, sprite, alignments, obstacles, copy(breadcrumb))
  end

  if validspace(x, y - 1, steps, obstacles) then
    crawlspace(x, y - 1, steps - 1, sprite, alignments, obstacles, copy(breadcrumb))
  end

  if validspace(x, y + 1, steps, obstacles) then
    crawlspace(x, y + 1, steps - 1, sprite, alignments, obstacles, copy(breadcrumb))
  end
end

function validspace(x, y, steps, obstacles)
  if x < 0 or x >= 128 or y < 0 or y >= 32 then
    return false
  end

  for obstacle in all(obstacles) do
    if g_typemask[x][y] == obstacle then
      return false
    end
  end

  if steps <= 0 then
    return false
  end

  return true
end

__gfx__
000000000000007d000660000000007600f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007dc006666000000776600f500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000007dc0006666600000566000f540700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000557dc000005667700056560333333670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005dc000005357700053500000f040700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005355000053507000535000000f550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000053505000335000005350000000f500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000035000000030000003500000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d7000000000660006700000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cd700000006666006677000000002f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cd70000066666000662000007042f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cd7220776620000626200076eeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cd2000772e2000002e20007040f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000022e2000702e2000002e2000022f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000202e2000002ee000002e200002f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000002e000000e00000002e00000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb33bbbff4444ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb37a3bbf477ff4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b37abb3b477fff440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
37abbb3547ffff420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3abbb3354ffff4420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbb33554fff44220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3355bf444422f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb5555bbff2222ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111cc111111cc111111111111cc111111cc11111111111111111111111111111111cccccccccccccccc11cccccc11cccccccccccc11cccccc11
1111cc1111111111c111cc11c11111111111111c1111111c1111cc11111111111111cc1111111111cccc11cccccccccc1ccc11cc1cccccccccccccc1ccccccc1
11cc11cc11cc11cc11cc11cc11cc11cc111111111111111111cc11cc11cc11cc11cc11cc11cc11cccc11cc11cc11cc11cc11cc11cc11cc11cccccccccccccccc
111111111111cc11111111111111cc111111111111111111111111111111cc11111111111111cc11cccccccccccc11cccccccccccccc11cccccccccccccccccc
11111111111111111111111111111111111111111111111111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccccccccccccc
11cc11111111111111cc11111111111111cc11111111111111111111111111111111111111111111cc11cccccccccccccc11cccccccccccccc11cccccccccccc
cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11c1111111c11111111111111c1111111c11cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11cc
1111111111cc11111111111111cc11111111111111cc1111cc111111cc111111111111cc111111cccccccccccc11cccccccccccccc11cccccccccccccc11cccc
ccccccccccccccccccccccccccccccccffccccccffccccccccccccffccccccffccccccccccccccccccccccccccccccccffffffffccffffffffffffccffffffff
cccc11cccccccccccccc11ccccccccccfccc11ccfccccccccccccccfcccccccfcccc11cccccccccccccc11ccccccccccffffffffcffffffffffffffcffffffff
cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11cc11cccccccccccccccccc11cc11cc11cc11cc11cc11cc11cc11ffffffffffffffffffffffffffffffff
cccccccccccc11cccccccccccccc11cccccccccccccc11cccccccccccccccccccccccccccccc11cccccccccccccc11ccfffff7fffffff7fffffff7fffffff7ff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffff
cccccccccccccccccccccccccccccccccc11cccccccccccccc11ccccccccccccccccccccccccccccccccccccccccccccf7fffffff7fffffff7ffffffffffffff
1ccccccc1cccccccccccccc1ccccccc111cc11cc11cc11cc11cc11cc11cc11ccfcccccccfccccccccccccccfcccccccfffffffffffffffffffffffffcfffffff
11cccccc11cccccccccccc11cccccc11cccccccccc11cccccccccccccc11ccccffccccccffccccccccccccffccccccffffffffffffffffffffffffffccffffff
ffffffffbbffffffffffffbbffffffffffffffffbbbbabbbffbbabbbbbbbabffbbbbabbbbbbbabbb99bbabbbbbbbab99bbbbabbbbbbbabbb99949994bb949994
ffffffffbffffffffffffffbffffffffffffffffbabbabbbfabbabbbbabbabbfbabbabbbbabbabbb9abbabbbbabbabb9babbabbbbabbabbb49999999b9999999
ffffffffffffffffffffffffffffffffffffffffbabbbbabbabbbbabbabbbbabbabbbbabbabbbbabbabbbbabbabbbbabbabbbbabbabbbbab9994999499949994
fffff7fffffff7fffffff7fffffff7fffffff7ffbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbab9999999999999999
ffffffffffffffffffffffffffffffffffffffffbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbb9949999999499999
f7fffffff7fffffff7fffffffffffffff7ffffffbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbb9999994999999949
fffffffcffffffffffffffffbffffffffffffffbabbbbbbbabbbbbbbabbbbbbbfbbbbbbbabbbbbbfabbbbbbbabbbbbbb9bbbbbbbabbbbbb94999999949999999
ffffffccffffffffffffffffbbffffffffffffbbabbbbbbbabbbbbbbabbbbbbbffbbbbbbabbbbbffabbbbbbbabbbbbbb99bbbbbbabbbbb999949999999499999
999499bb999499949994999444444444222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc77000077
4999999b499999994999999944444444222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc70000007
99949994999499949994999444448444222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc00000000
99999999999999999999999944444884222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc00000000
99499999994999999949999944444444222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc00000000
99999949999999499999994944444444222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc00000000
49999999b99999994999999b84444444222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc70000007
99499999bb499999994999bb48844444222222220000000000000000000000000000000000000000000000000000000000000000aaaaaaaacccccccc77000077
__gff__
0000080000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
cacacacacacacacacadcdcdcdcdcdcdcdcdcdcdcdcdcdcdce5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cacacacacacacacacadfdcdcdcdcdcdcdcdcdcdcdcdcdcdce5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cacacacacacacacacacad6dcdcdcdcdcdcdcdcdcdcdcdcdce5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cacacacacacacacacacacadfdcdcdcdcdcdcdcdcdcdcdcdce8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cacacacacacacacacacacacad6dcdcdcdcdcdcdcdcdcdcdcdce2e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
cacacacacacacacacacacacacadfdcdcdcdcdcdcdcdcdcdcdcdce8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c0c0c4cacacacacacacacacacacacad6dcdcdcdcdcdcdcdcdcdcdce2e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5ebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c0c0c0d0cacacacacacacacacacacacadfdcdcdcdcdcdcdcdcdcdcdce8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c0c0c0c0c0c0c0c4cacacacacacacacacacad6dcdcdcdcdcdcdcdcdcdce2e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5ebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c0c0c0c0c0c0c0c0d0cacacacacacacacacacadfdcdcdcdcdcdcdcdcdcdce8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c0c0c0c0c0c0c0c0c0c0c4cacacacacacacacacacacacacacacad6dcdcdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5ebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c0c0c0c0c0c0c0c0c0c0c0cacacacacacacacacacacacacacacacadfdcdcdcdcdcdcdcdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c0c0c0c0c0c0c0c0c0c0c0d0cacacacacacacacacacacacacacacacacacacacacacacacad6dfdcdcdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5ebf1eeeeeeeeeeeeeeeeeeee
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c4cacacacacacacacacacacacacacacacacacacacacacacacacacad6dfdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0cacacacacacacacacacacacacacacacacacacacacacacacacacacacad6dfdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e9e1dcdcdcdcdcdcdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacad6dfdcdcdcdcdcdcdcf3f3f3f3dcdce0d4cacacacacacad6dfdcdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c8cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacad6dfdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f4f4f4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f4f4f4e5e5
c0c0c0c0c0c0c0c0c0c0c0c0c0cccacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacad6dfdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4e5e5e5f4f4f4e5e5e5f4f4f4e5e5e5f4f3f3f4e5e5
c0c0c0c0c0c0c0c0c0c0c0c0c8cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacacacacad6dcdcdce2e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4f4f4f4f4f3f4f4f4f4f4f3f4f4f4f4f4f3f3f4e5e5
c0c0c0c0c0c0c0c0c0cccacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacacacacadadcdcdce4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f4f3f3f4f3f3f4f3f3f3f3f3f3f3f3f3f3f3f3f3f4f4e5e5
c0c0c0c0c0c0c0c0c8cacacacacacacacacacacacacacadadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcded8cacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacadadddcdce4e6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4f3f3f4f3f3f3f3f3f3f3f3f3f3f3f3f3f4e5e5e5
c0c0c0c0c0cccacacacacacacacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcded8cacacacacacaf3f3f3f3cacacacacacacacacacacacacadadddcdce4e6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4f3f3f4f3f3f3f3f3f3f3f3f3f3f3f3f3f4e5e5e5
c0c0c0c0c8cacacacacacacacacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e7e3dcdcdcdcdcdcdcf3f3f3f3cacacacacacacacadadddcdcdcdce4e6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f4e5e5e5
c0c0cccacacacacacacacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5f3f3f3f3dcdcdcdcdcdcdcdcdce4e6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f4e5e5e5
c0c8cacacacacacacacacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4f3f3f4f3f3f3f3f3f3f3f3f3f3f3f3f3f4e5e5e5
cacacacacacacacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4f3f3f4f3f3f3f3f3f3f3f3f3f3f3f3f3f4e5e5e5
cacacacacacacacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f4f3f3f4f3f3f4f3f3f3f3f3f3f3f3f3f3f3f3f3f4f4e5e5
cacacacacacacacacacacadadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4f4f4f4f4f3f4f4f4f4f4f3f4f4f4f4f4f3f3f4e5e5
cacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f3f3f4e5e5e5f4f4f4e5e5e5f4f4f4e5e5e5f4f3f3f4e5e5
cacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f4f4f4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f4f4f4f4e5e5
cacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
cacacacacacadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
__sfx__
00010000000000000000000000003400000000000001b0001b000000001c000000001e00020000230002500028000290002a0002c0002c0002c00000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
