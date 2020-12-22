--discord: morpheause#7800

ESX = nil

stealkey = 182 --L
lootdeadkey = 311 --K
usehandcuff = true -- for modified policejob dont use -- default false

Citizen.CreateThread(function()
    while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(0)
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(2)
--         if IsControlJustPressed(1, stealkey) and not IsEntityPlayingAnim(PlayerPedId(), 'misslamar1dead_body', 'dead_idle', 3) and not IsPedInAnyVehicle(PlayerPedId(), true) then -- steal
--             if IsPedArmed(PlayerPedId(), 7) then
--                 local target, distance = ESX.Game.GetClosestPlayer()
--                 OpenTargetInventory(target, distance)
--             else
--                 TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Silahını çekmen gerekiyor!'})
--             end
--         end

--         if IsControlJustReleased(0, lootdeadkey) and not IsEntityDead(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId(), true) then -- lootdead
--             local target, distance = ESX.Game.GetClosestPlayer()
--             OpenDeadTargetInventory(target, distance)
--         end
--     end
-- end)

function OpenTargetInventory(target, distance)
    local searchPlayerPed = GetPlayerPed(target)
    if target ~= -1 and distance ~= -1 and distance <= 3.0 and not IsEntityPlayingAnim(searchPlayerPed, 'misslamar1dead_body', 'dead_idle', 3) and IsEntityPlayingAnim(searchPlayerPed, 'random@mugging3', 'handsup_standing_base', 3) then
		local playerP=PlayerPedId()
		
		exports['mythic_progbar']:Progress({
            name = "unique_action_name",
            duration = 4500,
            label = "Kişinin üstünü arıyorsun...",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "combat@aim_variations@arrest",
                anim = "cop_med_arrest_01",
            }
        }, function(status)
            if not status then
                TriggerEvent('m3:inventoryhud:client:openPlayerInventory', GetPlayerServerId(target), 'player')
                ClearPedTasksImmediately(playerP)
                Citizen.CreateThread(function()
                    local closed = false
                    while true do
                        Citizen.Wait(3)
                        if not closed then
                            if not IsEntityPlayingAnim(searchPlayerPed, 'random@mugging3', 'handsup_standing_base', 3) then
                                TriggerEvent("m3:inventoryhud:client:forceClose")
                                closed = true
                                break
                            end

                            local target, distance = ESX.Game.GetClosestPlayer()
                            if distance > 3.0 then
                                TriggerEvent("m3:inventoryhud:client:forceClose")
                                closed = true
                                break
                            end
                        end
                        if closed then
                            closed = false
                            break
                        end
                    end
                end)
			end
		end)
    else
        TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Yakınında kelepçeli veya ellerini kaldıran kimse yok!'})
    end
end

function OpenDeadTargetInventory(target, distance)
    local searchPlayerPed = GetPlayerPed(target)
    if target ~= -1 and distance ~= -1 and distance <= 3.0 and IsEntityPlayingAnim(searchPlayerPed, 'misslamar1dead_body', 'dead_idle', 3) then
       
		local playerP=GetPlayerPed()
		local playerP1=PlayerPedId()
		local animDict = "amb@medic@standing@tendtodead@enter"
		local animLib = "enter"
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(50)
		end
        exports['mythic_progbar']:Progress({
            name = "unique_action_name",
            duration = 1400,
            label = "Kişinin üstünü arıyorsun...",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "amb@medic@standing@tendtodead@idle_a",
                anim = "idle_b",
            }
        }, function(status)
            if not status then
                TriggerEvent('m3:inventoryhud:client:openPlayerInventory', GetPlayerServerId(target), 'dead')
                Citizen.CreateThread(function()
                    local closed = false
                    while true do
                        Citizen.Wait(3)
                        if not closed then
                            if not IsEntityPlayingAnim(searchPlayerPed, 'misslamar1dead_body', 'dead_idle', 3) then
                                TriggerEvent("m3:inventoryhud:client:forceClose")
                                ClearPedTasksImmediately(PlayerPedId())
                                closed = true
                                break
                            end
                            
                            local target, distance = ESX.Game.GetClosestPlayer()
                            if distance > 3.0 then
                                TriggerEvent("m3:inventoryhud:client:forceClose")
                                closed = true
                                ClearPedTasksImmediately(PlayerPedId())
                                break
                            end
                        end
                        if closed then
                            ClearPedTasksImmediately(PlayerPedId())
                            closed = false
                            break
                        end
                    end
                end)
            end
        end)
    else
        TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Yakınında ölü olan kimse yok!'})
    end
end

RegisterCommand('soy', function()
    local target, distance = ESX.Game.GetClosestPlayer()
    if target ~= -1 and distance ~= -1 and distance <= 3.0 then
        if not IsEntityPlayingAnim(GetPlayerPed(target), 'misslamar1dead_body', 'dead_idle', 3) and IsEntityPlayingAnim(GetPlayerPed(target), 'random@mugging3', 'handsup_standing_base', 3) then
            if IsPedArmed(PlayerPedId(), 7) then
                OpenTargetInventory(target, distance)
            else
                TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Silahını çekmen gerekiyor!'})
            end
        else
            if IsEntityPlayingAnim(GetPlayerPed(target), 'misslamar1dead_body', 'dead_idle', 3) then
                OpenDeadTargetInventory(target, distance)
            end
        end
    else
        TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Yakınında kimse yok!'})
    end
end)