Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")
Lang = module("vrp_robPlayer", "Lang")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_robPlayer")
robPlayer = Tunnel.getInterface("vrp_robPlayer","vrp_robPlayer")

local function ch_robPlayer(player, choice)
    local user_id = vRP.getUserId(player)
    if user_id then
        local nPlayer = vRPclient.getNearestPlayer(player, 10)
        if nPlayer then
            if robPlayer.handsUp(nPlayer) then
                local nUser_id = vRP.getUserId(nPlayer)
                local nInventory = vRP.getInventory(nUser_id)
                local nWeapons = vRPclient.replaceWeapons(nPlayer, {})
                local nMoney = vRP.getMoney(nUser_id)
                vRP.clearInventory(nUser_id)
                if vRP.tryPayment(nUser_id, nMoney) then
                    vRP.giveMoney(user_id, nMoney)
                end
                for k, v in pairs(nInventory) do
                    vRP.giveInventoryItem(user_id, k, v.amount, true)
                end
                for k,v in pairs(nWeapons) do
                    vRP.giveInventoryItem(user_id, "wbody|"..k, 1, true)
                    if v.ammo > 0 then
                        vRP.giveInventoryItem(user_id, "wammo|"..k, v.ammo, true)
                    end
                end
                vRPclient.notify(nPlayer, Lang.victim.robbed)
                vRPclient.notify(player, Lang.robber.success)
            else
                vRPclient.notify(player, Lang.robber.notHandsUp)
                vRPclient.notify(nPlayer, Lang.victim.triedRob)
            end
        else
            vRPclient.notify(player, Lang.robber.noNearPlayers)
        end
    end
end

Citizen.CreateThread(function()
    vRP.registerMenuBuilder("main", function(add, data)
        local choices = {}
        choices["robPlayer"] = {ch_robPlayer, ""}
        add(choices)
    end)
end)