local function GetPoints(pos,pt, max_distance)
    local dr=0.1 -- verification step
    local dx=pt.x-pos.x
    local dz=pt.z-pos.z
    local angle=math.atan2(dz,dx)
    local angle_perp=math.atan2(dx,dz)
    local cangle=math.cos(angle)
    local sangle=math.sin(angle)
    local ntries=0
    local ntries_max=3/dr
    local px, pz
    
    px=pos.x    
    pz=pos.z
    ntries=0
    while TheWorld.Map:IsPassableAtPoint(px, 0, pz, false) do
        px=px+cangle*dr
        pz=pz+sangle*dr
        ntries=ntries+1
        if ntries > ntries_max then
            return
        end
    end
    local ipoint_x=px-5*cangle*dr
    local ipoint_z=pz-5*sangle*dr
    
    px=pt.x
    pz=pt.z
    ntries=0
    while TheWorld.Map:IsPassableAtPoint(px, 0, pz, false) do
        px=px-cangle*dr
        pz=pz-sangle*dr
        ntries=ntries+1
        if ntries > ntries_max then
            return
        end
    end
    local fpoint_x=px+5*cangle*dr
    local fpoint_z=pz+5*sangle*dr
    
    dx=fpoint_x-ipoint_x
    dz=fpoint_z-ipoint_z
    
    local dist=math.sqrt(dx*dx+dz*dz)
    
    local n_boards=math.ceil(dist/max_distance)
    
    if n_boards < 3 then
        return
    end
    
    dr=dist/(n_boards-1)
    
    local boards={}
    
    px=ipoint_x
    pz=ipoint_z
    table.insert(boards,{px,pz})
    for i=2,n_boards do
        px=px+dr*cangle
        pz=pz+dr*sangle
        table.insert(boards,{px,pz})
    end
    
    return boards, angle, angle_perp

end

return GetPoints
