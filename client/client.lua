--================================================================================================--
--==                                VARIABLES - DO NOT EDIT                                     ==--
--================================================================================================--
ESX                         = nil
inMenu                      = true
local atbank = false
local bankMenu = true

function playAnim(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

--================================================================================================
--==                                THREADING - DO NOT EDIT                                     ==
--================================================================================================

--===============================================
--==           Base ESX Threading              ==
--===============================================
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
--===============================================
--==             Core Threading                ==
--===============================================
local obj = {
	`prop_atm_01`,
	`prop_atm_02`,
	`prop_atm_03`,
	`prop_fleeca_atm`
}

Citizen.CreateThread(function()	
	exports['bt-target']:AddTargetModel(obj, {
		options = {
			{
				event = "ipixel-banking:openMenu",
				icon = "far fa-credit-card",
				label = "ATM Menu",
			},
			{
				event = "ipixel-salary:take",
				icon = "far fa-credit-card",
				label = "Take Salary",
			},
		},
		job = {"all"},
		distance = 2.5
	})
end)

if bankMenu then
	Citizen.CreateThread(function()
		while true do
			Wait(3)
			--[[if nearBank() or nearATM() then
					DisplayHelpText(_U('atm_open'))

				if IsControlJustPressed(1, 38) then
					openUI()
					TriggerServerEvent('bank:balance')
					local ped = GetPlayerPed(-1)
				end
			end]]--

			if IsControlJustPressed(1, 322) then
				closeUI()
			end
		end
	end)
end


--===============================================
--==             Map Blips	                   ==
--===============================================

--BANK
Citizen.CreateThread(function()
	if Config.ShowBlips then
	  for k,v in ipairs(Config.Bank)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite (blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.5)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U("bank_blip"))
		EndTextCommandSetBlipName(blip)
	  end
	end
end)

--ATM
--[[Citizen.CreateThread(function()
	if Config.ShowBlips and Config.OnlyBank == false then
	  for k,v in ipairs(Config.ATM)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite (blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.9)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U("atm_blip"))
		EndTextCommandSetBlipName(blip)
	  end
	end
end)]]--


--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNetEvent('currentbalance1')
AddEventHandler('currentbalance1', function(balance)
	local id = PlayerId()
	local playerName = GetPlayerName(id)

	ESX.TriggerServerCallback('bank:getname', function(nombre, apellido)

	SendNUIMessage({
		type = "balanceHUD",
		balance = balance,
		player = nombre .. " " .. apellido
		})
	end)
end)
--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('bank:deposit', tonumber(data.amount))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==          Withdraw Event                   ==
--===============================================
RegisterNUICallback('withdrawl', function(data)
	TriggerServerEvent('bank:withdraw', tonumber(data.amountw))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Balance Event                     ==
--===============================================
RegisterNUICallback('balance', function()
	TriggerServerEvent('bank:balance')
end)

RegisterNetEvent('balance:back')
AddEventHandler('balance:back', function(balance)
	SendNUIMessage({type = 'balanceReturn', bal = balance})
end)


--===============================================
--==         Transfer Event                    ==
--===============================================
RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('bank:transfer', data.to, data.amountt)
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Result   Event                    ==
--===============================================
RegisterNetEvent('bank:result')
AddEventHandler('bank:result', function(type, message)
	SendNUIMessage({type = 'result', m = message, t = type})
end)

--===============================================
--==               NUIFocusoff                 ==
--===============================================
RegisterNUICallback('NUIFocusOff', function()
	closeUI()
end)

AddEventHandler('onResourceStop', function (resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	closeUI()
end)

AddEventHandler('onResourceStart', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	closeUI()
end)


--===============================================
--==            Capture Bank Distance          ==
--===============================================
--[[function nearBank()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)

	for _, search in pairs(Config.Bank) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)

		if distance <= 3 then
			return true
		end
	end
end

function nearATM()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)

	for _, search in pairs(Config.ATM) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)

		if distance <= 2 then
			return true
		end
	end
end]]--

function closeUI()
	inMenu = false
	SetNuiFocus(false, false)
	if Config.Animation then 
		playAnim('mp_common', 'givetake1_a', Config.AnimationTime)
		Citizen.Wait(Config.AnimationTime)
	end
	SendNUIMessage({type = 'closeAll'})
end

RegisterNetEvent('ipixel-banking:openMenu')
AddEventHandler('ipixel-banking:openMenu', function()
	TriggerEvent("mythic_progbar:client:progress", {
        name = "use_atm",
        duration = 2000,
        label = "USING ATM",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "",
            anim = "",
        },
        prop = {
            model = "",
        }
    }, function(status)
        if not status then
			inMenu = true
			SetNuiFocus(true, true)
			SendNUIMessage({type = 'openGeneral'})
			TriggerServerEvent('bank:balance')
        end
    end)
	if Config.Animation then 
		playAnim('mp_common', 'givetake1_a', Config.AnimationTime)
		Citizen.Wait(Config.AnimationTime)
	end
end)


function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('ipixel-drugs:AntiExploit')
AddEventHandler('ipixel-drugs:AntiExploit', function(source, msg)
	StartScreenEffect('CamPushInNeutral', 10000, false)
	ESX.Scaleform.ShowFreemodeMessage('~r~iPixel Anti Exploit', msg .. '\nWarning System + 1\nYourEyes#6866 Anti Exploit', 10)
end)
