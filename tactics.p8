pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

-- prefix global variables with g_
g_numportals = 5
g_select = {x = 18, y = 0}
g_gridsize = {x = 128, y = 32}

-- state variables
g_turn = "player"
g_moving = false
g_attacking = false

g_back = false
g_alternate = 20
g_moveanimation = nil
g_spaces = nil

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
  },
  bear = {
    evil = 64
  },
  wolf = {
    evil = 65
  },
  raven = {
    evil = 66
  },
  snake = {
    evil = 67
  },
  deer = {
    evil = 68
  },
  shark = {
    evil = 69
  },
  frog = {
    evil = 70
  }
}

g_archetypes = {
  knight = {
    basehp = 10,
    basemight = 3,
    basespeed = 2,
    levelhp = 3,
    levelmight = 2,
    levelspeed = 1,
    attackmin = 0,
    attackmax = 1,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  dwarf = {
    basehp = 15,
    basemight = 4,
    basespeed = 1,
    levelhp = 5,
    levelmight = 3,
    levelspeed = 1,
    attackmin = 0,
    attackmax = 1,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  lancer = {
    basehp = 10,
    basemight = 2,
    basespeed = 2,
    levelhp = 2,
    levelmight = 1,
    levelspeed = 1,
    attackmin = 0,
    attackmax = 2,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  archer = {
    basehp = 5,
    basemight = 1,
    basespeed = 3,
    levelhp = 1,
    levelmight = 1,
    levelspeed = 1,
    attackmin = 1,
    attackmax = 2,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  bear = {
    basehp = 10,
    basemight = 3,
    basespeed = 3,
    levelhp = 2,
    levelmight = 2,
    levelspeed = 2,
    attackmin = 0,
    attackmax = 1,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  wolf = {
    basehp = 5,
    basemight = 1,
    basespeed = 4,
    levelhp = 2,
    levelmight = 1,
    levelspeed = 2,
    attackmin = 0,
    attackmax = 2,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  raven = {
    basehp = 2,
    basemight = 1,
    basespeed = 6,
    levelhp = 1,
    levelmight = 1,
    levelspeed = 2,
    attackmin = 0,
    attackmax = 1,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  snake = {
    basehp = 1,
    basemight = 1,
    basespeed = 3,
    levelhp = 1,
    levelmight = 1,
    levelspeed = 2,
    attackmin = 0,
    attackmax = 1,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  deer = {
    basehp = 4,
    basemight = 1,
    basespeed = 2,
    levelhp = 1,
    levelmight = 1,
    levelspeed = 2,
    attackmin = 0,
    attackmax = 2,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  shark = {
    basehp = 4,
    basemight = 1,
    basespeed = 3,
    levelhp = 1,
    levelmight = 1,
    levelspeed = 3,
    attackmin = 0,
    attackmax = 2,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  },
  frog = {
    basehp = 2,
    basemight = 1,
    basespeed = 2,
    levelhp = 1,
    levelmight = 1,
    levelspeed = 2,
    attackmin = 0,
    attackmax = 2,
    maxhp = 0,
    hp = 0,
    might = 0,
    speed = 0
  }
}

g_terrainsprites = {
  deepwater = {
    min = 192,
    max = 201
  },
  water = {
    min = 202,
    max = 219
  },
  beach = {
    min = 220,
    max = 228
  },
  grass = {
    min = 229,
    max = 237
  },
  sand = {
    min = 238,
    max = 242
  },
  bridge = {
    min = 243,
    max = 243
  }
}

function _init()
  g_bg = gridinit()
  g_breadcrumbs = gridinit()
  g_typemask = gridinit()
  g_terrain = gridinit()

  gridclear(g_bg, {sprite = 0})
  gridclear(g_breadcrumbs, {})
  gridclear(g_typemask, "neutral")

  processterrain()

  add(g_units.good, createunit("dwarf", 1, "good", 23, 0))
  add(g_units.evil, createunit("bear", 1, "evil", 20, 4))
  add(g_units.evil, createunit("raven", 1, "evil", 21, 4))
  add(g_units.evil, createunit("snake", 1, "evil", 22, 4))
  add(g_units.evil, createunit("deer", 1, "evil", 23, 4))
  add(g_units.evil, createunit("shark", 1, "evil", 24, 4))
  add(g_units.evil, createunit("frog", 1, "evil", 25, 4))

  for i=0, g_gridsize.x do
    for j=0, g_gridsize.y do
      local sprite = mget(i, j)
      if sprite > 127 and sprite < 192 then
        g_typemask[i][j] = "obstacle"
      end
    end
  end
end

function _update()
  if g_turn == "player" then
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

  print(g_terrain[g_select.x][g_select.y], 8, 8, 4)
end

function processterrain()
  for i=0, g_gridsize.x - 1 do
    for j=0, g_gridsize.y - 1 do
      for terrain in pairs(g_terrainsprites) do
        if mget(i, j) >= g_terrainsprites[terrain].min
        and mget(i, j) <= g_terrainsprites[terrain].max then
          g_terrain[i][j] = terrain
        end
      end
    end
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
    if g_moving == false
    and g_attacking == false then
      for unit in all(getunit(g_select.x, g_select.y)) do
        g_chosen = unit
      end
      if g_chosen != nil
      and g_chosen.alignment == "good"
      and g_chosen.actionover == false then
        g_moving = "player"
        g_spaces = exploremoves(g_chosen.x, g_chosen.y, {"good", "neutral"}, {"obstacle", "evil"})
      end
    elseif g_moving == "player"
    and g_attacking == false
    and g_valid[g_select.x] != nil
    and g_valid[g_select.x][g_select.y] != nil then
      if validaction("move") then
        move(g_select.x, g_select.y, {"good", "neutral"}, {"evil"})
      end
    elseif g_moving == false
    and g_attacking == "player"
    and g_battleanimation == nil then
      if validaction("attack") then
        attack({
          x = g_select.x,
          y = g_select.y
        })
      elseif g_select.x == g_chosen.x and g_select.y == g_chosen.y then
        gridclear(g_bg, {sprite = 0})
        g_moving = false
        g_attacking = false
        endaction()
      end
    end
  end

  if btnp(5) then
    if g_moving == "player"
    and g_attacking == false then
      gridclear(g_bg, {sprite = 0})
      g_moving = false
      modifyunit(g_chosen, {
        moving = false
      })
    elseif g_moving == false
    and g_attacking == "player" then
      g_back = true
      gridclear(g_bg, {sprite = 0})
      move(g_lastspace.x, g_lastspace.y, {"good", "neutral"}, {"evil"})
      g_spaces = exploremoves(g_chosen.x, g_chosen.y, {"good", "neutral"}, {"obstacle", "evil"})
      g_moving = "player"
      g_attacking = false
    end
  end
end

function validaction(type)
  for space in all(g_spaces) do
    if g_select.x == space.x and g_select.y == space.y then
      if type == "move" then
        if g_typemask[g_select.x][g_select.y] == "neutral" then
          return true
        elseif g_select.x == g_chosen.x and g_select.y == g_chosen.y then
          for unit in all(getunit(g_select.x, g_select.y)) do
            return true
          end
        end
      elseif type == "attack" then
        return true
      end
    end
  end
  return false
end

function movespace()
  for space in all(g_spaces) do
    if g_typemask[space.x][space.y] == "neutral" then
      local attackspaces = minmaxrange(space.x, space.y, g_chosen.attackmin, g_chosen.attackmax, nil, nil, {"good"}, {}, false)
      if #attackspaces == 1 then
        return space
      end
    end
  end

  return randomspace()
end

function attackspace()
  return randomspace()
end

function randomspace()
  local attempted = {}
  while #attempted < #g_spaces do
    local random = flr(rnd(#g_spaces))
    if inarray(random, attempted) == false then
      add(attempted, random)
      local space = g_spaces[flr(rnd(#g_spaces)) + 1]
      if space.x == g_chosen.x and space.y == g_chosen.y and #getunit(space.x, space.y) == 1 then
        return space
      elseif g_typemask[space.x][space.y] != "evil" then
        return space
      end
    end
  end
  return {
    x = g_chosen.x,
    y = g_chosen.y
  }
end

function unitdistance(unit1, unit2)
  return abs(unit1.x - unit2.x) + abs(unit1.y - unit2.y)
end

function towardcomrade(unit)
  local nearestdistance = 127
  local nearestcomrade = nil

  for comrade in all(g_units.evil) do
    if comrade.x != unit.x and comrade.y != unit.y then
      local distance = unitdistance(unit, comrade)
      if distance < nearestdistance then
        nearestdistance = distance
        nearestcomrade = comrade
      end
    end
  end

  local space = {
    x = unit.x,
    y = unit.y
  }

  if nearestcomrade != nil then
    local closerx = copy(space)
    if unit.x - nearestcomrade.x > 0 then
      closerx.x -= 1
    else
      closerx.x += 1
    end

    local closery = copy(space)
    if unit.y - nearestcomrade.y > 0 then
      closery.y -= 1
    else
      closery.y += 1
    end

    local randomaxis = flr(rnd(2))
    if randomaxis == 0 then
      if unitdistance(closerx, nearestcomrade) < unitdistance(unit, nearestcomrade) and g_typemask[closerx.x][closerx.y] == "neutral" then
        return closerx
      elseif unitdistance(closery, nearestcomrade) < unitdistance(unit, nearestcomrade) and g_typemask[closery.x][closery.y] == "neutral" then
        return closery
      end
    else
      if unitdistance(closery, nearestcomrade) < unitdistance(unit, nearestcomrade) and g_typemask[closery.x][closery.y] == "neutral" then
        return closery
      elseif unitdistance(closerx, nearestcomrade) < unitdistance(unit, nearestcomrade) and g_typemask[closerx.x][closerx.y] == "neutral" then
        return closerx
      end
    end
  end

  return movespace()
end

function enemyturn()
  if g_moving == false and g_attacking == false and g_battleanimation == nil then
    for unit in all(g_units.evil) do
      if unit.actionover == false then
        g_mapcorner = {
          x = unit.x - 8,
          y = unit.y - 8
        }

        if g_mapcorner.x < 0 then
          g_mapcorner.x = 0
        elseif g_mapcorner.x + 16 > 127 then
          g_mapcorner.x = 111
        end

        if g_mapcorner.y < 0 then
          g_mapcorner.y = 0
        elseif g_mapcorner.y + 16 > 31 then
          g_mapcorner.y = 15
        end

        g_chosen = unit
        local comrades = minmaxrange(g_chosen.x, g_chosen.y, 0, 6, nil, nil, {"evil"}, {}, false)
        g_spaces = exploremoves(g_chosen.x, g_chosen.y, {"evil", "neutral"}, {"obstacle", "good"})

        if #comrades == 0 then
          g_select = towardcomrade(g_chosen)
        else
          g_select = movespace()
        end

        g_moving = "enemy"
        move(g_select.x, g_select.y, {"evil", "neutral"}, {"good"})
        return
      end
    end
  elseif g_moving == false and g_attacking == "enemy" then
    attack(attackspace())
    g_attacking = false
  end
end

function copy(src)
  local dest = {}
  for key, value in pairs(src) do
    dest[key] = value
  end
  return dest
end

function inarray(needle, haystack)
  for item in all(haystack) do
    if item == needle then
      return true
    end
  end
  return false
end

function subtractspaces(sequence1, sequence2)
  local different = false

  for obj1 in all(sequence1) do
    for obj2 in all(sequence2) do
      for key, value in pairs(obj2) do
        if obj1[key] != value then
          different = true
        end
      end
      if different == false then
        del(sequence1, obj1)
      end
    end
  end

  return sequence1
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

  local unit = getunit(g_select.x, g_select.y)[1]
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
  local good = g_battleanimation.good
  local evil = g_battleanimation.evil

  local statpos = {
    good = {
      x = 16,
      y = 69
    },
    evil = {
      x = 82,
      y = 69
    }
  }

  if frame > 30 and frame < 116 then
    local friendlystats = {
      pos = statpos[g_chosen.alignment],
      width = 31
    }
    showstats(g_chosen, friendlystats)

    local enemystats = {
      pos = statpos[g_enemy.alignment],
      width = 31
    }
    showstats(g_enemy, enemystats)
  end

  local nudgefactor
  if good.alignment == "good" then
    nudgefactor = 1
  else
    nudgefactor = -1
  end

  if frame <= 30 then
    zoom(0, 1)
  elseif frame > 60 and frame <= 63 then
    nudge("good", 1 * nudgefactor)
  elseif frame > 63 and frame <= 66 then
    damage("evil")
    nudge("good", -1 * nudgefactor)
  elseif frame > 81 and frame <= 83 then
    if counterattack == true and g_enemy.hp > 0 then
      nudge("evil", -1 * nudgefactor)
    end
  elseif frame > 83 and frame <= 86 then
    if counterattack == true and g_enemy.hp > 0 then
      damage("good")
      nudge("evil", 1 * nudgefactor)
    end
  elseif frame > 116 and frame <= 146 then
    zoom(116, -1)
  elseif frame > 146 then
    if g_chosen.hp == 0 then
      die(g_chosen)
    else
      g_chosen.sprite = good.sprite
    end

    if g_enemy.hp == 0 then
      die(g_enemy)
    else
      g_enemy.sprite = evil.sprite
    end

    g_battleanimation = nil
    g_attacking = false

    endaction()
    return
  end

  local pos = spritepos(good.sprite)
  sspr(pos.x * 8, pos.y * 8, 8, 8, good.move.x, good.move.y, good.size.x, good.size.y)

  pos = spritepos(evil.sprite)
  sspr(pos.x * 8, pos.y * 8, 8, 8, evil.move.x, evil.move.y, evil.size.x, evil.size.y)
end

function zoom(baseframe, direction)
  local progress

  local zoompos = {
    good = {
      x = 29,
      y = 40
    },
    evil = {
      x = 95,
      y = 40
    }
  }

  if direction > 0 then
    progress = g_battleanimation.frame - baseframe
  else
    progress = 30 - (g_battleanimation.frame - baseframe)
  end

  local scale = 8 + 8 * (progress / 15)

  g_battleanimation.good.size = {
    x = scale,
    y = scale
  }

  g_battleanimation.good.move = {
    x = ((g_chosen.x - g_mapcorner.x) * 8 + (((zoompos[g_chosen.alignment].x - (g_chosen.x - g_mapcorner.x) * 8) / 30) * progress)) - g_battleanimation.good.size.x / 2 + 4,
    y = ((g_chosen.y - g_mapcorner.y) * 8 + (((zoompos[g_chosen.alignment].y - (g_chosen.y - g_mapcorner.y) * 8) / 30) * progress)) - g_battleanimation.good.size.y / 2 + 4
  }

  g_battleanimation.evil.size = {
    x = scale,
    y = scale
  }

  g_battleanimation.evil.move = {
    x = ((g_enemy.x - g_mapcorner.x) * 8 + (((zoompos[g_enemy.alignment].x - (g_enemy.x - g_mapcorner.x) * 8) / 30) * progress)) - g_battleanimation.evil.size.x / 2 + 4,
    y = ((g_enemy.y - g_mapcorner.y) * 8 + (((zoompos[g_enemy.alignment].y - (g_enemy.y - g_mapcorner.y) * 8) / 30) * progress)) - g_battleanimation.evil.size.y / 2 + 4
  }
end

function nudge(alignment, direction)
  g_battleanimation[alignment].move = {
    x = g_battleanimation[alignment].move.x + direction,
    y = g_battleanimation[alignment].move.y
  }
end

function damage(alignment)
  if alignment == "good"
  and g_enemy.hp > 0 then
    g_chosen.hp -= g_enemy.might / 3 * g_enemy.level
    g_enemy.xp += g_chosen.level / 10
    if g_chosen.hp < 1 then
      g_chosen.hp = 0
      g_enemy.xp += g_chosen.level / 5
    end
    if g_enemy.xp >= 3 ^ g_chosen.level then
      g_enemy.xp = 0
      levelup(g_enemy, g_enemy.level + 1)
    end
  elseif alignment == "evil"
  and g_chosen.hp > 0 then
    g_enemy.hp -= g_chosen.might / 3 * g_chosen.level
    g_chosen.xp += g_enemy.level / 10
    if g_enemy.hp < 1 then
      g_enemy.hp = 0
      g_chosen.xp += g_enemy.level / 5
    end
    if g_chosen.xp >= 3 ^ g_chosen.level then
      g_chosen.xp = 0
      levelup(g_chosen, g_chosen.level + 1)
    end
  end
end

function die(dyingunit)
  g_typemask[dyingunit.x][dyingunit.y] = "neutral"

  for alignment, units in pairs(g_units) do
    for unit in all(units) do
      if dyingunit == unit then
        del(units, unit)
      end
    end
  end
end

function endaction()
  g_chosen.actionover = true
  local turnover = true

  if g_turn == "player" then
    for unit in all(g_units.good) do
      if unit.actionover == false then
        turnover = false
      end
    end

    if turnover == true then
      endturn("player")
    end
  else
    for unit in all(g_units.evil) do
      if unit.actionover == false then
        turnover = false
      end
    end

    if turnover == true then
      endturn("enemy")
    end
  end
end

function endturn(side)
  if side == "player" then
    g_turn = "enemy"

    for unit in all(g_units.evil) do
      unit.actionover = false
    end

    g_lastselect = {
      x = g_select.x,
      y = g_select.y
    }

    g_lastmapcorner = {
      x = g_mapcorner.x,
      y = g_mapcorner.y,
    }
  else
    g_turn = "player"

    for unit in all(g_units.good) do
      unit.actionover = false
      if unit.hp < unit.maxhp then
        unit.hp += 1
      end
    end

    g_select = {
      x = g_lastselect.x,
      y = g_lastselect.y
    }

    g_mapcorner = {
      x = g_lastmapcorner.x,
      y = g_lastmapcorner.y
    }
  end

  g_moving = false
  g_attacking = false
end

function showstats(unit, screen)
  statprint(unit.type, screen.pos.x, screen.pos.y, g_colors[unit.alignment], screen.width)
  statprint("lvl:" .. unit.level, screen.pos.x, screen.pos.y + 8, g_colors[unit.alignment], screen.width)
  statprint("hp:" .. flr(unit.hp + 0.5), screen.pos.x, screen.pos.y + 16, g_colors[unit.alignment], screen.width)
  statprint("xp:" .. flr((unit.xp / (3 ^ unit.level)) * 100) .. "%", screen.pos.x, screen.pos.y + 24, g_colors[unit.alignment], screen.width)
end

function createunit(type, level, alignment, x, y)
  local new = copy(g_archetypes[type])
  new.sprite = g_sprites[type][alignment]
  new.type = type
  new.level = level
  new.alignment = alignment
  new.x = x
  new.y = y
  new.xp = 0
  new.moving = false
  new.actionover = false

  levelup(new, level)
  new.hp = new.maxhp

  g_typemask[x][y] = alignment
  return new
end

function modifyunit(unit, modifications)
  for key, value in pairs(modifications) do
    unit[key] = value
  end
end

function levelup(unit, level)
  modifyunit(unit, {
    maxhp = unit.basehp + unit.levelhp * (level - 1),
    might = unit.basemight + unit.levelmight * (level - 1),
    speed = unit.basespeed + unit.levelspeed * (level - 1),
    level = level
  })
end

function moveunit(unit, x, y)
  modifyunit(unit, {
    x = x,
    y = y
  })
  unit.moving = false
  if #getunit(g_lastspace.x, g_lastspace.y) == 0 then
    g_typemask[g_lastspace.x][g_lastspace.y] = "neutral"
  end
  g_typemask[x][y] = unit.alignment
end

function getunit(x, y)
  local found = {}
  for alignment, units in pairs(g_units) do
    for unit in all(units) do
      if unit.x == x and unit.y == y then
        add(found, unit)
      end
    end
  end
  return found
end

function exploremoves(x, y, passable, obstacles)
  return explorerange(g_chosen.x, g_chosen.y, g_chosen.speed, 254, passable, obstacles, true)
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
    g_moving = false
    g_moveanimation = nil
    g_spaces = exploreattacks(attacktargets)
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

function exploreattacks(targets)
  local attackspaces = minmaxrange(g_chosen.x, g_chosen.y, g_chosen.attackmin, g_chosen.attackmax, 0, 253, targets, {}, true)
  if #attackspaces > 0 then
    if g_turn == "player" then
      g_attacking = "player"
    else
      g_attacking = "enemy"
    end
  else
    endaction()
  end

  return attackspaces
end

function attack(target)
  g_enemy = getunit(target.x, target.y)[1]

  gridclear(g_bg, {sprite = 0})

  g_battleanimation = {
    frame = 0,
    good = {
      sprite = g_chosen.sprite,
      alignment = g_chosen.alignment
    },
    evil = {
      sprite = g_enemy.sprite,
      alignment = g_enemy.alignment
    }
  }

  local counteralignment = nil
  if g_enemy.alignment == "good" then
    counteralignment = {"evil"}
  else
    counteralignment = {"good"}
  end

  local g_spaces = minmaxrange(g_enemy.x, g_enemy.y, g_enemy.attackmin, g_enemy.attackmax, 0, 253, counteralignment, {}, true)

  g_battleanimation.counterattack = false
  for space in all(g_spaces) do
    if space.x == g_chosen.x and space.y == g_chosen.y then
      g_battleanimation.counterattack = true
    end
  end

  gridclear(g_bg, {sprite = 0})
  g_chosen.sprite = 0
  g_enemy.sprite = 0
end

function explorerange(x, y, steps, sprite, alignments, obstacles, storebreadcrumb)
  g_valid = {}
  spaces = {}
  return crawlspace(x, y, steps, sprite, alignments, obstacles, {}, storebreadcrumb, spaces)
end

function minmaxrange(x, y, min, max, minsprite, maxsprite, targets, obstacles, storebreadcrumb)
  local maxspaces = explorerange(x, y, max, maxsprite, targets, obstacles, storebreadcrumb)
  local minspaces = explorerange(x, y, min, minsprite, targets, obstacles, storebreadcrumb)
  return subtractspaces(maxspaces, minspaces)
end

function crawlspace(x, y, steps, sprite, alignments, obstacles, breadcrumb, storebreadcrumb, spaces)
  if g_valid[x] == nil then
    g_valid[x] = {}
  end

  if g_valid[x][y] == nil then
    g_valid[x][y] = {}
  end

  local betterpath = g_valid[x][y].steps == nil or g_valid[x][y].steps < steps

  if betterpath == true then
    g_valid[x][y].steps = steps
    g_valid[x][y].alignment = g_typemask[x][y]
    for alignment in all(alignments) do
      if g_typemask[x][y] == alignment then
        if sprite != nil then
          g_bg[x][y] = {sprite = sprite}
        end
        add(spaces, {
          x = x,
          y = y
        })
      end
    end
  end

  add(breadcrumb, {
    x = x,
    y = y
  })

  if storebreadcrumb == true and betterpath == true then
    g_breadcrumbs[x][y] = copy(breadcrumb)
  end

  if validspace(x - 1, y, steps, obstacles) then
    crawlspace(x - 1, y, steps - 1, sprite, alignments, obstacles, copy(breadcrumb), storebreadcrumb, spaces)
  end

  if validspace(x + 1, y, steps, obstacles) then
    crawlspace(x + 1, y, steps - 1, sprite, alignments, obstacles, copy(breadcrumb), storebreadcrumb, spaces)
  end

  if validspace(x, y - 1, steps, obstacles) then
    crawlspace(x, y - 1, steps - 1, sprite, alignments, obstacles, copy(breadcrumb), storebreadcrumb, spaces)
  end

  if validspace(x, y + 1, steps, obstacles) then
    crawlspace(x, y + 1, steps - 1, sprite, alignments, obstacles, copy(breadcrumb), storebreadcrumb, spaces)
  end

  return spaces
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
44000044060000600022220000333300505005050000600003300330000000000000000000000000000000000000000000000000000000000000000000000000
2444444206666660021111200333333055500555000c600007733770000000000000000000000000000000000000000000000000000000000000000000000000
4774477407766770211111120323323004444440000c600007133170000000000000000000000000000000000000000000000000000000000000000000000000
471441740716617021911912033333300444444000cccc0033333333000000000000000000000000000000000000000000000000000000000000000000000000
44444444066666600111611000333300041441400cccccc033333333000000000000000000000000000000000000000000000000000000000000000000000000
4441144406666660001761000003300004444440cc8cc8cc33888833000000000000000000000000000000000000000000000000000000000000000000000000
04444440006116000007600000004000004444000c7117c003333330000000000000000000000000000000000000000000000000000000000000000000000000
00444400000110000007000000004000000110000077770000333300000000000000000000000000000000000000000000000000000000000000000000000000
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
cacacacacacacacacacad6dcdcdcdcdcdcdcdcdcdcdcdcdce580e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c8cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacad6dfdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0c0c0c0c0c0c0c0c0cccacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacad6dfdcdce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0c0c0c0c0c0c0c0c8cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacacacacad6dfe2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0c0c0c0c0cccacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacacacacacad6dfe2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0c0c0c0c8cacacacacacacacacacacacacacadadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcded8cacacacacacacacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacacacacacacad6dfe2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e1dcdcdcdcdce2e8e5e5e5e5e5e5e5e5e5e5
c0c0c0c0c0cccacacacacacacacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcded8cacacacacacaf3f3f3f3cacacacacacacacacacacacacacacacacacacacacacad6dfe2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e9e1dcdcdce0d4cacacad6dfdcdce2e8e5e5e5e5e5e5e5
c0c0c0c0c8cacacacacacacacacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e7e3dcdcdcdcdcdcdcf3f3f3f3cacacacacacacacacacacacacacacacacacacacacacacad6dfe2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e9e1dcdcdce0d4cacacacacacacacacacad6dfdcdce2e8e5e5e5e5
c0c0cccacacacacacacacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5f3f3f3f3dcdcdcdcdcded8cacacacacacacacacacacacacacacacacad6dfdce2e8e5e5e5e5e5e5e5e5e5e5e1dcdcdcdcd4cacacacacacacacacacacacacacacacacad6dfe2e5e5e5e5
c0c8cacacacacacacacacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcdcdcded8cacacacacacacacacacacacacacacacad6dce2e5e5e5e5e5e5e5e5e5e5e3dcdcdcdcd8cacacacacacacacacacacacacacacacacacad6dce8e5e5e5
cacacacacacacacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcded8cacacacacacacacacacacacacacacacadfdce8e5e5e5e5e5e5e5e5e5e5e7e3dcdcdcdcded8cacacacacacacacacacacacacacacacadce2e5e5e5
cacacacacacacacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcded8cacacacacacacacacacacacacacad6dce2e8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcdcdcdcdcded8cacacacacacacacacadcdce5e5e5
cacacacacacacacacacacadadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcded8cacacacacacacacacacacacacadfdce2e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcdcded8cacacacadadce4e5e5e5
cacacacacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcded8cacacacacacacacacacacacad6dcdce8e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcdcdcdcdce4e6e5e5e5
cacacacacacacacadadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce4e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcded8cacacacacacacacacacacadcdce2e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
cacacacacacadddcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce6e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7e3dcdcded8cacacacacacacacacacadcdcdce5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
cacacacacacadcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdce5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e7dcdcdecacacacacacacacacacadcdcdce5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5
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

