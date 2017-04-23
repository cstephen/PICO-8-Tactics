pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
select = {x = 18, y = 0}
moving = false
attacking = false
gridsize = {x = 128, y = 32}
alternate = 20
moveanimation = nil

mapcorner = {
  x = 18,
  y = 0
}

mapanimatecounter = 0

mapanimations = {
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

colors = {
  good = 11,
  evil = 14
}

sprites = {
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

knight = {
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

dwarf = {
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

lancer = {
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

archer = {
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
  bg = gridinit()
  fg = gridinit()
  breadcrumbs = gridinit()
  typemask = gridinit()

  gridclear(bg, {sprite = 0})
  gridclear(fg, {sprite = 0})
  gridclear(breadcrumbs, {})
  gridclear(typemask, "neutral")

  place(18, 0, unit(knight, "good"))
  fg[0][18].hp = 7

  place(19, 0, unit(dwarf, "good"))
  fg[0][19].hp = 2

  place(22, 1, unit(dwarf, "evil"))
  fg[1][22].hp = 7

  place(21, 0, unit(archer, "good"))
  fg[0][21].hp = 5
end

function _update()
  if btnp(0) then
    if select.x > 0
    and animation == nil then
      select.x -= 1
      if select.x - mapcorner.x < 0 then
        mapcorner.x -= 1
        mapsliceanimate(0, nil)
      end
    end
  end

  if btnp(1) then
    if select.x < 127
    and animation == nil then
      select.x += 1
      if select.x - mapcorner.x > 15 then
        mapcorner.x += 1
        mapsliceanimate(15, nil)
      end
    end
  end

  if btnp(2) then
    if select.y > 0
    and animation == nil then
      select.y -= 1
      if select.y - mapcorner.y < 0 then
        mapcorner.y -= 1
        mapsliceanimate(nil, 0)
      end
    end
  end

  if btnp(3) then
    if select.y < 31
    and animation == nil then
      select.y += 1
      if select.y - mapcorner.y > 15 then
        mapcorner.y += 1
        mapsliceanimate(nil, 15)
      end
    end
  end

  if btnp(4) then
    if moving == false
    and attacking == false
    and typemask[select.x][select.y] == "good" then
      movespaces(select.x, select.y)
    elseif moving == true
    and attacking == false
    and valid[select.x] != nil
    and valid[select.x][select.y] != nil then
      if typemask[select.x][select.y] == "neutral"
      or (select.x == friendly.x and select.y == friendly.y) then
        move(select.x, select.y)
      end
    elseif moving == false
    and attacking == true then
      if bg[select.x][select.y].sprite == 253 then
        attack()
      elseif select.x == friendly.x and select.y == friendly.y then
        gridclear(bg, {sprite = 0})
        moving = false
        attacking = false
      end
    end
  end

  if btnp(5) then
    if moving == true
    and attacking == false then
      gridclear(bg, {sprite = 0})
      moving = false
    elseif moving == false
    and attacking == true then
      gridclear(bg, {sprite = 0})
      move(lastspace.x, lastspace.y)
      movespaces(friendly.x, friendly.y)
      moving = true
      attacking = false
    end
  end
end

function _draw()
  cls()
  mapanimate()
  map(mapcorner.x, mapcorner.y, 0, 0, 16, 16)
  griddraw(bg)
  griddraw(fg)
  selectdraw()
  animate()
  moveanimate()
end

function copy(src)
  local dest = {}
  dest.name = src.name
  dest.sprite = src.sprite
  dest.speed = src.speed
  dest.attackmin = src.attackmin
  dest.attackmax = src.attackmax
  dest.might = src.might
  dest.maxhp = src.maxhp
  dest.hp = src.hp
  dest.xp = src.xp
  dest.level = src.level
  dest.alignment = src.alignment
  return dest
end

function copybreadcrumb(src)
  local dest = {}
  for i=1, #src do
    dest[i] = {
      x = src[i].x,
      y = src[i].y
    }
  end
  return dest
end

function statprint(text, x, y, color, width)
  rectfill(x, y, x + width, y + 8, 0)
  print(text, x + 2, y + 2, color)
end

function gridinit()
  local grid = {}
  for i=0, gridsize.x do
    grid[i] = {}
  end
  return grid
end

function gridclear(grid, value)
  for i=0, gridsize.x do
    for j=0, gridsize.y do
      grid[i][j] = value
    end
  end
end

function griddraw(grid)
  for i=mapcorner.x, mapcorner.x + 16 do
    for j=mapcorner.y, mapcorner.y + 16 do
      local pos = spritepos(grid[i][j].sprite)
      sspr(pos.x * 8, pos.y * 8, 8, 8, (i - mapcorner.x) * 8, (j - mapcorner.y) * 8)
    end
  end
end

function mapanimate()
  for i=mapcorner.x, mapcorner.x + 16 do
    for j=mapcorner.y, mapcorner.y + 16 do
      if mapanimatecounter % alternate == 0 then
        for mapanimation in all(mapanimations) do
          for k=1, #mapanimation do
            if mget(i, j) == mapanimation[k]
            and mapanimatecounter == k * alternate then
              mset(i, j, mapanimation[k % #mapanimation + 1])
              break
            end
          end
        end
      end
    end
  end

  if mapanimatecounter == alternate * 2 then
    mapanimatecounter = 0
  end

  mapanimatecounter += 1
end

function mapsliceanimate(x, y)
  for idx=0, 15 do
    for mapanimation in all(mapanimations) do
      for k=1, #mapanimation do
        local sprite

        if x != nil then
          sprite = mget(mapcorner.x + x, mapcorner.y + idx)
        elseif y != nil then
          sprite = mget(mapcorner.x + idx, mapcorner.y + y)
        end

        if sprite == mapanimation[#mapanimation - (k - 1)]
        and mapanimatecounter >= (k - 1) * alternate
        and mapanimatecounter <= k * alternate then
          if x != nil then
            mset(mapcorner.x + x, mapcorner.y + idx, mapanimation[k])
          elseif y != nil then
            mset(mapcorner.x + idx, mapcorner.y + y, mapanimation[k])
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
    x = select.x - mapcorner.x,
    y = select.y - mapcorner.y
  }

  spr(255, screenpos.x * 8, screenpos.y * 8)

  if fg[select.x][select.y].sprite != 0 then
    local screen = {
      pos = {
        x = 100,
        y = 1
      },
      width = 26
    }

    showstats(fg[select.x][select.y], screen)
  end
end

function animate()
  if animation != nil then
    animation.frame += 1

    if animation.frame > 30 and animation.frame < 116 then
      local friendlystats = {
        pos = {
          x = 16,
          y = 69
        },
        width = 31
      }
      showstats(friendly, friendlystats)

      local enemystats = {
        pos = {
          x = 82,
          y = 69
        },
        width = 31
      }
      showstats(enemy, enemystats)
    end

    if animation.frame <= 30 then
      zoom(0, 1)
    elseif animation.frame > 60 and animation.frame <= 63 then
      nudge("friendly", 1)
    elseif animation.frame > 63 and animation.frame <= 66 then
      damage("enemy")
      nudge("friendly", -1)
    elseif animation.frame > 81 and animation.frame <= 83 then
      if animation.counterattack == true then
        nudge("enemy", -1)
      end
    elseif animation.frame > 83 and animation.frame <= 86 then
      if animation.counterattack == true then
        damage("friendly")
        nudge("enemy", 1)
      end
    elseif animation.frame > 116 and animation.frame <= 146 then
      zoom(116, -1)
    elseif animation.frame > 146 then
      if friendly.hp == 0 then
        die(friendly)
      else
        friendly.sprite = animation.friendly.sprite
      end

      if enemy.hp == 0 then
        die(enemy)
      else
        enemy.sprite = animation.enemy.sprite
      end

      animation = nil
      return
    end

    local pos = spritepos(animation.friendly.sprite)
    sspr(pos.x * 8, pos.y * 8, 8, 8, animation.friendly.move.x, animation.friendly.move.y, animation.friendly.size.x, animation.friendly.size.y)

    pos = spritepos(animation.enemy.sprite)
    sspr(pos.x * 8, pos.y * 8, 8, 8, animation.enemy.move.x, animation.enemy.move.y, animation.enemy.size.x, animation.enemy.size.y)
  end
end

function zoom(baseframe, direction)
  local progress

  if direction > 0 then
    progress = animation.frame - baseframe
  else
    progress = 30 - (animation.frame - baseframe)
  end

  local scale = 8 + 8 * (progress / 15)

  animation.friendly.size = {
    x = scale,
    y = scale
  }

  animation.friendly.move = {
    x = ((friendly.x - mapcorner.x) * 8 + (((29 - (friendly.x - mapcorner.x) * 8) / 30) * progress)) - animation.friendly.size.x / 2 + 4,
    y = ((friendly.y - mapcorner.y) * 8 + (((40 - (friendly.y - mapcorner.y) * 8) / 30) * progress)) - animation.friendly.size.y / 2 + 4
  }

  animation.enemy.size = {
    x = scale,
    y = scale
  }

  animation.enemy.move = {
    x = ((enemy.x - mapcorner.x) * 8 + (((95 - (enemy.x - mapcorner.x) * 8) / 30) * progress)) - animation.enemy.size.x / 2 + 4,
    y = ((enemy.y - mapcorner.y) * 8 + (((40 - (enemy.y - mapcorner.y) * 8) / 30) * progress)) - animation.enemy.size.y / 2 + 4
  }
end

function nudge(alignment, direction)
  animation[alignment].move = {
    x = animation[alignment].move.x + direction,
    y = animation[alignment].move.y
  }
end

function damage(alignment)
  if alignment == "friendly"
  and enemy.hp > 0 then
    friendly.hp -= enemy.might / 3
    if friendly.hp < 1 then
      friendly.hp = 0
    end
  elseif alignment == "enemy"
  and friendly.hp > 0 then
    enemy.hp -= friendly.might / 3
    if enemy.hp < 1 then
      enemy.hp = 0
    end
  end
end

function die(unit)
  typemask[unit.x][unit.y] = "neutral"
  unit = {sprite = 0}
end

function showstats(unit, screen)
  statprint(unit.name, screen.pos.x, screen.pos.y, colors[unit.alignment], screen.width)
  statprint("lvl: 1", screen.pos.x, screen.pos.y + 8, colors[unit.alignment], screen.width)
  statprint("hp: " .. flr(unit.hp + 0.5), screen.pos.x, screen.pos.y + 16, colors[unit.alignment], screen.width)
end

function unit(base, alignment)
  local new = copy(base)
  new.alignment = alignment
  new.sprite = sprites[base.name][alignment]
  return new
end

function movespaces(x, y)
  friendly = alias(x, y)
  moving = true
  explorerange(friendly.x, friendly.y, friendly.speed, 254, {"neutral", "good"}, {"evil"})
end

function moveanimate()
  if moveanimation != nil then
    local currentcell = {
      x = moveanimation.pixelpos.x / 8,
      y = moveanimation.pixelpos.y / 8
    }

    if currentcell.x == moveanimation.begin.x
    and currentcell.y == moveanimation.begin.y then
      gridclear(bg, {sprite = 0})
      unplace(friendly.x, friendly.y)
    end

    if moveanimateidx - 1 < #breadcrumbs[select.x][select.y] then
      if currentcell.x == breadcrumbs[select.x][select.y][moveanimateidx].x
      and currentcell.y == breadcrumbs[select.x][select.y][moveanimateidx].y then
        previousspace = {
          x = breadcrumbs[select.x][select.y][moveanimateidx].x,
          y = breadcrumbs[select.x][select.y][moveanimateidx].y
        }
        moveanimateidx += 1
      else
        moveanimation.pixelpos.x += breadcrumbs[select.x][select.y][moveanimateidx].x - previousspace.x
        moveanimation.pixelpos.y += breadcrumbs[select.x][select.y][moveanimateidx].y - previousspace.y
      end

      local movescreenpos = {
        x = moveanimation.pixelpos.x - (mapcorner.x * 8),
        y = moveanimation.pixelpos.y - (mapcorner.y * 8)
      }

      spr(moveanimation.sprite, movescreenpos.x, movescreenpos.y)
    end

    if currentcell.x == moveanimation.finish.x
    and currentcell.y == moveanimation.finish.y then
      place(moveanimation.finish.x, moveanimation.finish.y, friendly)
      friendly = alias(moveanimation.finish.x, moveanimation.finish.y)
      moving = false
      moveanimation = nil
      attackspaces()
    end
  end
end

function move(x, y)
  lastspace = {
    x = friendly.x,
    y = friendly.y
  }

  moveanimation = {
    begin = {
      x = friendly.x,
      y = friendly.y
    },
    finish = {
      x = x,
      y = y
    },
    pixelpos = {
      x = friendly.x * 8,
      y = friendly.y * 8
    },
    sprite = friendly.sprite
  }

  moveanimateidx = 1
end

function alias(x, y)
  local handle = fg[x][y]
  handle.x = x
  handle.y = y
  return handle
end

function attackspaces()
  local goodspaces = explorerange(friendly.x, friendly.y, friendly.attackmax, 253, {"evil"}, {})
  local badspaces = explorerange(friendly.x, friendly.y, friendly.attackmin, 0, {"evil"}, {})
  if goodspaces - badspaces > 0 then
    attacking = true
  end
end

function attack()
  enemy = alias(select.x, select.y)

  gridclear(bg, {sprite = 0})
  attacking = false

  animation = {
    frame = 0,
    friendly = {
      sprite = friendly.sprite
    },
    enemy = {
      sprite = enemy.sprite
    }
  }

  explorerange(enemy.x, enemy.y, enemy.attackmax, 253, {"good"}, {})
  explorerange(enemy.x, enemy.y, enemy.attackmin, 0, {"good"}, {})

  if bg[friendly.x][friendly.y].sprite == 253 then
    animation.counterattack = true
  else
    animation.counterattack = false
  end

  gridclear(bg, {sprite = 0})
  friendly.sprite = 0
  enemy.sprite = 0
end

function place(x, y, unit)
  fg[x][y] = copy(unit)
  typemask[x][y] = unit.alignment
end

function unplace(x, y)
  fg[x][y] = {sprite = 0}
  typemask[x][y] = "neutral"
end

function explorerange(x, y, steps, sprite, alignments, obstacles)
  valid = {}
  spaces = 0
  crawlspace(x, y, steps, sprite, alignments, obstacles, {})
  return spaces
end

function crawlspace(x, y, steps, sprite, alignments, obstacles, breadcrumb)
  if valid[x] == nil then
    valid[x] = {}
  end

  if valid[x][y] == nil
  or valid[x][y] < steps then
    valid[x][y] = steps
  else
    return
  end

  for alignment in all(alignments) do
    if typemask[x][y] == alignment then
      bg[x][y] = {sprite = sprite}
      spaces += 1
    end
  end

  add(breadcrumb, {
    x = x,
    y = y
  })

  breadcrumbs[x][y] = copybreadcrumb(breadcrumb)

  if validspace(x - 1, y, steps, obstacles) then
    crawlspace(x - 1, y, steps - 1, sprite, alignments, obstacles, copybreadcrumb(breadcrumb))
  end

  if validspace(x + 1, y, steps, obstacles) then
    crawlspace(x + 1, y, steps - 1, sprite, alignments, obstacles, copybreadcrumb(breadcrumb))
  end

  if validspace(x, y - 1, steps, obstacles) then
    crawlspace(x, y - 1, steps - 1, sprite, alignments, obstacles, copybreadcrumb(breadcrumb))
  end

  if validspace(x, y + 1, steps, obstacles) then
    crawlspace(x, y + 1, steps - 1, sprite, alignments, obstacles, copybreadcrumb(breadcrumb))
  end
end

function validspace(x, y, steps, obstacles)
  if x < 0 or x >= 128 or y < 0 or y >= 32 then
    return false
  end

  for obstacle in all(obstacles) do
    if typemask[x][y] == obstacle then
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
