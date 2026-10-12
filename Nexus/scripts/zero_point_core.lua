--zero_point_core.lua

-- The four invisible limiter pumps around a zero-point energy engine core. Each quality above normal has its own,
-- faster pump (prototypes/entity/zero_point_energy_engine_core/pump_qualities.lua), so the throughput of a core grows
-- with its quality.

local zero_point_core = {}

local CORE = "zero-point-energy-engine-core"
local BASE_PUMP = "invisible-throughput-limiter-pump"

local connections = {
    { relative_pos = {x = 8.0, y = 2.0}, pump_direction = defines.direction.south },
    { relative_pos = {x = -8.0, y = 2.0}, pump_direction = defines.direction.north },
    { relative_pos = {x = 0.0, y = 8.0}, pump_direction = defines.direction.west },
    { relative_pos = {x = 0.0, y = -4.0}, pump_direction = defines.direction.east }
}

-- The limiter pump for the quality of a core; the normal one when there is no pump of that quality.
local function pump_name(core)
    local name = BASE_PUMP .. "-" .. core.quality.name
    if core.quality.level > 0 and prototypes.entity[name] then
        return name
    end
    return BASE_PUMP
end

-- The names of the limiter pumps of all qualities.
local function pump_names()
    local names = {BASE_PUMP}
    for _, quality in pairs(prototypes.quality) do
        local name = BASE_PUMP .. "-" .. quality.name
        if prototypes.entity[name] then
            names[#names + 1] = name
        end
    end
    return names
end

local function find_pumps(core, names)
    local found = {}
    for _, connection in pairs(connections) do
        local pumps = core.surface.find_entities_filtered({
            position = {x = core.position.x + connection.relative_pos.x, y = core.position.y + connection.relative_pos.y},
            radius = 0.5,
            name = names
        })
        for _, pump in pairs(pumps) do
            found[#found + 1] = pump
        end
    end
    return found
end

function zero_point_core.place_pumps(core)
    local name = pump_name(core)
    for _, connection in pairs(connections) do
        core.surface.create_entity({
            name = name,
            position = {x = core.position.x + connection.relative_pos.x, y = core.position.y + connection.relative_pos.y},
            force = core.force,
            direction = connection.pump_direction
        })
    end
end

function zero_point_core.remove_pumps(core)
    for _, pump in pairs(find_pumps(core, pump_names())) do
        if pump.valid then pump.destroy() end
    end
end

-- A save from before the quality pumps: the cores that are not of normal quality get the pumps of their quality.
function zero_point_core.refresh_all()
    if not prototypes.entity[CORE] then return end

    for _, surface in pairs(game.surfaces) do
        for _, core in pairs(surface.find_entities_filtered({name = CORE})) do
            local name = pump_name(core)
            if name ~= BASE_PUMP then
                for _, pump in pairs(find_pumps(core, {BASE_PUMP})) do
                    local position, direction, force = pump.position, pump.direction, pump.force
                    pump.destroy()
                    surface.create_entity({name = name, position = position, direction = direction, force = force})
                end
            end
        end
    end
end

return zero_point_core
