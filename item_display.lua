local component = require("component")
local transforms = require("transforms")
local computer = require("computer")
local GPU = component.gpu
local ME = component.me_interface
local refreshtime=1 --s
local item_table={}
local i=""
local name=""
local id = ""
local damage=""
local new_size=0
local new_dsize=0
local d2size=0




local stats_fh = io.open("stats.dat","w")
--stats_fh:write('Name        Old Amount      New Amount\n')

local last_update = computer.uptime() 
local initial=true

while true do
    if computer.uptime() - last_update > refreshtime or initial then
        print("Refreshing")
        local last_update = computer.uptime()
        local total_types=#ME.getItemsInNetwork()
        local item_iter=ME.allItems()
        --iterate through items
        for n = 1, total_types, 1 do
            i=item_iter()
            if not i then
                break
            end
            name=i.label
            damage=i.damage
            id=name..'('..damage..')'
            new_size=i.size
            if item_table[id] then
                --get old x from last cycle
                if item_table[id].size then
                    old_size=item_table[id].size
                else
                    old_size=new_size
                end
                new_dsize=new_size - old_size
                --get old dx from last cycle
                if item_table[id].dsize then
                    old_dsize=item_table[id].dsize
                else
                    old_dsize=new_dsize
                end
                d2size=new_dsize - old_dsize
            else
                new_dsize=0
                d2size=0
            end
            item_table[id]={size=new_size, dsize=new_dsize, d2size=d2size}
            --if id == 'Plastic Circuit Board(32106)' then
            --    stats_fh:write(id,'       ', new_size,'       ', new_dsize,'       ', d2size,'\n')
            --end
            
        end
        initial=false
     end
--    print(computer.uptime() - last_update)
    os.sleep(refreshtime)
 end
    

--get stats (from file)
--max dx all time
--max dx all time
--min d2x all time 
--min d2x all time
--max quant

