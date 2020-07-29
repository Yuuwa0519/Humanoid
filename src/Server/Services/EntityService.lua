-- Entity Service
-- Yuuwa0519
-- July 28, 2020

--Service 
local CollectionService = game:GetService("CollectionService")

--Var
local EntityDatas = {
    --[[
        {
            Name = "";
            Id = "";
            Actor = Model; --Server Object
            Clothing = Model; --Client Object 
            Anim = {
                Walk = "";
                Jump = "";
            }
        }
    ]]
}

local CEvents = {

}

local EntityIds = -10000

--Setting 
local Entity_CollectionTag = "CharacterEntityObject"

local EntityService = {Client = {}}

--Handle the Animation Request, and Replicate to Everyone Else
function EntityService:AddData(Obj, CObj, Anim)
    --Get Unique EntityId
    local thisId = EntityIds 
    EntityIds += 1

    local thisEntity = {
        Id = thisId;
        Actor = Obj;
        Clothing = CObj;
        AnimationArray = Anim;
    }

    EntityDatas[thisId] = thisEntity

    Obj.AncestryChanged:Connect(function(parent) 
        if (parent == nil) then
            self:RemoveData(thisId)
        end
    end )

    CollectionService:AddTag(Obj, Entity_CollectionTag)

    return thisId
end

function EntityService:RemoveData(Id)
    local thisEntity = EntityDatas[Id]

    if (thisEntity) then
        if (thisEntity.Actor) then 
            thisEntity.Actor:Destroy()
        end 

        EntityDatas[Id] = EntityDatas[#EntityDatas]
        EntityDatas[#EntityDatas] = nil 
    end 
end 

function EntityService:DownloadEntity(plr, Obj)
    local EntityId
    for Id, entityData in pairs(EntityDatas) do
        if (entityData.Actor == Obj) then 
            EntityId = Id 
            break 
        end 
    end 

    if (EntityId) then 
        return EntityDatas[EntityId]
    else 
        warn(Obj:GetFullName())
    end 
end 

function EntityService.Client:DownloadEntity(...)
    return self.Server:DownloadEntity(...)
end 

function EntityService:Start()

end 

function EntityService:Init()
    for _, name in pairs(CEvents) do 
        self:RegisterClientEvent(name)
    end 
end


return EntityService