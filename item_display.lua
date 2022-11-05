
local GPU = component.gpu
local ME = component.me_interface
local refreshtime=5 --s
local item_table={}


local stats_fh = io.open("stats.dat","w")
--stats_fh:write('Name        Old Amount      New Amount\n')

lastUpdate = computer.uptime() 
local initial=true

while true do
    if initial == true then
        
        local total_types=#ME.getItemsInNetwork()
        local item_iter=ME.allItems()
        for i = 1, total_types, 1 do
            local i=item_iter()
            print(type(i.size))
            item_table[i.label]={i.size, i.size, i.size - i.size}
            if i.label == 'Plastic Circuit Board' then
                stats_fh:write(i.label, '       ', i.size, '       ', i.size, '       ', i.size - i.size,'\n')
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
            local i=item_iter()
            local old_size=item_table[i.label][2]
            item_table[i.label]={old_size, i.size, i.size - old_size}
            if i.label == 'Plastic Circuit Board' then
                stats_fh:write(i.label, '       ', old_size, '       ', i.size, '       ', i.size - old_size,'\n')
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

