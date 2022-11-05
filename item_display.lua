local component = require("component")
local transforms = require("transforms")
local computer = require("computer")
local GPU = component.gpu
local ME = component.me_interface
local refreshtime=1 --s
local item_table={}
local i=""



local stats_fh = io.open("stats.dat","w")
--stats_fh:write('Name        Old Amount      New Amount\n')

local last_update = computer.uptime() 
local initial=true

while true do
    if computer.uptime() - last_update > refreshtime or initial then
        print("Refreshed")
        local last_update = computer.uptime()
        local total_types=#ME.getItemsInNetwork()
        local item_iter=ME.allItems()
        --iterate through items
        for n = 1, total_types, 1 do
            i=item_iter()
            local name=i.label
            local new_size=i.size
            if item_table[name] then
                --get old x from last cycle
                if item_table[name].size then
                    old_size=item_table[name].size
                else
                    old_size=new_size
                end
                local new_dsize=new_size - old_size
                --get old dx from last cycle
                if item_table[name].dsize then
                    old_dsize=item_table[name].dsize
                else
                    old_dsize=new_dsize
                end
                local d2size=new_dsize - old_dsize
            else
                local new_dsize=0
                local d2size=0
            end
            item_table[name]={size=new_size, dsize=new_dsize, d2size=d2size}
            if name == 'Plastic Circuit Board' then
                stats_fh:write(name, size, dsize, new_dsize, d2size'\n')
            end
            item_table[name].old=new_size
            
        end
        initial=false
     end
    print(computer.uptime() - last_update)
    os.sleep(refreshtime)
 end
    

--get stats (from file)
--max dx all time
--max dx all time
--min d2x all time 
--min d2x all time
--max quant

