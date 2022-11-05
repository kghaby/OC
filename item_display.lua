
local GPU = component.gpu
local ME = component.me_interface
local refreshtime=60 --s


local stats_fh = io.open("stats.dat","w")
stats_fh.write('Name\t\t\tOld Amount\t\t\tNew Amount\n')

local lastUpdate = Computer.uptime() 
local old_size=-1
--iterate through items 
if computer.uptime() - lastUpdate > refreshtime then
    local lastUpdate = computer.uptime()
    local total_types=#ME.getItemsInNetwork()
    local item_iter=ME.allItems()
    for i = 1, total_types, 1 do
        local i=item_iter()
        stats_fh.write(i.label,'\t\t\t',old_size,'\t\t\t',i.size,'\n')
    end
 end
    

--get stats (from file)
--max dx all time
--max dx all time
--min d2x all time 
--min d2x all time
--max quant

