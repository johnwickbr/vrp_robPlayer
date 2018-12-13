--[[
    vrp_robPlayer
    Copyright C 2018  MarmotaGit
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    at your option any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")
Lang = module("vrp_robPlayer", "Lang")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_robPlayer")
robPlayer = Tunnel.getInterface("vrp_robPlayer","vrp_robPlayer")

local function ch_robPlayer(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id then
        vRPclient.getNearestPlayer(player, {10}, function(nPlayer)
            if nPlayer then
                robPlayer.handsUp(nPlayer, {}, function(handsUp)
                    if handsUp then
                        local nUser_id = vRP.getUserId({nPlayer})
                        local nData = vRP.getUserDataTable({nUser_id})
                        if nData ~= nil then
                            local nInventory = nData.inventory
                            local nMoney = vRP.getMoney({nUser_id})
                            if vRP.tryPayment({nUser_id, nMoney}) then
                                vRP.giveMoney({user_id, nMoney})
                            end
                            vRPclient.getWeapons(nPlayer,{},function(nWeapons)
                                for k,v in pairs(nWeapons) do
                                    vRP.giveInventoryItem({user_id, "wbody|"..k, 1, true})
                                    if v.ammo > 0 then
                                        vRP.giveInventoryItem({user_id, "wammo|"..k, v.ammo, true})
                                    end
                                end
                                vRPclient.giveWeapons(nPlayer,{{},true})
                            end)
                            vRP.clearInventory({nUser_id})
                            for k, v in pairs(nInventory) do
                                vRP.giveInventoryItem({user_id, k, v.amount, true})
                            end
                            vRPclient.notify(nPlayer, {Lang.victim.robbed})
                            vRPclient.notify(player, {Lang.robber.success})
                        end
                    else
                        vRPclient.notify(player, {Lang.robber.notHandsUp})
                        vRPclient.notify(nPlayer, {Lang.victim.triedRob})
                    end
                end)
            else
                vRPclient.notify(player, {Lang.robber.noNearPlayers})
            end
        end)
    end
end

vRP.registerMenuBuilder({"main", function(add, data)
    local choices = {}
    choices[Lang.title] = {ch_robPlayer, Lang.description}
    add(choices)
end})