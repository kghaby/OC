local component = require("component")
local computer = require("computer")
local GPU = component.gpu
local ME = component.me_interface
local refreshtime=5 --s
local item_table={}
local i=nil
local old_size=nil


local stats_fh = io.open("stats.dat","w")
--stats_fh:write('Name        Old Amount      New Amount\n')

lastUpdate = computer.uptime() 
local initial=true

while true do
    if initial == true then
        
        local total_types=#ME.getItemsInNetwork()
        local item_iter=ME.allItems()
        for i = 1, total_types, 1 do
            i=item_iter()
            name=i.label
            new_size=i.size
            item_table[name]={new_size, new_size, new_size - new_size}
            if name == 'Plastic Circuit Board' then
                stats_fh:write(name, '       ', new_size, '       ', new_size, '       ', new_size - new_size,'\n')
            end
        end
        initial=false
        print("Initialized")
    end
    if computer.uptime() - lastUpdate > refreshtime then
        print("Refreshed")
        lastUpdate = computer.uptime()
        local total_types=#ME.getItemsInNetwork()
        local item_iter=ME.allItems()
        --iterate through items
        for i = 1, total_types, 1 do
            i=item_iter()
            name=i.label
            new_size=i.size
            old_size=item_table[name][2]
            item_table[name]={old_size, new_size, new_size - old_size}
            if name == 'Plastic Circuit Board' then
                stats_fh:write(name, '       ', old_size, '       ', new_size, '       ', new_size - old_size,'\n')
            end
        end
     end
    print(computer.uptime() - lastUpdate)
    os.sleep(1)
 end
    

--get stats (from file)
--max dx all time
--max dx all time
--min d2x all time 
--min d2x all time
--max quant

