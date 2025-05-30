  local other2 = {} do
            -- other2.defensive = tabs.other:checkbox('Disable Defensive AA')
            other2.defensive = tabs.other:multiselect('Disable Defensive Features', {"Def. Flick", "Def. AA", "Force Def."})
            other2.flick = tabs.other:checkbox('Defensive Flick', 0X00)

            local aa = {
                disablers = tabs.other:multiselect("Disablers", {"Body Yaw", "Yaw Jitter"}),

                pitch = tabs.other:combobox("Pitch\nfl d_pitch", {"None", "Random", "Custom", "Progressive"}),
                pitch_val = tabs.other:slider("\nfl d_pitch_val", -89, 89, 0, true, '°', 1, {[-89] = "Up", [-45] = "Semi-Up", [0] = "Zero", [45] = "Semi-Down", [89] = "Down"}),    
                pitch_speed = tabs.other:slider("\nfl d_pitch_speed", 0, 50, 10, true, '', 0.1, t3),
                pitch_min = tabs.other:slider("\nfl d_pitch_min", -89, 89, -89, true, '°', 1, t2),
                pitch_max = tabs.other:slider("\nfl d_pitch_max", -89, 89, 89, true, '°', 1, t1),

                yaw = tabs.other:combobox("Yaw\nfl  d_yaw", {"None", "Sideways", 'Sideways 45', "Spin", "Random", "Custom", "Yaw Opposite", "Progressive", "Yaw Side"}),
                yaw_val = tabs.other:slider("\nfl d_yaw_val", -180, 180, 0, true, '°', 1, {[-180] = 'Forward', [0] = "Backward", [180] = "Forward"}),
                yaw_invert = tabs.other:hotkey("Inverter"),
                yaw_speed = tabs.other:slider("\nfl d_yaw_speed", 0, 50, 10, true, '', 0.1, t3),
                yaw_min = tabs.other:slider("\nfl d_yaw_min", -180, 180, -180, true, '°', 1, t2),
                yaw_max = tabs.other:slider("\nfl d_yaw_max", -180, 180, 180, true, '°', 1, t1),

            }
            pui.traverse(aa, function(element, path)
                element:depend({other2.flick, true})
            end)

            aa.pitch_val:depend({aa.pitch, 'Custom'})
            aa.yaw_val:depend({aa.yaw, "Custom"})
            aa.pitch_speed:depend({aa.pitch, 'Progressive'})
            aa.pitch_min:depend({aa.pitch, 'Progressive'})
            aa.pitch_max:depend({aa.pitch, 'Progressive'})
            aa.yaw_invert:depend({aa.yaw, "Custom"})
            aa.yaw_speed:depend({aa.yaw, "Progressive", "Spin"})
            aa.yaw_min:depend({aa.yaw, 'Progressive'})
            aa.yaw_max:depend({aa.yaw, 'Progressive'})
            other2.flick_aa = aa
            Antiaims.other2 = other2
        end

        local xd do
            Antiaims.label = tabs.fl:label('\nlabel1')

            Antiaims.label2 = tabs.fl:label('\nlabel2')
            Antiaims.default = tabs.fl:checkbox("GS", nil, false)
            Antiaims.megabutton = tabs.fl:button("Setup \vOther\r settings")

            tab:depend({Antiaims.default, false})
            tab_label:depend({Antiaims.default, false})
            Antiaims.default:depend({tab, 'fwefwefw'})

            Antiaims.default:set_callback(function(self)
                for a,t in pairs(refs) do
                    if a ~= 'aa' then
                        for name,el in pairs(t) do
                            el:set_visible(self.value)
                        end
                    end
                end
                refs.aa.fs:set_visible(self.value)
            end, true)

            Antiaims.megabutton:set_callback(function()
                Antiaims.default:set(not Antiaims.default:get())
            end)
            xd = {
                ['megabutton'] = true,
                ['label'] = true,
                ['other'] = 1,
                ['hotkeys'] = 1,
            }
        end

        local defensive_max = 13
        local max_angle = 180

        local builder = {} do
            local xd2 = {table.unpack(condition_list)}
            table.remove(xd2, 1)
            table.remove(xd2, 10)
            for i, name in pairs(condition_list) do
                builder[name] = {}

                pui.macros.x = '\n'..name


                builder[name].enabled = (name ~= condition_list[1] and name ~= condition_list[10]) and tabs.aa:checkbox("Enabled - \v"..name) or nil
                builder[name].conditions = name == condition_list[11] and tabs.aa:multiselect("Conditions", (xd2)) or nil
                builder[name].weapons = name == condition_list[11] and tabs.aa:multiselect("\nWeapons", {
                    "Knife", 
                    "Zeus", 
                    "Height Advantage"
                }) or nil
                builder[name].label_en = tabs.aa:label("\nen label")
                builder[name].yaw = {
                    base = tabs.aa:combobox("Yaw Base", (name == condition_list[10] and {"Local view", "At targets"} or {"At targets", "Local view"})),
                    global = name ~= condition_list[10] and tabs.aa:slider("Global Yaw\f<x>", -max_angle, max_angle, 0, true, '°') or nil,
                    left = name ~= condition_list[10] and tabs.aa:slider("Left & Right Yaw\f<x>", -max_angle, max_angle, 0, true, '°') or nil,
                    right = name ~= condition_list[10] and tabs.aa:slider("\nright yaw\f<x>", -max_angle, max_angle, 0, true, '°') or nil,
                }
                builder[name].label_yaw = tabs.aa:label("\nyaw label")

                builder[name].jitter = {
                    type = tabs.aa:combobox("Yaw Jitter\f<x>", {
                        "Off", 
                        "Offset", 
                        "Center", 
                        "Random", 
                        "Skitter", 
                        "3-Way", 
                        "5-Way", 
                    }),
                    mode = tabs.aa:combobox("\njitter mode\f<x>", {
                        "Static", "Switch", "Random", "Spin"
                    }),
                    value = tabs.aa:slider("\f<x>jitter value", -max_angle, max_angle, 0, true, '°'),
                    value2 = tabs.aa:slider("\f<x>jitter value2", -max_angle, max_angle, 0, true, '°'),
                    ways = (function()
                        local el = {}
                        for i=1, 5 do
                            el[i] = tabs.aa:slider("\f<x>way" .. i, -max_angle, max_angle, 0, true, '°')
                        end
                        return el
                    end)(),
                    rand = tabs.aa:slider("Randomization\f<x>", 0, max_angle, 0, true, '°', 1, {[0] = 'Off'})
                }

                local t = {['Off'] = true, ['3-Way'] = true, ['5-Way'] = true}
                builder[name].jitter.mode:depend({builder[name].jitter.type, function()
                    return not t[builder[name].jitter.type.value]
                end})
                builder[name].jitter.value:depend({builder[name].jitter.type, function()
                    return not t[builder[name].jitter.type.value]
                end})
                builder[name].jitter.value2:depend({builder[name].jitter.mode, "Static", true}, {builder[name].jitter.type, function()
                    return not t[builder[name].jitter.type.value]
                end})
                for i=1, 5 do
                    builder[name].jitter.ways[i]:depend({builder[name].jitter.type, function()
                        return i<4 and builder[name].jitter.type.value == '3-Way' or builder[name].jitter.type.value == '5-Way'
                    end})
                end
                builder[name].jitter.rand:depend({builder[name].jitter.type, "Off", true})
                
                builder[name].body = {
                    yaw = tabs.aa:combobox('Body Yaw\f<x>', {"Off", "Static", "Opposite", "Jitter"}),
                    side = tabs.aa:slider("\f<x> side", 0,1,0, true, nil, 1, {[0] = "Left", [1] = "Right"}),
                    delay = {
                        mode = tabs.aa:combobox("\ndelay mode\f<x>", {"Static", "Switch"}),
                        delay = tabs.aa:slider("Delay\f<x>", 1, 12, 1, true, 't', 1, {[1] = 'Default'}),
                        left = tabs.aa:slider("Left ticks\f<x>", 1, 12, 1, true, 't', 1, {[1] = 'Default'}),
                        right = tabs.aa:slider("Right ticks\f<x>", 1, 12, 1, true, 't', 1, {[1] = 'Default'}),
                        switch = tabs.aa:slider("Switch ticks\f<x>", 0, 50, 0, true, 't', 1, {[0] = 'Off'}),
                    }
                }
                builder[name].body.side:depend({builder[name].body.yaw, "Static"})
                for a,b in pairs(builder[name].body.delay) do
                    b:depend({builder[name].body.yaw, "Jitter"}, a ~= 'mode' and {builder[name].body.delay.mode, a == 'delay' and "Static" or "Switch"})
                end
                builder[name].label_def = tabs.aa:label("\ndef label")
                if name ~= "Fake Lag" then
                    builder[name].defensive = {
                        force = tabs.aa:checkbox("Force Defensive\f<x>"),
                        enabled = tabs.aa:checkbox("Enabled \v" .. name ..  " \rDefensive AA\f<x>"),
                        enabled_ = name ~= "Default" and tabs.aa:label("\aFFFFFF4E- Using settings from "..condition_list[1].." Condition\f<x>") or nil,
                        override = name ~= "Default" and tabs.aa:checkbox("Override \v" .. name ..  " \rDefensive AA\f<x>") or nil,
                        override_ = tabs.aa:label("\aFF4E4EFF- DEFENSIVE AA DISABLED\f<x>"),

                        settings = {
                            duration = tabs.aa:slider('Duration \f<x>', 2, defensive_max, 13, true, 't', 1, {[13] = "Max"}),
                            disablers = tabs.aa:multiselect("Disablers", {"Body Yaw", "Yaw Jitter"}),

                            pitch = tabs.aa:combobox("Pitch\f<x> d_pitch", {"None", "Random", "Custom", "Progressive"}),
                            pitch_val = tabs.aa:slider("\f<x>d_pitch_val", -89, 89, 0, true, '°', 1, {[-89] = "Up", [-45] = "Semi-Up", [0] = "Zero", [45] = "Semi-Down", [89] = "Down"}),      
                            pitch_speed = tabs.aa:slider("\nd d_pitch_speed", 0, 50, 10, true, '', 0.1, t3),
                            pitch_min = tabs.aa:slider("\nd d_pitch_min", -89, 89, -89, true, '°', 1, t2),
                            pitch_max = tabs.aa:slider("\nd d_pitch_max", -89, 89, 89, true, '°', 1, t1),
                            yaw = tabs.aa:combobox("Yaw\f<x> d_yaw", {"None", "Sideways", 'Sideways 45', "Spin", "Random", "Custom", "Yaw Opposite", "Progressive", "Yaw Side"}),
                            yaw_val = tabs.aa:slider("\f<x>d_yaw_val", -180, 180, 0, true, '°', 1, {[-180] = 'Forward', [0] = "Backward", [180] = "Forward"}),
                            yaw_speed = tabs.aa:slider("\nd d_yaw_speed", 0, 50, 10, true, '', 0.1, t3),
                            yaw_min = tabs.aa:slider("\nd d_yaw_min", -180, 180, -180, true, '°', 1, t2),
                            yaw_max = tabs.aa:slider("\nd d_yaw_max", -180, 180, 180, true, '°', 1, t1),
                        }
                    }
                    for n,ref in pairs(builder[name].defensive.settings) do
                        ref:depend({builder[name].defensive.enabled, true})
                        if name ~= condition_list[1] then
                            ref:depend({builder[name].defensive.override, true})
                        end
                    end
                    if name ~= condition_list[1] then 
                        builder[name].defensive.override:depend({builder[name].defensive.enabled, true})
                        builder[name].defensive.enabled_:depend({builder[name].defensive.enabled, true}, {builder[name].defensive.override, false})
                    end
                    builder[name].defensive.override_:depend({other2.defensive, true}, {builder[name].defensive.enabled, true})
                    builder[name].defensive.settings.pitch_val:depend({builder[name].defensive.settings.pitch, 'Custom'})
                    builder[name].defensive.settings.yaw_val:depend({builder[name].defensive.settings.yaw, "Custom"})
                    builder[name].defensive.settings.pitch_speed:depend({builder[name].defensive.settings.pitch, 'Progressive'})
                    builder[name].defensive.settings.pitch_max:depend({builder[name].defensive.settings.pitch, 'Progressive'})
                    builder[name].defensive.settings.pitch_min:depend({builder[name].defensive.settings.pitch, 'Progressive'})
                    builder[name].defensive.settings.yaw_speed:depend({builder[name].defensive.settings.yaw, "Progressive", "Spin"})
                    builder[name].defensive.settings.yaw_min:depend({builder[name].defensive.settings.yaw, "Progressive"})
                    builder[name].defensive.settings.yaw_max:depend({builder[name].defensive.settings.yaw, "Progressive"})
                end
                builder[name].label_def2 = tabs.aa:label("\ndef label2")

                builder[name].export = tabs.aa:button("Export \v"..name)
                builder[name].import = tabs.aa:button("Import \v"..name)
                builder[name].export:set_callback(function(self)
                    local config = pui.setup(builder[name])

                    clipboard.set(base64.encode( json.stringify(config:save()) ))
                    client.exec('playvol buttons\\button18 0.5')
                    utils.printc(pui.format("\f<r>[\f<ez>rinnegan\f<r>] ~ Exported condition \f<ez>" .. name))
                end)
                builder[name].import:set_callback(function(self)
                    local config = pui.setup(builder[name])

                    config:load(json.parse(base64.decode(clipboard.get())))
                    client.exec('playvol buttons\\button17 0.5')
                    utils.printc(pui.format("\f<r>[\f<ez>rinnegan\f<r>] ~ Imported config for \f<ez>" .. name ..'\f<r> condition'))
                end)
            end


    do
        local weapon_raw = ffi.cast('void****', ffi.cast('char*', client.find_signature('client_panorama.dll', '\x8B\x35\xCC\xCC\xCC\xCC\xFF\x10\x0F\xB7\xC0')) + 2)[0]
        local ccsweaponinfo_t = [[struct{
            char __pad_0x0000[0x1cd];
            bool hide_vm_scope;
        }]]
        local get_weapon_info = vtable_thunk(2, ccsweaponinfo_t .. '*(__thiscall*)(void*, unsigned int)')
        client.set_event_callback('run_command', function()
            if not lp.entity then return end
            local weapon = entity.get_player_weapon(lp.entity)
            if not weapon then return end
            get_weapon_info(weapon_raw, entity.get_prop(weapon, 'm_iItemDefinitionIndex')).hide_vm_scope = not (self.scope.value and self.on.value)
        end)

        defer(function()
            setup()
            if not lp.entity then return end
            local weapon = entity.get_player_weapon(lp.entity)
            if not weapon then return end
            get_weapon_info(weapon_raw, entity.get_prop(weapon, 'm_iItemDefinitionIndex')).hide_vm_scope = true
        end)
    end
    
end

local ragelogs do
    local data, hitlog = {}, {}
    local hitgroups = {'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear', 'nil'}

    menu.Features.logs.on:set_event('aim_fire', function(e)  
        data.hitgroup = e.hitgroup
        data.damage = e.damage
        -- data.bt = e.backtrack
        data.bt = globals.tickcount() - e.tick
        data.lc = e.teleported
    end)

    local self = menu.Features.logs
    self.on:set_event('aim_miss', function(e)  
        local col = color(unpack(menu.Features.color[e.reason].color.value)) or color(255,255,255,255)
        if self.display:get("On Screen") then
            table.insert(hitlog, {"\f<col2> Miss \f<col>"..entity.get_player_name(e.target).."\f<col2>'s \f<col>"..hitgroups[e.hitgroup].."\f<col2> due to \f<col>"..e.reason, 
            globals.curtime() +  menu.Features.logs.time.value*.1, 0.1, nil, col})
        end
        if self.display:get("In Console") then
            col = (utils.to_hex(col)):sub(1,6)
            pui.macros.col = '\a'..col
            utils.printc(pui.format(
                "\f<r>[\f<col>rinnegan\f<r>] ~ Miss "..
                "\f<col>"..entity.get_player_name(e.target).."\f<r>'s "..
                "\f<col>"..(hitgroups[e.hitgroup] or "?")..
                "\f<r> due to \f<col>"..e.reason.."\f<r>"..
                (e.reason == 'spread' and "(\f<col>"..string.format('%.0f', e.hit_chance).."\f<r>%)" or '')..
                (data.bt ~= 0 and ' (\f<col>'..data.bt..'\f<r> bt)' or '')..
                (data.lc and ' (\f<col>LC\f<r>)' or '')
            ))
        end
    end)
    self.on:set_event('aim_hit', function(e)
        local col = utils.to_hex(color(unpack(menu.Features.color['hit'].color.value)) or color(255,255,255,255))
        if self.display:get("On Screen") then
            table.insert(hitlog, {
                "\f<col2> Hit \f<col>"..entity.get_player_name(e.target).."\f<col2>'s \f<col>"..(hitgroups[e.hitgroup] or '?').."\f<col2> for \f<col>"..e.damage.." \f<col2>dmg", 
                globals.curtime() +  menu.Features.logs.time.value*.1, 0.1, nil, color(unpack(menu.Features.color['hit'].color.value)) })
        end
        if self.display:get("In Console") then
            col = col:sub(1,6)
            pui.macros.col = '\a'..col
            local health = entity.get_prop(e.target, 'm_iHealth')
            utils.printc(pui.format(
                "\f<r>[\f<col>rinnegan\f<r>] ~ Hit "..
                "\f<col>"..entity.get_player_name(e.target).."\f<r>'s "..
                "\f<col>"..(hitgroups[e.hitgroup] or "?")..
                (e.hitgroup ~= data.hitgroup and "\f<r>(\f<col>"..hitgroups[data.hitgroup].."\f<r>)" or '')..
                "\f<r> for \f<col>"..e.damage.."\f<r>"..
                (e.damage ~= data.damage and "\f<r>(\f<col>"..data.damage.."\f<r>) dmg" or ' dmg')..
                (e.reason == 'spread' and "(\f<col>"..string.format('%.0f', e.hit_chance).."\f<r>%)" or '')..
                " \f<col>~"..
                (health <= 0 and ' \f<r>(\f<col>dead\f<r>)' or ' \f<r>(\f<col>'..health..'\f<r> hp)')..
                (data.bt ~= 0 and ' (\f<col>'..data.bt..'\f<r> bt)' or '')..
                (data.lc and ' (\f<col>LC\f<r>)' or '')
            ))
        end
    end)

    local render = function()
        if not self.display:get('On Screen') then return end
        if #hitlog > 0 then
            if hitlog[1][3] <= 0.07 or #hitlog > 7 then
                table.remove(hitlog, 1)
            end
            for i = 1, #hitlog do
                local curtime = globals.curtime()
                hitlog[i][3] = utils.lerp(hitlog[i][3], curtime >= hitlog[i][2] and 0 or 1, 0.03)
                hitlog[i][4] = not hitlog[i][4] and i * 50 or utils.lerp(hitlog[i][4], curtime >= hitlog[i][2] and i * -10 or (hitlog[i - 1] and curtime >= hitlog[i - 1][2] and i-1 or i) * 30, 0.035)

                local text_color = hitlog[i][5]:clone()
                pui.macros.col = '\a'..utils.to_hex(text_color:alpha_modulate(text_color.a * hitlog[i][3]))

                local text_color2 = color(255,255,255,100)
                pui.macros.col2 = '\a'..utils.to_hex(text_color2:alpha_modulate(text_color2.a * hitlog[i][3]))

                local text = pui.format(hitlog[i][1])
                local measure = vector(renderer.measure_text('d', text))
                local y = screen.size.y * 0.73 - (1 - hitlog[i][4])

                local c = colors['logs']['Background']
                utils.rectangle(
                        screen.center.x - math.floor(measure.x * 0.55), y - 3,
                        math.floor(measure.x * 0.55) * 2, measure.y + 7,
                        c.r,c.g,c.b,c.a * hitlog[i][3],
                        5
                )
                renderer.text(screen.center.x - measure.x * 0.5, y, 0,0,0,0, 'd', 0, text)
            end
        end
    end
    self.on:set_event('paint', render)
    client.set_event_callback('round_poststart', function()
        hitlog = {}
    end)
    self.on:set_callback(function(self)
        refs2.log_dealt:override(not self.value and nil or false)
        refs2.log_dealt:set_enabled(not self.value)
        refs2.log_spread:override(not self.value and nil or false)
        refs2.log_spread:set_enabled(not self.value)
    end, true)
end

local filter do
    menu.Features.console.on:set_callback(function(self)
        client.delay_call(0, function()
            cvar.con_filter_enable:set_int(self.value and 1 or 0)
            cvar.con_filter_text:set_string(self.value and 'Rinnegan ['..version[1] ..']' or '')
        end)
    end, true)
    defer(function()
        cvar.con_filter_enable:set_int(0)
        cvar.con_filter_text:set_string('')
    end)
end

local manuals do
    manuals = {
        {
            [menu.Antiaims.hotkeys.forward] = {
                state = false,
                yaw = "Forward",
            },
            [menu.Antiaims.hotkeys.left]  = {
                state = false,
                yaw = "Left",
            },
            [menu.Antiaims.hotkeys.right] = {
                state = false,
                yaw = "Right",
            },
        },
        {
            ["Forward"] = 180,
            ["Left"] = -90,
            ["Right"] = 90,
        },
        {
            ["Forward"] = {1,-70,"^"},
            ["Left"] = {-70,1,"<"},
            ["Right"] = {70,1,">"},
        },
    }
    local handle_manuals = function()
        for key, value in pairs(manuals[1]) do
            local state, m_mode = key:get()
            if state ~= value.state then
                value.state = state
                if m_mode == 1 then
                    lp.manual = state and value.yaw or nil
                end
    
                if m_mode == 2 then
                    if lp.manual == value.yaw then
                        lp.manual = nil
                    else
                        lp.manual = value.yaw
                    end
                end
            end
    
        end
    end
    client.set_event_callback('paint', handle_manuals)

    local alpha,x,y = 0,0,0
    local last = nil
    local this = nil
    local render = function()
        if not lp.entity or not entity.is_alive(lp.entity) then return end
        this = lp.manual
        last = this and this or last
        if not last then return end
        y = utils.lerp(y,this and manuals[3][last][2] or 0, 0.03)
        x = utils.lerp(x,this and manuals[3][last][1] or 0, 0.03)
        alpha = utils.lerp(alpha, this and math.sqrt( x^2 +y^2 )/math.sqrt( manuals[3][last][1]^2 +manuals[3][last][2]^2 ) * (alpha < 0.75 and 0.9 or 1) or 0, 0.03)
        if alpha <= 0.1 then return end
        local c = colors["manual"]['Color']
        renderer.text(screen.center.x+x-1, screen.center.y+y-1, c.r,c.g,c.b,c.a * alpha,'+cd',0,manuals[3][last][3]:upper())
    end
    menu.Features.manual.on:set_event('paint', render)
end

local exploit do
    exploit = { }
    exploit.def_aa = false
    local BREAK_LAG_COMPENSATION_DISTANCE_SQR = 64 * 64

    local max_tickbase = 0
    local run_command_number = 0

    local data = {
        old_origin = vector(),
        old_simtime = 0.0,

        shift = false,
        breaking_lc = false,

        defensive = {
            force = false,
            left = 0,
            max = 0,
        },

        lagcompensation = {
            distance = 0.0,
            teleport = false
        }
    }

    local function update_tickbase(me)
        data.shift = globals.tickcount() > entity.get_prop(me, 'm_nTickBase')
    end

    local function update_teleport(old_origin, new_origin)
        local delta = new_origin - old_origin
        local distance = delta:lengthsqr()

        local is_teleport = distance > BREAK_LAG_COMPENSATION_DISTANCE_SQR

        data.breaking_lc = is_teleport

        data.lagcompensation.distance = distance
        data.lagcompensation.teleport = is_teleport
    end

    local function update_lagcompensation(me)
        local old_origin = data.old_origin
        local old_simtime = data.old_simtime

        local origin = vector(entity.get_origin(me))
        local simtime = toticks(entity.get_prop(me, 'm_flSimulationTime'))

        if old_simtime ~= nil then
            local delta = simtime - old_simtime

            if delta < 0 or delta > 0 and delta <= 64 then
                update_teleport(old_origin, origin)
            end
        end

        data.old_origin = origin
        data.old_simtime = simtime
    end

    local function update_defensive_tick(me)
        local tickbase = entity.get_prop(me, 'm_nTickBase')

        if math.abs(tickbase - max_tickbase) > 64 then
            -- nullify highest tickbase if the difference is too big
            max_tickbase = 0
        end

        local defensive_ticks_left = 0

        -- defensive effect can be achieved because the lag compensation is made so that
        -- it doesn't write records if the current simulation time is less than/equals highest acknowledged simulation time
        -- https://gitlab.com/KittenPopo/csgo-2018-source/-/blame/main/game/server/player_lagcompensation.cpp#L723

        if tickbase > max_tickbase then
            max_tickbase = tickbase
        elseif max_tickbase > tickbase then
            defensive_ticks_left = math.min(14, math.max(0, max_tickbase - tickbase - 1))
        end

        if defensive_ticks_left > 0 then
            data.breaking_lc = true
            data.defensive.left = defensive_ticks_left

            if data.defensive.max == 0 then
                data.defensive.max = defensive_ticks_left
            end
        else
            data.defensive.left = 0
            data.defensive.max = 0
        end
    end

    function exploit.get()
        return data
    end

    local function on_predict_command(cmd)
        local me = entity.get_local_player()

        if me == nil then
            return
        end

        if cmd.command_number == run_command_number then
            update_defensive_tick(me)
            run_command_number = nil
        end
    end

    local function on_setup_command(cmd)
        local me = entity.get_local_player()

        if me == nil then
            return
        end

        update_tickbase(me)
    end

    local function on_run_command(e)
        run_command_number = e.command_number
    end

    local function on_net_update_start()
        local me = entity.get_local_player()

        if me == nil then
            return
        end

        update_lagcompensation(me)
    end

    client.set_event_callback('predict_command', on_predict_command)
    client.set_event_callback('setup_command', on_setup_command)
    client.set_event_callback('run_command', on_run_command)

    client.set_event_callback('net_update_start', on_net_update_start)
end

local antiaims do
    local antiaims = {
        pitch = {
            ['Random'] = function()
                return client.random_int(-89,89)
            end,
            ['Custom'] = function(e)
                return e.pitch_val:get()
            end,
            ['Progressive'] = function(e)
                return (utils.sine_yaw(globals.servertickcount() * e.pitch_speed.value * 0.1, e.pitch_min.value, e.pitch_max.value))
            end
        },
        yaw = {
            ['Sideways'] = function()
                return globals.tickcount() % 6 <= 2 and 90 or -90
            end,
            ['Sideways 45'] = function()
                return globals.tickcount() % 6 <= 2 and 45 or -45
            end,
            ['Spin'] = function(e)
                return utils.normalize_yaw(globals.servertickcount() * e.yaw_speed.value)
            end,
            ['Progressive'] = function(e)
                return (utils.sine_yaw(globals.servertickcount() * e.yaw_speed.value * 0.1, e.yaw_min.value, e.yaw_max.value))
            end,
            ['Random'] = function()
                return client.random_int(-180,180)
            end,
            ['Custom'] = function(e)
                return not e.yaw_invert and e.yaw_val:get() or e.yaw_val:get() + (e.yaw_invert:get() and 180 or 0)
            end,
            ['Yaw Opposite'] = function(yaw)
                return utils.normalize_yaw(yaw+180)
            end,
            ['Yaw Side'] = function(val)
                return val
            end
        }
    }
    local body_yaw,packets,offset,fl = 0,0,0,0
    local delay = {left=0,right=0,switch_ticks=0,work_side='left',switch=false}

    local setup = function(cmd)
        refs.fl.enabled:override( not (
            (menu.Antiaims.other.fl_disabler.value[1] == "Standing") and (lp.on_ground and not lp.moving) or
            (menu.Antiaims.other.fl_disabler.value[1] == "Crouch Move" or menu.Antiaims.other.fl_disabler.value[2] == "Crouch Move") and (lp.on_ground and lp.crouch and lp.moving)
        ) )

        -- if menu.Antiaims.other.unsafe.value then
        --     exploits:allow_unsafe_charge(true)
        -- end

        refs.aa.enabled:override(true)
        refs.aa.pitch:override('Minimal')
        refs.aa.yaw:override("180")
        refs.aa.roll:override(0)

        local aa = (lp.manual or menu.Antiaims.builder[lp.state].enabled.value) and menu.Antiaims.builder[lp.state] or menu.Antiaims.builder[condition_list[1]]

        refs.aa.yaw_base:override(aa.yaw.base.value)
        refs.aa.body:override(aa.body.yaw.value == "Jitter" and "Static" or aa.body.yaw.value)

        if globals.chokedcommands() == 0 then
            if aa.body.delay.mode.value == "Static" then
                packets = packets > aa.body.delay.delay.value * 2 - 2 and 0 or packets + 1
            else
                delay.switch_ticks = (aa.body.delay.switch.value == 0 and -1) or (delay.switch_ticks > aa.body.delay.switch.value - 2 and 0 or delay.switch_ticks + 1)
                if delay.switch_ticks == 0 then
                    delay.switch = not delay.switch
                else
                    delay.switch = (aa.body.delay.switch.value == 0 and false) or delay.switch
                end
                delay.work_side = (delay[delay.work_side] > ( aa.body.delay[(delay.switch and (delay.work_side == 'left' and 'right' or 'left') or delay.work_side)].value - 2 ) and (delay.work_side == 'left' and 'right' or 'left')) or delay.work_side
                delay[delay.work_side] = (delay[delay.work_side] > ( aa.body.delay[ (delay.switch and (delay.work_side == 'left' and 'right' or 'left') or delay.work_side) ].value - 2 )) and 0 or delay[delay.work_side] + 1
            end
        end
        local inverted = (function()
            if aa.body.yaw.value == 'Static' then 
                return aa.body.side.value == 1
            elseif aa.body.yaw.value == 'Jitter' then
                if aa.body.delay.mode.value == "Switch" then
                    return delay.work_side == 'right'
                else
                    return packets % (aa.body.delay.delay.value * 2) >= aa.body.delay.delay.value
                end
            end
        end)()

        local yaw_jitter = aa.jitter.type.value
        if yaw_jitter == "3-Way" or yaw_jitter == '5-Way' then
            offset = aa.jitter.ways[(globals.tickcount() % (yaw_jitter == '3-Way' and 3 or 5)) + 1].value
            yaw_jitter = 'Off'
            offset = client.random_int(offset-aa.jitter.rand.value, offset+aa.jitter.rand.value)
        else
            offset = 0
        end

        refs.aa.jitter:override(yaw_jitter ~= "Spin" and yaw_jitter or "Off")
        local jitter_val = 0
        if yaw_jitter ~= 'Off' then
            jitter_val = (
                aa.jitter.mode.value == "Spin" and utils.sine_yaw(globals.servertickcount(), aa.jitter.value2.value, aa.jitter.value.value) 
                or (aa.jitter.mode.value == "Random" and client.random_int(0,1) == 1 or 
                aa.jitter.mode.value == 'Switch' and globals.tickcount() % 6 <= 2) and aa.jitter.value2.value or aa.jitter.value.value
            )
            jitter_val = client.random_int(jitter_val-aa.jitter.rand.value, jitter_val+aa.jitter.rand.value)
        end
        refs.aa.jitter_val:override(utils.normalize_yaw(jitter_val))
        
        
        refs.aa.body_val:override(inverted and 1 or -1)
        local yaw = utils.normalize_yaw(
            lp.manual and manuals[2][lp.manual] + offset 
            or aa.yaw.global.value + (inverted and aa.yaw.right.value or aa.yaw.left.value) + offset
        )

        refs.aa.yaw_val:override(yaw)
        refs.aa.edge:override(menu.Antiaims.hotkeys.edge:get() and not lp.manual)
        refs.aa.fs:set_hotkey("Always On", 0)
        if menu.Antiaims.hotkeys.fs:get() and not lp.manual then
            refs.aa.fs:override(true)
            if menu.Antiaims.hotkeys.fs_disablers:get("Body Yaw") then refs.aa.body:override("Off") end
            if menu.Antiaims.hotkeys.fs_disablers:get("Yaw Jitter") then refs.aa.jitter:override("Off") end
        else
            refs.aa.fs:override(false)
        end
        if lp.state ~= condition_list[9] then
            if aa.defensive.force.value and not menu.Antiaims.other2.defensive:get("Force Def.") then
                cmd.force_defensive = true
            end
            if lp.flicking then
                cmd.force_defensive = cmd.command_number % 7 == 0
            end
            if (aa.defensive.enabled.value and not menu.Antiaims.other2.defensive:get("Def. AA") or lp.flicking) and not refs2.fd:get() then
                local this = lp.flicking and menu.Antiaims.other2.flick_aa or (aa.defensive.override and aa.defensive.override.value and aa or menu.Antiaims.builder[condition_list[1]]).defensive.settings
                local exp = exploit.get().defensive.left
                local work = exp ~= 0 and (lp.flicking or exp <= this.duration.value)
                exploit.def_aa = false
                if work then
                    exploit.def_aa = true
                    if this.disablers:get("Body Yaw") then refs.aa.body:override('Off') end
                    if this.disablers:get("Yaw Jitter") then refs.aa.jitter:override('Off') end
                    if this.pitch.value ~= "None" then
                        refs.aa.pitch:override('Custom')
                        refs.aa.pitch_val:override(antiaims.pitch[this.pitch.value](this))
                    end
                    local ezz = {
                        ['Yaw Opposite'] = yaw,
                        ['Yaw Side'] = lp.state == condition_list[10] and yaw + 180 or aa.yaw.global.value + (inverted and aa.yaw.left.value or aa.yaw.right.value)
                    }
                    if this.yaw.value ~= "None" then
                        refs.aa.yaw:override('180')
                        refs.aa.yaw_val:override(utils.normalize_yaw(antiaims.yaw[this.yaw.value](ezz[this.yaw.value] or this)))
                    end
                end
            end
        end


        refs.aa.enabled:override(true)
        refs.aa.pitch:override('Minimal')
        refs.aa.yaw:override("180")
        refs.aa.roll:override(0)

        local aa = (lp.manual or menu.Antiaims.builder[lp.state].enabled.value) and menu.Antiaims.builder[lp.state] or menu.Antiaims.builder[condition_list[1]]

        refs.aa.yaw_base:override(aa.yaw.base.value)
        refs.aa.body:override(aa.body.yaw.value == "Jitter" and "Static" or aa.body.yaw.value)

        if globals.chokedcommands() == 0 then
            if aa.body.delay.mode.value == "Static" then
                packets = packets > aa.body.delay.delay.value * 2 - 2 and 0 or packets + 1
            else
                delay.switch_ticks = (aa.body.delay.switch.value == 0 and -1) or (delay.switch_ticks > aa.body.delay.switch.value - 2 and 0 or delay.switch_ticks + 1)
                if delay.switch_ticks == 0 then
                    delay.switch = not delay.switch
                else
                    delay.switch = (aa.body.delay.switch.value == 0 and false) or delay.switch
                end
                delay.work_side = (delay[delay.work_side] > ( aa.body.delay[(delay.switch and (delay.work_side == 'left' and 'right' or 'left') or delay.work_side)].value - 2 ) and (delay.work_side == 'left' and 'right' or 'left')) or delay.work_side
                delay[delay.work_side] = (delay[delay.work_side] > ( aa.body.delay[ (delay.switch and (delay.work_side == 'left' and 'right' or 'left') or delay.work_side) ].value - 2 )) and 0 or delay[delay.work_side] + 1
            end
        end
        local inverted = (function()
            if aa.body.yaw.value == 'Static' then 
                return aa.body.side.value == 1
            elseif aa.body.yaw.value == 'Jitter' then
                if aa.body.delay.mode.value == "Switch" then
                    return delay.work_side == 'right'
                else
                    return packets % (aa.body.delay.delay.value * 2) >= aa.body.delay.delay.value
                end
            end
        end)()

        local yaw_jitter = aa.jitter.type.value
        if yaw_jitter == "3-Way" or yaw_jitter == '5-Way' then
            offset = aa.jitter.ways[(globals.tickcount() % (yaw_jitter == '3-Way' and 3 or 5)) + 1].value
            yaw_jitter = 'Off'
            offset = client.random_int(offset-aa.jitter.rand.value, offset+aa.jitter.rand.value)
        else
            offset = 0
        end

        refs.aa.jitter:override(yaw_jitter ~= "Spin" and yaw_jitter or "Off")
        local jitter_val = 0
        if yaw_jitter ~= 'Off' then
            jitter_val = (
                aa.jitter.mode.value == "Spin" and utils.sine_yaw(globals.servertickcount(), aa.jitter.value2.value, aa.jitter.value.value) 
                or (aa.jitter.mode.value == "Random" and client.random_int(0,1) == 1 or 
                aa.jitter.mode.value == 'Switch' and globals.tickcount() % 6 <= 2) and aa.jitter.value2.value or aa.jitter.value.value
            )
            jitter_val = client.random_int(jitter_val-aa.jitter.rand.value, jitter_val+aa.jitter.rand.value)
        end
        refs.aa.jitter_val:override(utils.normalize_yaw(jitter_val))
        
        
        refs.aa.body_val:override(inverted and 1 or -1)
        local yaw = utils.normalize_yaw(
            lp.manual and manuals[2][lp.manual] + offset 
            or aa.yaw.global.value + (inverted and aa.yaw.right.value or aa.yaw.left.value) + offset
        )

        refs.aa.yaw_val:override(yaw)
        refs.aa.edge:override(menu.Antiaims.hotkeys.edge:get() and not lp.manual)
        refs.aa.fs:set_hotkey("Always On", 0)
        if menu.Antiaims.hotkeys.fs:get() and not lp.manual then
            refs.aa.fs:override(true)
            if menu.Antiaims.hotkeys.fs_disablers:get("Body Yaw") then refs.aa.body:override("Off") end
            if menu.Antiaims.hotkeys.fs_disablers:get("Yaw Jitter") then refs.aa.jitter:override("Off") end
        else
            refs.aa.fs:override(false)
        end
        if lp.state ~= condition_list[9] then
            if aa.defensive.force.value and not menu.Antiaims.other2.defensive:get("Force Def.") then
                cmd.force_defensive = true
            end
            if lp.flicking then
                cmd.force_defensive = cmd.command_number % 7 == 0
            end
            if (aa.defensive.enabled.value and not menu.Antiaims.other2.defensive:get("Def. AA") or lp.flicking) and not refs2.fd:get() then
                local this = lp.flicking and menu.Antiaims.other2.flick_aa or (aa.defensive.override and aa.defensive.override.value and aa or menu.Antiaims.builder[condition_list[1]]).defensive.settings
                local exp = exploit.get().defensive.left
                local work = exp ~= 0 and (lp.flicking or exp <= this.duration.value)
                exploit.def_aa = false
                if work then
                    exploit.def_aa = true
                    if this.disablers:get("Body Yaw") then refs.aa.body:override('Off') end
                    if this.disablers:get("Yaw Jitter") then refs.aa.jitter:override('Off') end
                    if this.pitch.value ~= "None" then
                        refs.aa.pitch:override('Custom')
                        refs.aa.pitch_val:override(antiaims.pitch[this.pitch.value](this))
                    end
                    local ezz = {
                        ['Yaw Opposite'] = yaw,
                        ['Yaw Side'] = lp.state == condition_list[10] and yaw + 180 or aa.yaw.global.value + (inverted and aa.yaw.left.value or aa.yaw.right.value)
                    }
                    if this.yaw.value ~= "None" then
                        refs.aa.yaw:override('180')
                        refs.aa.yaw_val:override(utils.normalize_yaw(antiaims.yaw[this.yaw.value](ezz[this.yaw.value] or this)))
                    end
                end
            end
        end
