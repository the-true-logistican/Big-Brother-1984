-- control.lua des Client-Mods

local PROVIDER_API = "logistics_events_api"
local client_event_id = nil

-- Funktion, die die Daten vom Provider verarbeitet
local function handle_logistics_event(event)
    local le = event.logistics_event
    if not le then return end

    -- Gleiche Ausgabe wie im Big Brother, markiert als [CLIENT]
    local location_str = le.source_or_target.type .. " [ID:" .. le.source_or_target.id .. "] Slot:" .. le.source_or_target.slot_name
    
    if le.action == "TAKE" then
        game.print("💻 [CLIENT] 🔵 TAKE | Tick:" .. le.tick .. " | Actor:" .. le.actor.type .. " | Item:" .. le.item.name .. " | Qty:" .. le.item.quantity)
    else
        game.print("💻 [CLIENT] 🟢 GIVE | Tick:" .. le.tick .. " | Actor:" .. le.actor.type .. " | Target:" .. location_str .. " | Item:" .. le.item.name)
    end
end

-- Funktion zur Registrierung des Events
local function try_register_at_provider()
    -- Prüfen, ob das Interface des Big Brother existiert
    if remote.interfaces[PROVIDER_API] then
        local event_id = remote.call(PROVIDER_API, "get_event_id")
        
        if event_id then
            client_event_id = event_id
            -- Das Event dynamisch abonnieren
            script.on_event(client_event_id, handle_logistics_event)
            game.print("✅ [Logistics-Client] Erfolgreich beim Big Brother registriert. Event-ID: " .. tostring(event_id))
        end
    end
end

-- 1. Versuch beim Spielstart
script.on_init(function()
    try_register_at_provider()
end)

-- 2. Versuch beim Laden eines Spielstands
script.on_load(function()
    -- Hinweis: Bei on_load können wir keine remote.calls machen, 
    -- aber wenn wir die ID in storage hätten, könnten wir sie hier nutzen.
    -- Da die ID vom Provider in storage des Providers liegt, 
    -- registrieren wir uns sicherheitshalber bei on_configuration_changed erneut.
end)

-- 3. WICHTIG: Falls Mods hinzugefügt werden oder die Ladereihenfolge sich ändert
script.on_configuration_changed(function()
    try_register_at_provider()
end)

-- 4. Backup: Falls der Big Brother erst später per Runtime-Skript kommt
-- Wir prüfen alle paar Sekunden, falls wir noch keine ID haben
script.on_nth_tick(600, function()
    if not client_event_id then
        try_register_at_provider()
    end
end)