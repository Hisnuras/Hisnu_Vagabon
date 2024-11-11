-- time_command.lua

RegisterCommand('time', function(source, args)
    if args[1] then
        local hour = tonumber(args[1])
        if hour >= 0 and hour <= 23 then
            NetworkOverrideClockTime(hour, 0, 0)
            print('^3Time set to ' .. hour .. ':00^0')
        else
            print('^1Invalid hour. Please enter a value between 0 and 23.^0')
        end
    else
        print('^1Usage: /time [hour]^0')
    end
end, false)
