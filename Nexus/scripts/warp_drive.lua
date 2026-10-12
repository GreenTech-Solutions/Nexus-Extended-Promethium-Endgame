--warp_drive.lua

-- The warp drive engine is meant for the jump to the Oort cloud and on to Sol. On an ordinary route it throws the
-- platform through dense asteroid lines: the game drops to under 1 UPS for hours and multiplayer desyncs. The engines
-- of a platform are switched off while it travels a route that neither starts nor ends at the Oort cloud or Sol, and on
-- again otherwise.

local warp_drive = {}

local ENGINE = "warp-drive-engine"
local WARP_LOCATIONS = { ["oort-cloud"] = true, ["sol"] = true }

function warp_drive.update_platform(platform)
    if not (platform and platform.valid and platform.surface) then return end

    local connection = platform.space_connection
    local allowed = not connection or WARP_LOCATIONS[connection.from.name] or WARP_LOCATIONS[connection.to.name] or false
    for _, engine in pairs(platform.surface.find_entities_filtered({name = ENGINE})) do
        engine.disabled_by_script = not allowed
    end
end

function warp_drive.refresh_all()
    for _, force in pairs(game.forces) do
        for _, platform in pairs(force.platforms) do
            warp_drive.update_platform(platform)
        end
    end
end

return warp_drive
