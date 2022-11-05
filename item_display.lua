local component = require("component")
local transforms = require("transforms")
local computer = require("computer")
local GPU = component.gpu
local ME = component.me_interface
local refreshtime=5 --s
local item_table={}
local i=""
local old_size=0


local stats_fh = io.open("stats.dat","w")
--stats_fh:write('Name        Old Amount      New Amount\n')

local last_update = computer.uptime() 
local initial=true

while true do
    if initial == true then
        
        local total_types=#ME.getItemsInNetwork()
        local item_iter=ME.allItems()
        for n = 1, total_types, 1 do
            local i=item_iter()
            local name=i.label
            local new_size=i.size
            local item_table[name]={old=new_size, new=new_size, dif=0}
            if name == 'Plastic Circuit Board' then
                stats_fh:write(name, '       ', new_size, '       ', new_size, '       ', 0,'\n')
            end
        end
        initial=false
        print("Initialized")
    end
    if computer.uptime() - last_update > refreshtime then
        print("Refreshed")
        local last_update = computer.uptime()
        local total_types=#ME.getItemsInNetwork()
        local item_iter=ME.allItems()
        --iterate through items
        for n = 1, total_types, 1 do
            local i=item_iter()
            local name=i.label
            local new_size=i.size
            local old_size=item_table[name].old
            local dif=new_size - old_size
            local item_table[name]={old=old_size, new=new_size, dif=dif}
            if name == 'Plastic Circuit Board' then
                stats_fh:write(name, '       ', old_size, '       ', new_size, '       ', new_size - old_size,'\n')
            end
        end
     end
    print(computer.uptime() - last_update)
    os.sleep(1)
 end
    

--get stats (from file)
--max dx all time
--max dx all time
--min d2x all time 
--min d2x all time
--max quant

