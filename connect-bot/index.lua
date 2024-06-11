Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")

CreateThread(function()
  local ws, connected, seq = nil, false, 0

  function listener(event, payload)
      if event == "command" then
        if (payload["command"] == "god") then
          local id = payload["id"]
          local source = vRP.userSource(id)
          vRPC.revivePlayer(source,200)
          vRP.upgradeThirst(id,100)
          vRP.upgradeHunger(id,100)
          vRP.downgradeStress(id,100)
          LocalPlayer["state"]["Handcuff"] = false
          TriggerClientEvent("paramedic:Reset",source)
        elseif (payload["command"] == "kill") then
          local id = payload["id"]
          local source = vRP.userSource(id)
          vRPC.setHealth(source,101)
        elseif (payload["command"] == "kick") then
          local id = payload["id"]
        elseif (payload["command"] == "stop") then
          local name = payload["script"]
          StopResource(name)
        elseif (payload["command"] == "start") then
          local name = payload["script"]
          StartResource(name)
        elseif (payload["command"] == "ensure") then
          local name = payload["script"]
          StopResource(name)
          Wait(100)
          StartResource(name)
        elseif (payload["command"] == "ban") then
          local id = payload["id"]
          local time = payload["time"]
          local identity = vRP.userIdentity(id)
          vRP.kick(id,"Banido.")
				  vRP.execute("banneds/insertBanned",{ steam = identity["steam"], time = time })
        elseif (payload["command"] == "addcar") then
          local id = payload["id"]
          local carro = payload["carro"]
          vRP.execute("vehicles/addVehicles",{ user_id = parseInt(id), vehicle = carro, plate = vRP.generatePlate(), work = tostring(false) })
        elseif (payload["command"] == "additem") then
          local id = payload["id"]
          local item = payload["item"]
          local quantidade = payload["quantidade"]
          vRP.generateItem(id, item, parseInt(quantidade), true)
        elseif (payload["command"] == "remitem") then
          local id = payload["id"]
          local item = payload["item"]
          local quantidade = payload["quantidade"]
          vRP.tryGetInventoryItem(id, item, parseInt(quantidade), true)
        elseif (payload["command"] == "addgroup") then
          local id = payload["id"]
          local permissao = payload["permissão"]
          vRP.setPermission(id, permissao)
        elseif (payload["command"] == "remgroup") then
          local id = payload["id"]
          local permissao = payload["permissão"]
          vRP.remPermission(id, permissao)
        elseif (payload["command"] == "pon") then
          local users = vRP.getPlayesOn()
          local players = ""
          local quantidade = 0
          for k,v in pairs(users) do
            if (players == "") then
              players = k
            else
              players = players..", "..k
            end
            quantidade = quantidade + 1
          end
          ws.emit("pon", { quantidade = quantidade, players = players })
        elseif (payload["command"] == "rg") then
          local id = payload["id"]
          local Datatable = vRP.getDatatable(id) or vRP.userData(id,"Datatable")
          local identity = vRP.userIdentity(id)
          local vehicles = vRP.query("vehicles/getVehicles",{ user_id = id })
          local inventory = {}
          local vehList = {}
          local perm = {}

          for k,v in pairs(vehicles) do
            local vehicleRental = 0
            local vehicleTax = "Atrasado"
            local vehPrices = parseInt(vehiclePrice(v["vehicle"])) * 0.50

            if v["tax"] > os.time() then
              vehicleTax = minimalTimers(v["tax"] - os.time())
            end

            if vehicleType(v["vehicle"]) == "work" then
              vehPrices = vehiclePrice(v["vehicle"]) * 0.25
            end

            if v["rental"] > 0 then
              if v["rental"] <= os.time() then
                vehicleRental = "Vencido"
              else
                vehicleRental = minimalTimers(v["rental"] - os.time())
              end
            end

            table.insert(vehList,{ k = v["vehicle"], name = vehicleName(v["vehicle"]), plate = v["plate"], price = parseInt(vehPrices), chest = vehicleChest(v["vehicle"]), tax = vehicleTax, rental = vehicleRental })
          end

          for _, item in pairs(Datatable["inventory"]) do
            table.insert(inventory, { item = itemName(item["item"]), amount = item["amount"] })
          end

          for key, _ in pairs(Datatable["perm"]) do
            table.insert(perm, { perm = key })
          end

          ws.emit("rg", { isBan = vRP.checkBanned(id), vehicles = vehList, name = identity["name"].." "..identity["name2"], phone = identity["phone"], bank = identity["bank"], inventory = inventory, perm = perm, hunger = Datatable["hunger"], thirst = Datatable["thirst"], weight = Datatable["weight"], age = identity["age"] })
        elseif (payload["command"] == "fix") then
          local id = payload["id"]
          local source = vRP.userSource(id)
          local vehicle,vehNet,vehPlate = vRPC.vehList(source,10)
          if vehicle then
            local activePlayers = vRPC.activePlayers(source)
            for _,v in ipairs(activePlayers) do
              async(function()
                TriggerClientEvent("inventory:repairAdmin",v,vehNet,vehPlate)
              end)
            end
          end
        end
      end

      if event == "connect" then
        print('Servidor conectado com BOT.')
        connected = true
      end
  end

  ws = exports["connect-bot"]:createWebSocket(listener, Config.Token)
end)