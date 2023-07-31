local commChannel = "REPLACE" --export: Communication channel

local RxTx = require("device/RxTx")
local Stream = require("Stream")

local Worker = {}
Worker.__index = Worker

function Worker.New()
    local s = {}
    local rx = library.getLinkByClass("ReceiverUnit")
    local stream ---@type Stream

    if not rx then
        system.print("No receiver")
    end

    local tx = library.getLinkByClass("EmitterUnit")

    if not tx then
        system.print("No emitter")
    end

    local hold = library.getLinkByName("hold")

    if not hold then
        system.print("No switch named 'hold' connected")
    end

    local gates = library.getLinkByName("gates")

    if not gates then
        system.print("No switch named 'gates' connected")
    end

    if not (rx and tx and hold and gates) then
        unit.exit()
    end

    -- Activate hold circuit
    hold.activate()

    local rxtx = RxTx.New(tx, rx, commChannel, false)

    local function shutdown()
        unit.setTimer("shutdown", 0.5)
    end

    unit:onEvent("onTimer", function(_, id)
        if id == "shutdown" then
            unit.exit()
        end
    end)

    unit:onEvent("onStop", function()
        hold.deactivate()
    end)

    ---@param data { topic:string, data:{ desiredState:boolean } }
    function s.OnData(data)
        local topic = data.topic
        local d = data.data

        if topic ~= "GateControl" or not d then
            system.print("Invalid data received")
            return
        end

        if d.desiredState then
            gates.activate()
        else
            gates.deactivate()
        end

        stream.Write({ topic = "GateControl", data = { state = d.desiredState } })
    end

    function s.OnTimeout(timeout, stream)
        if timeout then
            shutdown()
        end
    end

    function s.RegisterStream(stream)
        -- NOP
    end

    function s.Tick()
        stream.Tick()
    end

    stream = Stream.New(rxtx, s, 0.5)

    return setmetatable(s, Worker)
end

unit.hideWidget()
local worker = Worker.New()

system:onEvent("onUpdate", function()
    worker.Tick()
end)
