local Tunnel = module("vrp", "lib/Tunnel")

local robPlayer = {}

Tunnel.bindInterface("vrp_robPlayer", robPlayer)

function robPlayer.handsUp()
    return IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "random@mugging3", "handsup_standing_base", 3)
end