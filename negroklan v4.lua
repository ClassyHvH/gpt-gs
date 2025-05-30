--FFI

local vectors = require("vector");
local ffi = require 'ffi'
local crr_t = ffi.typeof('void*(__thiscall*)(void*)')
local cr_t = ffi.typeof('void*(__thiscall*)(void*)')
local gm_t = ffi.typeof('const void*(__thiscall*)(void*)')
local gsa_t = ffi.typeof('int(__fastcall*)(void*, void*, int)')
local resolved = { }
ffi.cdef[[
    struct anim_layer_t
    {
	    char pad20[24];
	    uint32_t m_nSequence;
	    float m_flPrevCycle;
	    float m_flWeight;
	    float m_flWeightDeltaRate;
	    float m_flPlaybackRate;
	    float m_flCycle;
	    uintptr_t m_pOwner;
	    char pad_0038[ 4 ];
    };
    struct c_animstate { 
        char pad[ 3 ];
        char m_bForceWeaponUpdate; //0x4
        char pad1[ 91 ];
        void* m_pBaseEntity; //0x60
        void* m_pActiveWeapon; //0x64
        void* m_pLastActiveWeapon; //0x68
        float m_flLastClientSideAnimationUpdateTime; //0x6C
        int m_iLastClientSideAnimationUpdateFramecount; //0x70
        float m_flAnimUpdateDelta; //0x74
        float m_flEyeYaw; //0x78
        float m_flPitch; //0x7C
        float m_flGoalFeetYaw; //0x80
        float m_flCurrentFeetYaw; //0x84
        float m_flCurrentTorsoYaw; //0x88
        float m_flUnknownVelocityLean; //0x8C
        float m_flLastUpdateIncrement ;
        float m_flLowerBodyYawTarget;
        float m_flLeanAmount; //0x90
        char pad2[ 4 ];
        float m_flFeetCycle; //0x98
        float m_flFeetYawRate; //0x9C
        char pad3[ 4 ];
        float m_fDuckAmount; //0xA4
        float m_fLandingDuckAdditiveSomething; //0xA8
        char pad4[ 4 ];
        float m_vOriginX; //0xB0
        float m_vOriginY; //0xB4
        float m_flFootYaw;
        float m_vOriginZ; //0xB8
        float m_vLastOriginX; //0xBC
        float m_vLastOriginY; //0xC0
        float m_vLastOriginZ; //0xC4
        float m_vVelocityX; //0xC8
        float m_vVelocityY; //0xCC
        char pad5[ 4 ];
        float m_flUnknownFloat1; //0xD4
        float m_flSpeed;
        float flWalkToRunTransition;
        float m_flAnimDuckAmount;
        char pad6[ 8 ];
        float m_flUnknownFloat2; //0xE0
        float m_flUnknownFloat3; //0xE4
        float m_flUnknown; //0xE8
        float m_flSpeed2D; //0xEC
        float m_flAimYawMax;
        float m_flAimYawMin;
        float m_flUpVelocity; //0xF0
        float m_flSpeedNormalized; //0xF4
        float m_flFeetSpeedForwardsOrSideWays; //0xF8
        float m_flFeetSpeedUnknownForwardOrSideways; //0xFC
        float m_flTimeSinceStartedMoving; //0x100
        float m_flTimeSinceStoppedMoving; //0x104
        bool m_bOnGround; //0x108
        bool m_bInHitGroundAnimation; //0x109
        float m_flTimeSinceInAir; //0x10A
        float m_flLastOriginZ; //0x10E
        float m_flHeadHeightOrOffsetFromHittingGroundAnimation; //0x112
        float m_flStopToFullRunningFraction; //0x116
        char pad7[ 4 ]; //0x11A
        float m_flMagicFraction; //0x11E
        char pad8[ 60 ]; //0x122
        float m_flWorldForce; //0x15E
        char pad9[ 462 ]; //0x162
        float m_flMaxYaw; //0x334
    };
]]
local classptr = ffi.typeof('void***')
local rawientitylist = client.create_interface('client_panorama.dll', 'VClientEntityList003') or error('VClientEntityList003 wasnt found', 2)

local ientitylist = ffi.cast(classptr, rawientitylist) or error('rawientitylist is nil', 2)
local get_client_networkable = ffi.cast('void*(__thiscall*)(void*, int)', ientitylist[0][0]) or error('get_client_networkable_t is nil', 2)
local get_client_entity = ffi.cast('void*(__thiscall*)(void*, int)', ientitylist[0][3]) or error('get_client_entity is nil', 2)

local rawivmodelinfo = client.create_interface('engine.dll', 'VModelInfoClient004')
local ivmodelinfo = ffi.cast(classptr, rawivmodelinfo) or error('rawivmodelinfo is nil', 2)
local get_studio_model = ffi.cast('void*(__thiscall*)(void*, const void*)', ivmodelinfo[0][32])

local seq_activity_sig = client.find_signature('client_panorama.dll','\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x8B\xF1\x83')

local function get_model(b)if b then b=ffi.cast(classptr,b)local c=ffi.cast(crr_t,b[0][0])local d=c(b)or error('error getting client unknown',2)if d then d=ffi.cast(classptr,d)local e=ffi.cast(cr_t,d[0][5])(d)or error('error getting client renderable',2)if e then e=ffi.cast(classptr,e)return ffi.cast(gm_t,e[0][8])(e)or error('error getting model_t',2)end end end end
local function get_sequence_activity(b,c,d)b=ffi.cast(classptr,b)local e=get_studio_model(ivmodelinfo,get_model(c))if e==nil then return-1 end;local f=ffi.cast(gsa_t, seq_activity_sig)return f(b,e,d)end
local function get_anim_layer(b,c)c=c or 1;b=ffi.cast(classptr,b)return ffi.cast('struct anim_layer_t**',ffi.cast('char*',b)+0x2990)[0][c]end
local function get_anim_state(b,c)c=c or 1;b=ffi.cast(classptr,b)return ffi.cast('struct c_animstate**',ffi.cast('char*',b)+0x9960)[0]end

--MATH

local CSGO_ANIM_LOWER_CATCHUP_IDLE = 100
local CSGO_ANIM_AIM_NARROW_RUN = 0.5
local CSGO_ANIM_AIM_NARROW_WALK = 0.8
local CSGO_ANIM_WALK_TOP_SPEED = 1
local CSGO_ANIM_AIM_NARROW_CROUCHMOVING = 0.5
local CSGO_ANIM_CROUCH_TOP_SPEED = 0.7

local Lerp = function(a, b, t) return a + (b - a) * t end
function Clamp(value, min, max) return math.min(math.max(value, min), max) end

local function AngleModifier(a) return (360 / 65536) * bit.band(math.floor(a * (65536 / 360)), 65535) end
local function Approach(target, value, speed)
	target = AngleModifier(target)
	value = AngleModifier(value)
	local delta = target - value
	if speed < 0 then speed = -speed end
	if delta < -180 then delta = delta + 360
	elseif delta > 180 then delta = delta - 360 end
	if delta > speed then value = value + speed
	elseif delta < -speed then value = value - speed
    else value = target
	end
	return value
end

local function NormalizeAngle(angle)
    if angle == nil then return 0 end
	while angle > 180 do angle = angle - 360 end
	while angle < -180 do angle = angle + 360 end
	return angle
end

local function AngleDifference(dest_angle, src_angle)
	local delta = math.fmod(dest_angle - src_angle, 360)
	if dest_angle > src_angle then
		if delta >= 180 then delta = delta - 360 end
	else
		if delta <= -180 then delta = delta + 360 end
	end
	return delta
end
local function CalculateHighSpeedCorrection(speed)
    local highSpeedThreshold = 250
    local max_correction = 250

    local correction = 0
    if speed > highSpeedThreshold then
        local correctionFactor = (speed - highSpeedThreshold) / highSpeedThreshold
        correction = max_correction * correctionFactor
    end

    return correction
end

local function ApplyHighSpeedCorrection(a,b,c)
    local flAngleDelta = AngleDifference(a,b)
    local flMaxCorrection = CalculateHighSpeedCorrection(c)
    local flCorrection = Clamp(flAngleDelta, -flMaxCorrection,flMaxCorrection)
    return NormalizeAngle(b + flCorrection)
end


local function AngleVector(pitch, yaw)
    if pitch ~= nil and yaw ~= nil then 
        local p, y = math.rad(pitch), math.rad(yaw)
        local sp, cp, sy, cy = math.sin(p), math.cos(p), math.sin(y), math.cos(y)
        return cp*cy, cp*sy, -sp
    end
    return 0,0,0
end

local function CalculateAimMatrixWidthRange(state)
    local flAimMatrixWidthRange = Lerp(Clamp(state.m_flSpeed / CSGO_ANIM_WALK_TOP_SPEED, 0.0, 1.0), 1.0, Lerp(state.flWalkToRunTransition, CSGO_ANIM_AIM_NARROW_WALK, CSGO_ANIM_AIM_NARROW_RUN))

    if state.m_flAnimDuckAmount > 0.0 then
        flAimMatrixWidthRange = Lerp(state.m_flAnimDuckAmount * Clamp(state.m_flSpeed / CSGO_ANIM_CROUCH_TOP_SPEED, 0.0, 1.0), flAimMatrixWidthRange, CSGO_ANIM_AIM_NARROW_CROUCHMOVING)
    end

    return flAimMatrixWidthRange
end

local userid_to_entindex, get_local_player, is_enemy, console_cmd = client.userid_to_entindex, entity.get_local_player, entity.is_enemy, client.exec
local MenuC = {};
MenuC["Enable"] =               ui.new_checkbox("Rage", "Other", "\aC84545FF[negroklan]\a414141FF  [4.0]");
MenuC["Method"] =               ui.new_combobox("Rage", "Other", "\aC84545FF[negroklan]\aCFCFCFCF desync method", { "Default", "Eye Brute" })
MenuC["Label"] =               ui.new_label("Lua", "A", "\aCFCFCFCF resolver customization")
MenuC["Fix"] =               ui.new_checkbox("Lua", "A", "\aC84545FF[negroklan]\aCFCFCFCF animation fixer");
MenuC["Woah"] =               ui.new_checkbox("Lua", "A", "\aC84545FF[negroklan]\aCFCFCFCF clantag");
MenuC["Nigger"] =               ui.new_checkbox("Lua", "A", "\aC84545FF[negroklan]\aCFCFCFCF killsay");
MenuC["Delay"] =                    ui.new_slider("Lua", "A", "\aCFCFCFCF killsay delay", 0, 4, 1, false, "s", 0.1, "yes") 

function updateSex()
    if ui.get(MenuC["Enable"]) then
        ui.set_visible(MenuC["Woah"], true)
        ui.set_visible(MenuC["Fix"], true)
        ui.set_visible(MenuC["Nigger"], true)
        ui.set_visible(MenuC["Method"], true)
        ui.set_visible(MenuC["Delay"], true)
    else
        ui.set_visible(MenuC["Woah"], false)
        ui.set_visible(MenuC["Fix"], false)
        ui.set_visible(MenuC["Method"], false)
        ui.set_visible(MenuC["Nigger"], false)
        ui.set_visible(MenuC["Delay"], false)
    end
end
updateSex();

ui.set_callback(MenuC["Enable"], function()
    updateSex();
end)

local words = {
    [1] = "𝒾𝓂 𝓃𝑜𝓉 𝓁𝓊𝒸𝓀 𝒷𝑜𝑜𝓈𝓉, 𝒾 𝓊𝓈𝑒 𝒩𝐸𝒢𝑅𝒪𝒦𝐿𝒜𝒩 𝑅𝐸𝒮𝒪𝐿𝒱𝐸𝑅",
    [2] = "ɢᴇᴛ ɢᴏᴏᴅ ɢᴇᴛ ɴᴇɢʀᴏᴋʟᴀɴ ᴅᴏɢ - vacban.wtf/threads/103881/",
    [3] = "vacban.wtf/threads/103881/",
    [4] = "ɴᴇᴡ ɴᴇɢʀᴏᴋʟᴀɴ ᴜᴘᴅᴀᴛᴇ 4.0, ɪ ᴛᴀᴘ ᴀʟʟ ʙᴏᴛꜱ 🤑",
    [5] = "ᵉᶻ ¹ ᵇʸ ⁿᵉᵍʳᵒᵏˡᵃⁿ ʳᵉˢᵒˡᵛᵉʳ - vacban.wtf/threads/103881/",
    [6] = "˜”*°•.˜”*°• head re$olve too good •°*”˜.•°*”˜",
    [7] = "【﻿ｎｅｇｒｏｋｌａｎ　ｒｅｓｏｌｖｅｓ　ａｌｌ　ｂｏｔｓ】",
    [8] = "𝕓𝕒𝕟𝕕 𝕗𝕠𝕣 𝕓𝕒𝕟𝕕? 𝕚 𝕤𝕒𝕪 𝕘𝕖𝕥 𝕘𝕠𝕠𝕕 𝕣𝕖𝕤𝕠𝕝𝕧𝕖",
    [9] = "talk to me when you have negroklan resolver",
    [10] = "#օղӀվɾҽʂօӀѵҽաìէհղҽցɾօҟӀąղ - vacban.wtf/threads/103881/",
    [11] = "(っ◔◡◔)っ ♥ uninstall or get negroklan ♥",
    [12] = "𝚗𝚒𝚌𝚎 𝚔𝚍 𝚗𝚎𝚐𝚛𝚘𝚔𝚕𝚊𝚗 𝚜𝚕𝚊𝚟𝚎",
    [13] = "no negroklan resovler no kd haha! - vacban.wtf/threads/103881/",
    [14] = "NEGROKLAN V4 RESOLVES DEFENSIVE - vacban.wtf/threads/103881/",
    [15] = "i resolve all aa's thanks to negroklan - vacban.wtf/threads/103881/",
    [16] = "negroklan top - vacban.wtf/threads/103881/",
}

local function on_player_death(e)
    if not ui.get(MenuC["Nigger"]) then
        return
    end
	local victim_userid, attacker_userid = e.userid, e.attacker
	if victim_userid == nil or attacker_userid == nil then
		return
	end

	local victim_entindex = userid_to_entindex(victim_userid)
	local attacker_entindex = userid_to_entindex(attacker_userid)

	if attacker_entindex == get_local_player() and is_enemy(victim_entindex) then
        client.delay_call(ui.get(MenuC["Delay"]), function()
            console_cmd("say ", words[math.random(1,14)])
        end)
	end
end
client.set_event_callback("player_death", on_player_death)

local player_data = {
    interpolation_data = {},
    velocity_data = {}
}

local yaw_cache = {  }
local annen = { }
local Animlayers =  {};
local AnimParts =   {};
local AnimList =    {"m_flPrevCycle", "m_flWeight", "m_flWeightDeltaRate", "m_flPlaybackRate", "m_flCycle"};
local cache = { DesyncCache = {} }
local g_esp_data = { }
local g_sim_ticks, g_net_data = { }, { }
local globals_tickinterval = globals.tickinterval
local entity_is_enemy = entity.is_enemy
local entity_get_prop = entity.get_prop
local entity_is_dormant = entity.is_dormant
local entity_is_alive = entity.is_alive
local entity_get_origin = entity.get_origin
local entity_get_local_player = entity.get_local_player
local entity_get_player_resource = entity.get_player_resource
local entity_get_bounding_box = entity.get_bounding_box
local entity_get_player_name = entity.get_player_name
local renderer_text = renderer.text
local w2s = renderer.world_to_screen
local line = renderer.line
local table_insert = table.insert
local client_trace_line = client.trace_line
local math_floor = math.floor
local globals_frametime = globals.frametime

local sv_gravity = cvar.sv_gravity
local sv_jump_impulse = cvar.sv_jump_impulse

local time_to_ticks = function(t) return math_floor(0.5 + (t / globals_tickinterval())) end
local vec_subtract = function(a, b) return { a[1] - b[1], a[2] - b[2], a[3] - b[3] } end
local vec_add = function(a, b) return { a[1] + b[1], a[2] + b[2], a[3] + b[3] } end
local vec_length = function(x, y) return (x * x + y * y) end

local get_entities = function(enemy_only, alive_only)
    local enemy_only = enemy_only ~= nil and enemy_only or false
    local alive_only = alive_only ~= nil and alive_only or true
    
    local result = {}

    local me = entity_get_local_player()
    local player_resource = entity_get_player_resource()
    
    for player = 1, globals.maxplayers() do
        local is_enemy, is_alive = true, true
        
        if enemy_only and not entity_is_enemy(player) then is_enemy = false end
        if is_enemy then
            if alive_only and entity_get_prop(player_resource, 'm_bAlive', player) ~= 1 then is_alive = false end
            if is_alive then table_insert(result, player) end
        end
    end

    return result
end

local extrapolate = function(ent, origin, flags, ticks)
    local tickinterval = globals_tickinterval()

    local sv_gravity = sv_gravity:get_float() * tickinterval
    local sv_jump_impulse = sv_jump_impulse:get_float() * tickinterval

    local p_origin, prev_origin = origin, origin

    local velocity = { entity_get_prop(ent, 'm_vecVelocity') }
    local gravity = velocity[3] > 0 and -sv_gravity or sv_jump_impulse

    for i=1, ticks do
        prev_origin = p_origin
        p_origin = {
            p_origin[1] + (velocity[1] * tickinterval),
            p_origin[2] + (velocity[2] * tickinterval),
            p_origin[3] + (velocity[3]+gravity) * tickinterval,
        }

        local fraction = client_trace_line(-1, 
            prev_origin[1], prev_origin[2], prev_origin[3], 
            p_origin[1], p_origin[2], p_origin[3]
        )

        if fraction <= 1.49 then
            return prev_origin
        end
    end
    return p_origin
end

local function g_net_update()
    local me = entity_get_local_player()
    local players = get_entities(true, true)

    for i=1, #players do
        local idx = players[i]
        local prev_tick = g_sim_ticks[idx]
        
        if entity_is_dormant(idx) or not entity_is_alive(idx) then
            g_sim_ticks[idx] = nil
            g_net_data[idx] = nil
            g_esp_data[idx] = nil
        else
            local player_origin = { entity_get_origin(idx) }
            local simulation_time = time_to_ticks(entity_get_prop(idx, 'm_flSimulationTime'))
    
            if prev_tick ~= nil then
                local delta = simulation_time - prev_tick.tick

                if delta < 0 or delta > 0 and delta <= 64 then
                    local m_fFlags = entity_get_prop(idx, 'm_fFlags')

                    local diff_origin = vec_subtract(player_origin, prev_tick.origin)
                    local teleport_distance = vec_length(diff_origin[1], diff_origin[2])

                    local extrapolated = extrapolate(idx, player_origin, m_fFlags, delta-1)
    
                    if delta < 0 then
                        g_esp_data[idx] = 1
                    end

                    g_net_data[idx] = {
                        tick = delta-1,

                        origin = player_origin,
                        predicted_origin = extrapolated,

                        tickbase = delta < 0,
                        lagcomp = teleport_distance > 4096,
                    }
                end
            end
    
            if g_esp_data[idx] == nil then
                g_esp_data[idx] = 0
            end

            g_sim_ticks[idx] = {
                tick = simulation_time,
                origin = player_origin,
            }
        end
    end
end

local function check_valid_tick(player)
    if g_net_data[player] ~= nil then
        if g_net_data[player].tickbase then
            return false
        else
            return true
        end
    end
end

local resolved_yaw = {}
local layer_data = {}
local yaw = 0

local resolver_data = {}

local function resolver(player, state)
        local player_id = player

        if not resolver_data[player_id] then
            resolver_data[player_id] = {
                previous_eye_angles = {
                    valid = false,
                    x = 0
                },
                last_pitch_delta = 0,
                ticks_without_change = 0
            }
        end

        local data = resolver_data[player_id]

        local anim_state = state
        local current_eye_angles = {
            x = anim_state.m_flPitch
        }

        if data.previous_eye_angles.valid then
            local delta_pitch = current_eye_angles.x - data.previous_eye_angles.x

            local pitch_delta_change = math.abs(delta_pitch - data.last_pitch_delta)
            data.last_pitch_delta = delta_pitch

            if math.abs(delta_pitch) <= 1.0 then --@note: delta_pitch = -1   ->   1
                data.ticks_without_change = data.ticks_without_change + 1
            else
                data.ticks_without_change = 0
            end

            if math.abs(delta_pitch) > 15 or (pitch_delta_change > 15 and data.ticks_without_change > 2) then
                local new_pitch = data.previous_eye_angles.x + delta_pitch
                plist.set(player, "Force pitch", true)
                plist.set(player, "Force pitch value", new_pitch)
            end
        end

        data.previous_eye_angles.valid = true
        data.previous_eye_angles.x = current_eye_angles.x
end

local yaw_cache = {  }

function predict_next_enemy_yaw(player)
    local data = yaw_cache 
    local current_eye_yaw = entity.get_prop(player, "m_angEyeAngles[1]")
    if yaw_cache[1] == nil then
        yaw_cache[1] = current_eye_yaw
    end
    if yaw_cache[2] == nil and yaw_cache[1] ~= nil and yaw_cache[1] ~= current_eye_yaw then
        yaw_cache[2] = current_eye_yaw
    end
    if data[1] ~= nil and data[2] ~= nil and data[3] ~= nil and data[4] ~= nil and data[5] ~= nil then
        if math.abs(data[1]) - math.abs(data[2]) > 30.0 then
            resolved[player] = true
            return current_eye_yaw + data[2]
        elseif math.abs(current_eye_yaw) - math.abs(data[2]) > 30.0 then
            resolved[player] = true
            return current_eye_yaw + data[1]
        end
    end
end

local side = {}

local function normalize_angle(angle)
    angle = angle % 360
    if angle > 180 then
        angle = angle - 360
    end
    return angle
end

local missed_shots = {}
local last_debug_time = 0

local eyeside


local defensive_values = {
    yaw = {},
    pitch = {}
}

local function save_defensive_values(player, animstation)
    if not animstation then return end

    if not defensive_values[player] then
        defensive_values[player] = {
            yaw = {},
            pitch = {}
        }
    end
    if g_net_data[player] ~= nil then
        if g_net_data[player].tickbase then
            table.insert(defensive_values[player].pitch,math.floor(animstation.m_flPitch))
            table.insert(defensive_values[player].yaw,math.floor(animstation.m_flEyeYaw))
        end
    end
end
local regular_pitch
local function resolve_defensive_pitch(player, animstation)
    if not animstation then return end
    save_defensive_values(player,animstation)
    if g_net_data[player] ~= nil then
        if g_net_data[player].tickbase then
            plist.set(player, "Override safe point","On")
            if defensive_values[player] ~= nil then
                for i=1,#defensive_values[player].pitch do
                    local saved_pitch = defensive_values[player].pitch[i]
                    if saved_pitch == math.floor(animstation.m_flPitch) then
                        if defensive_values[player].pitch[i+1] ~= nil then
                            plist.set(player,"Force pitch",true)
                            plist.set(player,"Force pitch value",defensive_values[player].pitch[i+1])
                        else
                            plist.set(player,"Force pitch",true)
                            plist.set(player,"Force pitch value",defensive_values[player].pitch[1])
                        end
                    end
                end
            end
        else
            plist.set(player, "Override safe point","Off")
            plist.set(player,"Force pitch",false)
        end
    end
end

local function resolve_defensive_yaw(player, animstation)
    if not animstation then return end
    save_defensive_values(player,animstation)
    if g_net_data[player] ~= nil then
        if g_net_data[player].tickbase then
            if defensive_values[player] ~= nil then
                for i=1,#defensive_values[player].yaw do
                    local saved_yaw = defensive_values[player].yaw[i]
                    if saved_yaw == math.floor(animstation.m_flEyeYaw) then
                        if defensive_values[player].yaw[i+1] ~= nil then
                            animstation.m_flEyeYaw = defensive_values[player].yaw[i+1]
                        else
                            animstation.m_flEyeYaw = defensive_values[player].yaw[1]
                        end
                    end
                end
            end
        end
    end
end

local resolved_yaw = {}
local layer_data = {}
local yaw = 0
local sex
local miss_count = 0
local resolvered = 0
local set_value = 57
local function desync(faggot)
    if not ui.get(MenuC["Enable"]) then return end
    local PlayerP = get_client_entity(ientitylist, faggot);
    plist.set(faggot, "Correction active", false)
    local animstate = get_anim_state(PlayerP)
    if not animstate then
        return
    end
    save_defensive_values(faggot,animstate)
    local sides = 0
    local body_yaw = entity.get_prop(faggot, "m_flPoseParameter", 11)
    local pitch = entity.get_prop(faggot, "m_flPoseParameter", 11)
    local current_eye_yaw = entity.get_prop(faggot, "m_angEyeAngles[1]")
    local old_body_yaw = (entity.get_prop(faggot, "m_flPoseParameter", 11) * 60)
    local velo = entity.get_prop(faggot, "m_vecVelocity[1]")
    local move_yaw = cache.DesyncCache
    for u = 1, 13, 1 do
        Animlayers[u] = {};
        Animlayers[u]["Main"] =                 get_anim_layer(PlayerP, u);

        Animlayers[u]["m_flPrevCycle"] =        Animlayers[u]["Main"].m_flPrevCycle;
        Animlayers[u]["m_flWeight"] =           Animlayers[u]["Main"].m_flWeight;
        Animlayers[u]["m_flWeightDeltaRate"] =  Animlayers[u]["Main"].m_flWeightDeltaRate;
        Animlayers[u]["m_flPlaybackRate"] =     Animlayers[u]["Main"].m_flPlaybackRate;
        Animlayers[u]["m_flCycle"] =            Animlayers[u]["Main"].m_flCycle;

        AnimParts[u] = {};
        for y, val in pairs(AnimList) do
            AnimParts[u][val] = {};
            for i = 1, 13, 1 do
                AnimParts[u][val][i] = math.floor(Animlayers[u][val]*(10^i)) - (math.floor(Animlayers[u][val]*(10^(i-1)))*10);
            end
        end
    end
    if math.abs(velo) == 0 then
        move_yaw[2] = body_yaw * 60
    end
    if math.abs(velo) > 1 then
        move_yaw[3] = body_yaw * 60
    end
    if math.abs(velo) > 1 and math.abs(velo) < 2 then
        move_yaw[1] = body_yaw * 60
    end
    local normalized_layer = Animlayers[6]["m_flPlaybackRate"] + 1
	local threshold = 0.000001
	local maximum_threshold = 0.0000013
	local jitter_threshold = 0.0000005
	resolve_defensive_pitch(faggot, animstate)
    resolve_defensive_yaw(faggot,animstate)
	if layer_data[1] == nil then
        layer_data[1] = normalized_layer    
    end
    if layer_data[2] == nil and layer_data[1] ~= nil and layer_data[1] ~= normalized_layer then
        layer_data[2] = normalized_layer
    end
	if layer_data[1] ~= nil and layer_data[2] ~= nil then
        local delta = (layer_data[1] - layer_data[2]) + 0.0000001
        local delta2 = (layer_data[2] - layer_data[1]) + 0.0000001
		if delta > delta2 then
            sex = 1
            layer_data[1] = nil
            layer_data[2] = nil
        else
            sex = -1
            layer_data[1] = nil
            layer_data[2] = nil
        end
    end
    local flEyeFootDelta = AngleDifference(animstate.m_flEyeYaw, resolvered)
    local flAimMatrixWidthRange = CalculateAimMatrixWidthRange(animstate) --good job you deobfuscated the lua! now what?

    local flTempYawMax = animstate.m_flAimYawMax * flAimMatrixWidthRange
    local flTempYawMin = animstate.m_flAimYawMin * flAimMatrixWidthRange
    if velo < 25 then
        set_value = 57
    elseif velo > 25 and velo < 100 then
        set_value = math.random(34,47)
    elseif velo > 100 then
        set_value = math.random(29,31)
    end
    if flEyeFootDelta > flTempYawMax then
        animstate.m_flGoalFeetYaw = animstate.m_flEyeYaw - math.abs(flTempYawMax)
    elseif flEyeFootDelta < flTempYawMin then
        animstate.m_flGoalFeetYaw = animstate.m_flEyeYaw + math.abs(flTempYawMin)
    end
    animstate.m_flGoalFeetYaw = NormalizeAngle(animstate.m_flGoalFeetYaw)
    local data = yaw_cache 
    local current_eye_yaw = animstate.m_flEyeYaw
    if yaw_cache[1] == nil then
        yaw_cache[1] = current_eye_yaw
    end
    if yaw_cache[2] == nil and yaw_cache[1] ~= nil and yaw_cache[1] ~= current_eye_yaw then
        yaw_cache[2] = current_eye_yaw
    end
    if animstate.m_bOnGround then --see if player is on ground
        if animstate.m_flSpeed > 0.1 then --see if player is walking and resolve accordingly
            animstate.m_flGoalFeetYaw = Approach(animstate.m_flEyeYaw, animstate.m_flGoalFeetYaw, animstate.m_flLastUpdateIncrement * (30.0 + 20.0 * animstate.flWalkToRunTransition))
            if animstate.m_flSpeed > 0.1 then --see if player is running and resolve accordingly
                animstate.m_flGoalFeetYaw = ApplyHighSpeedCorrection(animstate.m_flEyeYaw, animstate.m_flGoalFeetYaw, animstate.m_flSpeed)
            end
        else --standing statement
            animstate.m_flGoalFeetYaw = Approach(animstate.m_flLowerBodyYawTarget, animstate.m_flGoalFeetYaw, animstate.m_flLastUpdateIncrement * CSGO_ANIM_LOWER_CATCHUP_IDLE)
        end
    else --resolve player if in air (e.g defensive resolver)
        if animstate.m_flSpeed > 0.1 then
            animstate.m_flGoalFeetYaw = ApplyHighSpeedCorrection(animstate.m_flEyeYaw, animstate.m_flGoalFeetYaw, animstate.m_flSpeed)
        end
    end
    local eye_yaw = entity.get_prop(player, "m_angEyeAngles[1]")
    if ui.get(MenuC["Method"]) == "Default" then
        if sex ~= nil then
            animstate.m_flGoalFeetYaw = math.abs(animstate.m_flGoalFeetYaw)*sex
        end
    elseif ui.get(MenuC["Method"]) == "Eye Brute" then
        if yaw_cache[1] ~= nil and yaw_cache[2] ~= nil then
            if yaw_cache[1] > yaw_cache[2] and yaw_cache[1] - yaw_cache[2] > (0 or 30) then
                eyeside = -1
            elseif  yaw_cache[2] > yaw_cache[1] and yaw_cache[1] - yaw_cache[2] > (0 or 30) then
                eyeside = -1
            elseif yaw_cache[1] > yaw_cache[2] and yaw_cache[1] - yaw_cache[2] > (yaw_cache[2]) or yaw_cache[1] - yaw_cache[2] < 0 then
                eyeside = 1
            elseif  yaw_cache[2] > yaw_cache[1] and (yaw_cache[1] - yaw_cache[2] > (yaw_cache[1]) or (yaw_cache[1] - yaw_cache[2] < 0 and yaw_cache[1] - yaw_cache[2] < yaw_cache[1])) then
                eyeside = 1
            end
            if animstate.m_flEyeYaw ~= (yaw_cache[1] or yaw_cache[2]) then
                yaw_cache[1] = nil
                yaw_cache[2] = nil
            end
        end
        if eyeside ~= nil then
            animstate.m_flGoalFeetYaw = math.abs(animstate.m_flGoalFeetYaw) * eyeside
        end
    if ui.get(MenuC["Method"]) == "Default" then
        if sex == 1 then
            side[faggot] = "Right"
        else
            side[faggot] = "Left"
        end
    end
end
end

local jitter = { 
    values = {} ,
    simtimes = {}
}

local hitgroup_names = {'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear'}


local function aim_miss(e)
    local group = hitgroup_names[e.hitgroup + 1] or '?'
    if e.reason == "?" then
        if g_net_data[e.target] ~= nil then
            if entity.get_prop(e,"m_vecOrigin") == g_net_data[e.target].predicted_origin then
                print("resolver | missed shot on ",e.target,"'s ",group," due to extrapolation")
            else
                print("resolver | missed shot on ",e.target,"'s ",group," due to resolver")
            end
        end
    elseif e.reason == "prediction error" then
        if entity.get_prop(e,"m_vecOrigin") == g_net_data[e.target].predicted_origin then
            print("resolver | missed shot on ",e.target,"'s ",group," due to extrapolation")
        else
            print("resolver | missed shot on ",e.target,"'s ",group," due to prediction error")
        end
    else
        print("resolver | missed shot on ",e.target,"'s ",group," due to ",e.reason)
    end
end

client.set_event_callback('aim_miss', aim_miss)

local previous_yaw = {}

local function Jitterresolver(entity_index)
    local PlayerP = get_client_entity(ientitylist, entity_index);
    local simulation_time = entity.get_prop(entity_index, "m_flSimulationTime")
    local animstate = get_anim_state(PlayerP)
    if not animstate then
        return
    end
    local index = entity_index
    local current_yaw = entity.get_prop(entity_index, "m_angEyeAngles[1]")

    if previous_yaw[entity_index] then
        local jitter_delta = math.abs(normalize_angle(current_yaw - previous_yaw[index]))
        if jitter_delta > 15 then
            entity.set_prop(entity_index, "m_angEyeAngles[1]", previous_yaw[index] * simulation_time)
        end
    end

    previous_yaw[entity_index] = current_yaw
end


local function on_paint()
    local me = entity_get_local_player()
    local player_resource = entity_get_player_resource()

    if not me or not entity_is_alive(me) then
        return
    end

    local observer_mode = entity_get_prop(me, "m_iObserverMode")
    local active_players = {}

    if (observer_mode == 0 or observer_mode == 1 or observer_mode == 2 or observer_mode == 6) then
        active_players = get_entities(true, true)
    elseif (observer_mode == 4 or observer_mode == 5) then
        local all_players = get_entities(false, true)
        local observer_target = entity_get_prop(me, "m_hObserverTarget")
        local observer_target_team = entity_get_prop(observer_target, "m_iTeamNum")

        for test_player = 1, #all_players do
            if (
                observer_target_team ~= entity_get_prop(all_players[test_player], "m_iTeamNum") and
                all_players[test_player ] ~= me
            ) then
                table_insert(active_players, all_players[test_player])
            end
        end
    end

    if #active_players == 0 then
        return
    end

    for idx, net_data in pairs(g_net_data) do
        if entity_is_alive(idx) and entity_is_enemy(idx) and net_data ~= nil then
            if net_data.lagcomp then
                local predicted_pos = net_data.predicted_origin
                if predicted_pos ~= nil then
                    entity.set_prop(idx,"m_vecOrigin[0]", predicted_pos[1])
                    entity.set_prop(idx,"m_vecOrigin[1]", predicted_pos[2])
                    entity.set_prop(idx,"m_vecOrigin", predicted_pos)
                end

                local min = vec_add({ entity_get_prop(idx, 'm_vecMins') }, predicted_pos)
                local max = vec_add({ entity_get_prop(idx, 'm_vecMaxs') }, predicted_pos)

                local points = {
                    {min[1], min[2], min[3]}, {min[1], max[2], min[3]},
                    {max[1], max[2], min[3]}, {max[1], min[2], min[3]},
                    {min[1], min[2], max[3]}, {min[1], max[2], max[3]},
                    {max[1], max[2], max[3]}, {max[1], min[2], max[3]},
                }

                local edges = {
                    {0, 1}, {1, 2}, {2, 3}, {3, 0}, {5, 6}, {6, 7}, {1, 4}, {4, 8},
                    {0, 4}, {1, 5}, {2, 6}, {3, 7}, {5, 8}, {7, 8}, {3, 4}
                }

                for i = 1, #edges do
                    if i == 1 then
                        local origin = { entity_get_origin(idx) }
                        local origin_w2s = { w2s(origin[1], origin[2], origin[3]) }
                        local min_w2s = { w2s(min[1], min[2], min[3]) }

                        if origin_w2s[1] ~= nil and min_w2s[1] ~= nil then
                            line(origin_w2s[1], origin_w2s[2], min_w2s[1], min_w2s[2], 47, 117, 221, 255)
                        end
                    end

                    if points[edges[i][1]] ~= nil and points[edges[i][2]] ~= nil then
                        local p1 = { w2s(points[edges[i][1]][1], points[edges[i][1]][2], points[edges[i][1]][3]) }
                        local p2 = { w2s(points[edges[i][2]][1], points[edges[i][2]][2], points[edges[i][2]][3]) }
            
                        line(p1[1], p1[2], p2[1], p2[2], 47, 117, 221, 255)
                    end
                end
            end

            local text = {
                [0] = '', [1] = 'BREAKING LC',
                [2] = 'SHIFTING TICKBASE',
                [3] = 'INTERPOLATING'
            }

            local x1, y1, x2, y2, a = entity_get_bounding_box(idx)
            local palpha = 0

            if g_esp_data[idx] > 0 then
                g_esp_data[idx] = g_esp_data[idx] - globals_frametime()*2
                g_esp_data[idx] = g_esp_data[idx] < 0 and 0 or g_esp_data[idx]

                palpha = g_esp_data[idx]
            end

            local tb = net_data.tickbase or g_esp_data[idx] > 0
            local lc = net_data.lagcomp
            local ip = false
            if player_data[idx] then
                ip = player_data[idx].interpolation_data.isInterpolating
            end
            if not tb or net_data.lagcomp then
                palpha = a
            end

            if x1 ~= nil and a > 0 then
                local name = entity_get_player_name(idx)
                local y_add = name == '' and -8 or 0

                renderer_text(x1 + (x2-x1)/2, y1 - 18 + y_add, 255, 45, 45, palpha*255, 'c', 0, text[tb and 2 or (lc and 1 or 0) or ip and 3])
            end
        end
    end
end

client.set_event_callback('paint', on_paint)
client.set_event_callback('net_update_end', g_net_update)

client.set_event_callback("paint", function()
    if not ui.get(MenuC["Enable"]) then
        return;
    end
    local enemies = entity.get_players(true)
    for i=1, #enemies do
        local player = enemies[i]
        desync(player)
    end
    if ui.get(MenuC["Woah"]) then
        client.set_clan_tag("$negroklan$")
    end
end)

client.register_esp_flag("RIGHT", 150, 150, 150, function(Player)
    if not ui.get(MenuC["Enable"]) then
        return false;
    end

    if side[Player] == "Right" then
        return true;
    end

    return false;
end)

client.register_esp_flag("LEFT", 150, 150, 150, function(Player)
    if not ui.get(MenuC["Enable"]) then
        return false;
    end

    if side[Player] == "Left" then
        return true;
    end

    return false;
end)