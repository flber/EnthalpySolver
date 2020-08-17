debug = io.open("debug.txt", "w+")
math.randomseed(os.time())

goal = {}
goal.p = {}
goal.p.coefs = {1, 1}
goal.p.chems = {"FeO(s)", "CO(g)"}
goal.r = {}
goal.r.coefs = {1, 1}
goal.r.chems = {"Fe(s)", "CO_2(g)"}

coefs = {}
known_coefs = {}

givens = {}

local a = {}
a.h = -23
a.p = {}
a.p.coefs = {1, 3}
a.p.chems = {"Fe_2O_3(s)", "CO(g)"}
a.r = {}
a.r.coefs = {2, 3}
a.r.chems = {"Fe(s)", "CO_2(g)"}
givens[#givens+1] = a

local b = {}
b.h = -39
b.p = {}
b.p.coefs = {3, 1}
b.p.chems = {"Fe_2O_3(s)", "CO(g)"}
b.r = {}
b.r.coefs = {2, 1}
b.r.chems = {"Fe_3O_4(s)", "CO_2(g)"}
givens[#givens+1] = b

local c = {}
c.h = 18
c.p = {}
c.p.coefs = {1, 1}
c.p.chems = {"Fe_3O_4(s)", "CO(g)"}
c.r = {}
c.r.coefs = {3, 1}
c.r.chems = {"FeO(s)", "CO_2(g)"}
givens[#givens+1] = c


function love.load()
  coefs = generate_new_coefs()

  print("Goal:")
  print(print_reaction(1, goal))
  print()

  print("Givens:")
  for i = 1, #givens do
    local react = givens[i]
    print(print_reaction(1, react))
  end
  print()

  solve()
end

function love.update(dt)

end

function love.draw()

end

function solve()
  local unique_chems = find_unique_chems(goal, givens)
  local goal_coefs = {}
  for i = 1, #unique_chems do
    goal_coefs[i] = 0
  end

  for i = 1, #unique_chems do
    local chem = unique_chems[i]
    for j = 1, #goal.r.chems do
      local grchem = goal.r.chems[j]
      if grchem == chem then
        goal_coefs[i] = goal_coefs[i] + goal.r.coefs[j]
      end
    end
    for j = 1, #goal.p.chems do
      local gpchem = goal.p.chems[j]
      if gpchem == chem then
        goal_coefs[i] = goal_coefs[i] + goal.p.coefs[j]
      end
    end
  end

  local temp_coefs = {}
  temp_coefs = generate_new_coefs()
  local temp_react_coefs = {}
  for i = 1, #temp_coefs do
    temp_react_coefs[i] = {}
    for j = 1, #givens[i].r.coefs + #givens[i].p.coefs do
      temp_react_coefs[i][j] = 0
    end
  end
  local finished = false
  while not finished do
    for i = 1, #temp_coefs do
      local coef = temp_coefs[i]
      for j = 1, #givens[i].r.coefs + #givens[i].p.coefs do
        if j <= #givens[i].r.coefs then
          local r_coef = givens[i].r.coefs[j]
          temp_react_coefs[i][j] = coef * r_coef
        else
          local p_coef = givens[i].p.coefs[j - #givens[i].r.coefs]
          temp_react_coefs[i][j] = coef * p_coef
        end
      end
    end

    
  end
end

function generate_new_coefs()
  local temp_coefs = {}
  for i = 1, #givens do
    temp_coefs[i] = math.random(-5, 5)
  end
  while table_is_in_table(temp_coefs, known_coefs) do
    for i = 1, #givens do
      temp_coefs[i] = math.random(-5, 5)
    end
    add_to_known_coefs(temp_coefs)
  end
  add_to_known_coefs(temp_coefs)
  return temp_coefs
end

function find_unique_chems(temp_goal, temp_givens)
  local temp_chems = add_tables(temp_goal.r.chems, temp_goal.p.chems)
  for i = 1, #temp_givens do
    local react = temp_givens[i]
    temp_chems = add_tables(add_tables(react.r.chems, react.p.chems), temp_chems)
  end
  for i = #temp_chems, 1, -1 do
    local check_chem = temp_chems[i]
    for j = i-1, 1, -1 do
      if temp_chems[j] == check_chem then table.remove(temp_chems, j) end
    end
  end
  return temp_chems
end

function add_tables(a, b)
  local final = {}
  for i = 1, #a + #b do
    if i <= #a then
      final[i] = a[i]
    else
      final[i] = b[i-#a]
    end
  end
  return final
end

function print_reaction(c, react)
  local str = ""
  local p = react.p
  local r = react.r
  local h = react.h

  for i = 1, #p.coefs do
    str = str .. (c * p.coefs[i]) .. " " .. p.chems[i]
    if i ~= #p.coefs then
      str = str .. "  +  "
    else
      str = str .. "  ->  "
    end
  end

  for i = 1, #r.coefs do
    str = str .. (c * r.coefs[i]) .. " " .. r.chems[i]
    if i ~= #r.coefs then
      str = str .. "  +  "
    elseif h ~= nil then
      str = str .. "  |  dH = " .. h
    end
  end

  return str
end

function add_to_known_coefs(temp_coefs)
  if not table_is_in_table(temp_coefs, known_coefs) then
    known_coefs[#known_coefs+1] = temp_coefs
  end
end

function table_is_in_table(a, b)
  if #b < 1 then
    return false
  else
    unique = true
    for i = 1, #b do
      if table_is_table(b[i], a) then unique = false end
    end
    return unique
  end
end

function table_is_table(a, b)
  same = true
  if #a ~= #b then
    return false
  else
    for i = 1, #a do
      if a[i] ~= b[i] then same = false end
    end
  end
  return same
end
