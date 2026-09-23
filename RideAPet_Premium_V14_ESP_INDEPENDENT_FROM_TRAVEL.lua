-- RideAPet Premium V14 | No Key | V7-style Egg ESP Independent from Travel
-- No combat / no aim / no auto-egg pickup
local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local RS=game:GetService('RunService')
local VU=game:GetService('VirtualUser')
local SG=game:GetService('StarterGui')
local LP=Players.LocalPlayer
local PG=LP:WaitForChild('PlayerGui')
local originalGravity=workspace.Gravity

local S={
 egg='',eggESP=false,eggRange=500,eggSpeed=120,travel=false,travelToken=0,spawn=nil,
 fly=false,flySpeed=60,noclip=false,infJump=false,sprint=false,walk=16,jump=50,
 gravity=originalGravity,afk=false,notify=true,dead=false,hidden=false
}
local connections={}
local function conn(signal,fn,t)
 local c=signal:Connect(fn);table.insert(t or connections,c);return c
end
local function disconnect(t)
 for i=#t,1,-1 do pcall(function()t[i]:Disconnect()end);t[i]=nil end
end
local pageConnections={};local charConnections={};local cameraConnections={}
local function pageConn(s,f)return conn(s,f,pageConnections)end
local function charConn(s,f)return conn(s,f,charConnections)end
local function notify(title,msg)
 if not S.notify then return end
 pcall(function()SG:SetCore('SendNotification',{Title=title,Text=msg,Duration=3})end)
end
local function character()return LP.Character end
local function root()
 local c=character();return c and c:FindFirstChild('HumanoidRootPart')
end
local function humanoid()
 local c=character();return c and c:FindFirstChildOfClass('Humanoid')
end
local function alive()
 local h=humanoid();return h and h.Health>0
end

-- GUI
local old=PG:FindFirstChild('RideAPet');if old then pcall(function()old:Destroy()end)end
local G=Instance.new('ScreenGui');G.Name='RideAPet';G.ResetOnSpawn=false;G.IgnoreGuiInset=true;G.Parent=PG
local function corner(o,r)local c=Instance.new('UICorner');c.CornerRadius=UDim.new(0,r or 8);c.Parent=o end
local function stroke(o,t)local s=Instance.new('UIStroke');s.Color=Color3.new(1,1,1);s.Transparency=t or .65;s.Thickness=1;s.Parent=o end
local function label(p,text,size)
 local l=Instance.new('TextLabel');l.BackgroundTransparency=1;l.Text=text;l.TextColor3=Color3.new(1,1,1);l.Font=Enum.Font.GothamMedium;l.TextSize=12;l.TextXAlignment=Enum.TextXAlignment.Left;l.Size=size or UDim2.new(1,0,0,24);l.Parent=p;return l
end
local function button(p,text,size)
 local b=Instance.new('TextButton');b.Size=size or UDim2.new(1,0,0,34);b.BackgroundColor3=Color3.fromRGB(14,18,26);b.Text=text;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamMedium;b.TextSize=12;b.AutoButtonColor=true;b.Parent=p;corner(b,8);stroke(b,.65);return b
end
local content
local function clearPage()
 disconnect(pageConnections)
 for _,x in ipairs(content:GetChildren())do
  if not x:IsA('UIListLayout') and not x:IsA('UIPadding') then x:Destroy()end
 end
end

local main=Instance.new('Frame');main.Name='Main';main.AnchorPoint=Vector2.new(.5,.5);main.Position=UDim2.fromScale(.5,.5);main.Size=UDim2.fromOffset(600,390);main.BackgroundColor3=Color3.fromRGB(7,10,16);main.Parent=G;corner(main,14);stroke(main,.1)
local scale=Instance.new('UIScale');scale.Parent=main
local function fit()
 local cam=workspace.CurrentCamera;local v=cam and cam.ViewportSize or Vector2.new(900,600)
 scale.Scale=math.clamp(math.min(v.X/600,v.Y/390),.68,1)
end
fit()
conn(main.AncestryChanged,function(_,parent)if not parent then S.dead=true end end)
local function bindCamera(c)
 disconnect(cameraConnections)
 if c then table.insert(cameraConnections,c:GetPropertyChangedSignal('ViewportSize'):Connect(fit)) end
 task.defer(fit)
end
conn(workspace:GetPropertyChangedSignal('CurrentCamera'),function()bindCamera(workspace.CurrentCamera)end)
bindCamera(workspace.CurrentCamera)

local top=Instance.new('Frame');top.Size=UDim2.new(1,0,0,50);top.BackgroundColor3=Color3.fromRGB(14,17,24);top.Parent=main;corner(top,12)
local title=label(top,'RIDE A PET  •  PREMIUM V12',UDim2.new(1,-180,1,0));title.Position=UDim2.fromOffset(16,0);title.Font=Enum.Font.GothamBold;title.TextSize=16
local status=label(top,'READY',UDim2.fromOffset(110,24));status.Position=UDim2.new(1,-150,.5,-12);status.TextXAlignment=Enum.TextXAlignment.Right;status.TextColor3=Color3.fromRGB(110,255,170)
local hide=button(top,'—',UDim2.fromOffset(34,30));hide.Position=UDim2.new(1,-44,.5,-15)
local side=Instance.new('Frame');side.Position=UDim2.fromOffset(7,57);side.Size=UDim2.fromOffset(132,326);side.BackgroundColor3=Color3.fromRGB(10,14,21);side.Parent=main;corner(side,10)
local sl=Instance.new('UIListLayout');sl.Padding=UDim.new(0,4);sl.Parent=side
local sp=Instance.new('UIPadding');sp.PaddingTop=UDim.new(0,7);sp.PaddingLeft=UDim.new(0,7);sp.PaddingRight=UDim.new(0,7);sp.Parent=side
content=Instance.new('ScrollingFrame');content.Position=UDim2.fromOffset(146,57);content.Size=UDim2.new(1,-153,1,-64);content.BackgroundColor3=Color3.fromRGB(10,14,21);content.BorderSizePixel=0;content.ScrollBarThickness=4;content.CanvasSize=UDim2.new();content.Parent=main;corner(content,10)
local cp=Instance.new('UIPadding');cp.PaddingTop=UDim.new(0,12);cp.PaddingBottom=UDim.new(0,12);cp.PaddingLeft=UDim.new(0,12);cp.PaddingRight=UDim.new(0,12);cp.Parent=content
local cl=Instance.new('UIListLayout');cl.Padding=UDim.new(0,7);cl.Parent=content
conn(cl:GetPropertyChangedSignal('AbsoluteContentSize'),function()content.CanvasSize=UDim2.fromOffset(0,cl.AbsoluteContentSize.Y+25)end)

local reopen=button(G,'S',UDim2.fromOffset(54,54));reopen.AnchorPoint=Vector2.new(.5,.5);reopen.Position=UDim2.fromScale(.5,.5);reopen.TextSize=23;reopen.Visible=false;corner(reopen,27)
local function draggable(obj,handle)
 local dragging=false;local start;local origin
 conn(handle.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;start=i.Position;origin=obj.Position end end)
 conn(UIS.InputChanged,function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-start;obj.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y)end end)
 conn(UIS.InputEnded,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end
draggable(main,top);draggable(reopen,reopen)

local function section(text)local l=label(content,text:upper(),UDim2.new(1,0,0,22));l.Font=Enum.Font.GothamBold;l.TextSize=10;l.TextColor3=Color3.fromRGB(180,190,205)end
local function action(text,desc,fn)
 local b=button(content,'',UDim2.new(1,-4,0,51));local a=label(b,text,UDim2.new(1,-18,0,22));a.Position=UDim2.fromOffset(10,4);a.Font=Enum.Font.GothamBold;local d=label(b,desc or'',UDim2.new(1,-18,0,18));d.Position=UDim2.fromOffset(10,26);d.TextSize=10;d.TextColor3=Color3.fromRGB(150,155,165);pageConn(b.Activated,fn);return b
end
local function toggle(text,value,fn)
 local on=value;local b=button(content,'',UDim2.new(1,-4,0,34));local function draw()b.Text=text..'   ['..(on and 'ON' or 'OFF')..']' end;draw();pageConn(b.Activated,function()on=not on;draw();fn(on)end);return b
end
local tabs={'Dashboard','Egg ESP','Egg Travel','Movement','Utilities','Settings'}

-- Egg ESP (independent from Egg Travel target; selecting a target never filters ESP)
local highlights={};local tags={};local trackedEggs={};local MIN_EGG_DISTANCE=500;local ESP_TAG_DISTANCE=10000;local espTimer=0
local function normalize(v)return tostring(v or ''):lower():gsub('[%s%-%_]','')end
local function objectPart(x)
 if x:IsA('BasePart') then return x end
 if x:IsA('Model') then return x.PrimaryPart or x:FindFirstChildWhichIsA('BasePart',true) end
end
local function isEgg(x)
 if not x or not x:IsDescendantOf(workspace) then return false end
 if not x:IsA('Model') and not x:IsA('BasePart') then return false end
 local n=normalize(x.Name);if n=='' then return false end
 return n:find('egg',1,true)~=nil
end
local function clearEgg(x)
 if highlights[x] then pcall(function()highlights[x]:Destroy()end);highlights[x]=nil end
 if tags[x] then pcall(function()tags[x]:Destroy()end);tags[x]=nil end
end
local function clearAllEggESP()
 for x in pairs(highlights)do clearEgg(x)end
 for x in pairs(tags)do clearEgg(x)end
end
local function createTag(x,p)
 if tags[x] and tags[x].Parent==p then return tags[x] end
 if tags[x] then pcall(function()tags[x]:Destroy()end)end
 local bb=Instance.new('BillboardGui');bb.Name='RideAPetEggESP';bb.Adornee=p;bb.AlwaysOnTop=true;bb.Size=UDim2.fromOffset(190,58);bb.StudsOffset=Vector3.new(0,3.2,0);bb.MaxDistance=ESP_TAG_DISTANCE;bb.Parent=p
 local n=Instance.new('TextLabel');n.BackgroundTransparency=1;n.Size=UDim2.new(1,0,0,20);n.Text=x.Name;n.TextColor3=Color3.fromRGB(255,225,70);n.TextStrokeTransparency=.2;n.Font=Enum.Font.GothamBold;n.TextSize=12;n.Name='EggName'
 n.Parent=bb
 local i=Instance.new('TextLabel');i.BackgroundTransparency=1;i.Position=UDim2.fromOffset(0,19);i.Size=UDim2.new(1,0,0,18);i.TextColor3=Color3.new(1,1,1);i.TextStrokeTransparency=.3;i.Font=Enum.Font.GothamMedium;i.TextSize=10;i.Name='EggInfo'
 i.Parent=bb
 local q=Instance.new('TextLabel');q.BackgroundTransparency=1;q.Position=UDim2.fromOffset(0,37);q.Size=UDim2.new(1,0,0,17);q.TextStrokeTransparency=.35;q.Font=Enum.Font.GothamMedium;q.TextSize=9;q.Name='EggState'
 q.Parent=bb
 tags[x]=bb;return bb
end
local function markEgg(x)
 if not S.eggESP or not isEgg(x) then return end
 local p=objectPart(x);local r=root();if not p or not r then return end
 if x:IsA('BasePart') then local m=x:FindFirstAncestorOfClass('Model');if m and isEgg(m) then return end end
 local d=(p.Position-r.Position).Magnitude
 if d<=MIN_EGG_DISTANCE then clearEgg(x);return end
 local h=highlights[x]
 if not h or not h.Parent then
  h=Instance.new('Highlight');h.Name='RideAPetEggHighlight';h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.FillColor=Color3.fromRGB(255,205,40);h.FillTransparency=.72;h.OutlineColor=Color3.new(1,1,1);h.OutlineTransparency=.05;h.Adornee=x;h.Parent=x;highlights[x]=h
 end
 local tag=createTag(x,p);tag.Enabled=true
 local second=tag:FindFirstChild('EggInfo')
 local third=tag:FindFirstChild('EggState')
 if second then second.Text=string.format('%d studs  •  %s',math.floor(d+.5),d<=35 and 'NEAR' or 'READY') end
 local ready=false
 for _,z in ipairs(x:GetDescendants())do if z:IsA('ProximityPrompt') and z.Enabled then ready=true;break end end
 if third then third.Text=ready and '● INTERACTABLE' or '● EGG';third.TextColor3=ready and Color3.fromRGB(90,255,150) or Color3.fromRGB(160,220,255) end
end
local function refreshESP()
 if not S.eggESP then clearAllEggESP();return end
 clearAllEggESP()
 table.clear(trackedEggs)
 for _,x in ipairs(workspace:GetDescendants())do
  if isEgg(x) then trackedEggs[x]=true;markEgg(x)end
 end
end
conn(workspace.DescendantAdded,function(x)
 if isEgg(x) then trackedEggs[x]=true end
 if S.eggESP then task.defer(function()markEgg(x)end)end
end)
conn(workspace.DescendantRemoving,function(x)
 trackedEggs[x]=nil
 clearEgg(x)
end)
conn(RS.Heartbeat,function(dt)
 if not S.eggESP then return end
 espTimer+=dt;if espTimer<.3 then return end;espTimer=0
 for x in pairs(trackedEggs)do
  if x and x.Parent and x:IsDescendantOf(workspace) and isEgg(x) then
   markEgg(x)
  else
   trackedEggs[x]=nil;clearEgg(x)
  end
 end
end)

-- Movement / travel
local savedCollision={};local flyVelocity=nil;local travelVelocity=nil
local function applyMovement()
 local h=humanoid();if not h then return end
 h.WalkSpeed=math.max(0,S.sprint and S.walk*1.35 or S.walk)
 h.JumpPower=math.max(0,S.jump)
end
local function setNoclip(v)
 S.noclip=v
 if not v then
  for p,oldValue in pairs(savedCollision)do if p and p.Parent then p.CanCollide=oldValue end end
  table.clear(savedCollision);return
 end
 local c=character();if not c then return end
 for _,p in ipairs(c:GetDescendants())do if p:IsA('BasePart')then if savedCollision[p]==nil then savedCollision[p]=p.CanCollide end;p.CanCollide=false end end
end
local function stopFly()
 if flyVelocity then pcall(function()flyVelocity:Destroy()end);flyVelocity=nil end
end
local function stopTravelVelocity()
 if travelVelocity then pcall(function()travelVelocity:Destroy()end);travelVelocity=nil end
end
local function setEggTravelSpeed(v)
 S.eggSpeed=math.clamp(math.floor(tonumber(v) or S.eggSpeed),25,1000)
end
local function stopTravel(message)
 S.travelToken+=1;S.travel=false
 stopTravelVelocity()
 local r=root();if r then r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end
 if message then notify('Egg Travel',message)end
end
local function flyTo(destination,target)
 if S.travel then notify('Egg Travel','A flight is already running');return false end
 if not alive() then notify('Egg Travel','Character is not ready');return false end
 local r=root()
 if not r or typeof(destination)~='Vector3' then return false end
 stopFly();stopTravelVelocity()
 S.fly=false;S.travel=true;S.travelToken+=1
 local token=S.travelToken
 local maxTime=math.clamp((destination-r.Position).Magnitude/math.max(S.eggSpeed,40)+10,10,50)
 task.spawn(function()
  local bv=Instance.new('BodyVelocity')
  travelVelocity=bv
  bv.Name='RideAPetTravel'
  bv.MaxForce=Vector3.new(1e6,1e6,1e6)
  bv.P=30000
  bv.Parent=r
  local started=os.clock();local arrived=false
  while S.travel and token==S.travelToken and alive() and os.clock()-started<maxTime do
   r=root()
   if not r then break end
   if target and target.Parent then
    local p=objectPart(target)
    if p then destination=p.Position+Vector3.new(0,4,0) end
   end
   local delta=destination-r.Position
   local dist=delta.Magnitude
   if dist<=6 then arrived=true;break end
   bv.Velocity=delta.Unit*math.min(S.eggSpeed,math.max(45,dist*2.2))
   RS.Heartbeat:Wait()
  end
  if travelVelocity==bv then travelVelocity=nil end
  pcall(function()bv:Destroy()end)
  local valid=(token==S.travelToken)
  if valid then S.travel=false end
  r=root()
  if r and valid then r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end
  if valid and arrived then notify('Egg Travel','Arrived') elseif valid and not S.dead then notify('Egg Travel','Flight ended') end
  if valid and S.eggESP then task.defer(refreshESP) end
 end)
 return true
end

local function findNearestEgg(query)
 local r=root();if not r or tostring(query or '')=='' then return nil end
 local q=normalize(query);local best,bestScore,bestDistance=nil,math.huge,math.huge
 for _,x in ipairs(workspace:GetDescendants())do
  if isEgg(x) then
   local p=objectPart(x)
   if p then
    local d=(p.Position-r.Position).Magnitude
    if d>MIN_EGG_DISTANCE then
     local n=normalize(x.Name);local score=(n==q and 0 or n:find(q,1,true) and 1 or 99)
     if score<bestScore or(score==bestScore and d<bestDistance)then best=x;bestScore=score;bestDistance=d end
    end
   end
  end
 end
 return best
end

-- Utility features (ESP V7 block above intentionally unchanged)
local U={fullBright=false,noFog=false,antiVoid=false,sit=false,platform=false,freeze=false,autoSpawn=false,waterWalk=false,fov=70,hip=2}
local savedLighting={Brightness=game:GetService('Lighting').Brightness,ClockTime=game:GetService('Lighting').ClockTime,FogStart=game:GetService('Lighting').FogStart,FogEnd=game:GetService('Lighting').FogEnd,GlobalShadows=game:GetService('Lighting').GlobalShadows}
local function applyUtility()
 local L=game:GetService('Lighting')
 if U.fullBright then L.Brightness=2;L.ClockTime=14;L.GlobalShadows=false else L.Brightness=savedLighting.Brightness;L.ClockTime=savedLighting.ClockTime;L.GlobalShadows=savedLighting.GlobalShadows end
 if U.noFog then L.FogStart=1e6;L.FogEnd=1e6 else L.FogStart=savedLighting.FogStart;L.FogEnd=savedLighting.FogEnd end
 local h=humanoid()
 if h then h.Sit=U.sit;h.PlatformStand=U.platform;h.HipHeight=math.clamp(U.hip,0,10) end
 if U.freeze then local r=root();if r then r.Anchored=true end end
 local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=math.clamp(U.fov,40,120) end
end
local function setFreeze(v)
 U.freeze=v;local r=root();if r then r.Anchored=v end
end
local function resetUtility()
 U.fullBright=false;U.noFog=false;U.antiVoid=false;U.sit=false;U.platform=false;U.freeze=false;U.autoSpawn=false;U.waterWalk=false;U.fov=70;U.hip=2
 local r=root();if r then r.Anchored=false end
 applyUtility()
end
conn(RS.Heartbeat,function()
 if S.dead then return end
 applyUtility()
 if U.antiVoid then
  local r=root();if r and r.Position.Y < -80 then
   local dest=S.spawn
   if dest then r.CFrame=dest+Vector3.new(0,4,0);r.AssemblyLinearVelocity=Vector3.zero end
  end
 end
 if U.waterWalk then
  local h=humanoid();if h and h:GetState()==Enum.HumanoidStateType.Swimming then h:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
end)

-- Tabs
local tabButtons={}
local function show(tab)
 clearPage()
 if tab=='Dashboard' then
  section('Premium Dashboard')
  action('Egg Travel','Fly to an egg beyond 500 studs and return to spawn',function()notify('Egg Travel','Open Egg Travel to start')end)
  action('Egg ESP','Advanced egg-only ESP • 500+ stud range',function()notify('Egg ESP',S.eggESP and 'Enabled' or 'Disabled')end)
  action('Current Status',S.travel and 'TRAVELLING' or (S.fly and 'FLYING' or 'READY'),function()end)
  action('Premium','No key system • no combat features',function()notify('RideAPet Premium','Ready')end)
 elseif tab=='Egg ESP' then
  section('Advanced Egg ESP')
  toggle('ESP Egg',S.eggESP,function(v)S.eggESP=v;if v then refreshESP()else clearAllEggESP()end end)
  action('Range','Minimum distance: 500 studs',function()notify('Egg ESP','Only eggs beyond 500 studs are detected')end)
  action('Refresh','Rescan eggs now',function()refreshESP()end)
  action('Clear','Remove all ESP objects',function()clearAllEggESP()end)
 elseif tab=='Egg Travel' then
  section('Egg Target')
  local box=Instance.new('TextBox');box.Size=UDim2.new(1,-4,0,38);box.BackgroundColor3=Color3.fromRGB(14,18,26);box.TextColor3=Color3.new(1,1,1);box.PlaceholderText='Egg name e.g. Gorilla Egg';box.Text=S.egg;box.Font=Enum.Font.Gotham;box.TextSize=12;box.ClearTextOnFocus=false;box.Parent=content;corner(box);stroke(box);pageConn(box.FocusLost,function()S.egg=box.Text:gsub('^%s+',''):gsub('%s+$','')end)
  action('Target','Selected: '..(S.egg~='' and S.egg or 'not selected'),function()notify('Egg Target',S.egg~='' and S.egg or 'Enter an egg name')end)
  action('Take to Egg','Fly to selected egg • must be beyond 500 studs',function()
   local e=findNearestEgg(S.egg);local p=e and objectPart(e);local r=root()
   if not p or not r then notify('Egg Travel','No matching egg beyond 500 studs');return end
   if not S.spawn then S.spawn=r.CFrame end
   flyTo(p.Position+Vector3.new(0,4,0),e)
  end)
  action('Take Back to Spawn','Fly to the latest saved spawn',function()
   if not S.spawn then notify('Egg Travel','No spawn saved');return end
   if S.travel then stopTravel() end
   if not S.dead then flyTo(S.spawn.Position+Vector3.new(0,2,0),nil) end
  end)
  local speedBox=Instance.new('TextBox');speedBox.Size=UDim2.new(1,-4,0,38);speedBox.BackgroundColor3=Color3.fromRGB(14,18,26);speedBox.TextColor3=Color3.new(1,1,1);speedBox.PlaceholderText='Travel speed: 25 - 1000';speedBox.Text=tostring(S.eggSpeed);speedBox.Font=Enum.Font.Gotham;speedBox.TextSize=12;speedBox.ClearTextOnFocus=false;speedBox.Parent=content;corner(speedBox);stroke(speedBox)
  pageConn(speedBox.FocusLost,function()
   local n=tonumber(speedBox.Text)
   if not n then speedBox.Text=tostring(S.eggSpeed);notify('Travel Speed','Enter a number from 25 to 1000');return end
   setEggTravelSpeed(n);speedBox.Text=tostring(S.eggSpeed);notify('Travel Speed',tostring(S.eggSpeed)..' studs/s')
  end)
  action('Travel Speed Preset','Current: '..S.eggSpeed..' studs/s • tap for next preset',function()
   local a={50,75,100,150,200,300,400,500,650,800,1000}
   local i=table.find(a,S.eggSpeed) or 1
   setEggTravelSpeed(a[i%#a+1])
   speedBox.Text=tostring(S.eggSpeed)
   notify('Travel Speed',tostring(S.eggSpeed)..' studs/s')
  end)
  action('Stop Travel','Immediately stop current flight',function()if S.travel then stopTravel('Stopped')else notify('Egg Travel','No active flight')end end)
  action('Save Spawn','Save your current position',function()local r=root();if r then S.spawn=r.CFrame;notify('Spawn','Saved')end end)
  action('Clear Target','Remove egg name filter',function()S.egg='';box.Text='' end)
 elseif tab=='Movement' then
  section('Movement')
  action('WalkSpeed','Current: '..S.walk,function()local a={16,24,32,50,75,100};local i=table.find(a,S.walk)or 1;S.walk=a[i%#a+1];applyMovement()end)
  action('JumpPower','Current: '..S.jump,function()local a={50,75,100,150,200};local i=table.find(a,S.jump)or 1;S.jump=a[i%#a+1];applyMovement()end)
  toggle('Infinite Jump',S.infJump,function(v)S.infJump=v end)
  toggle('Noclip',S.noclip,function(v)setNoclip(v)end)
  toggle('Fly',S.fly,function(v)if v and S.travel then notify('Fly','Stop Egg Travel first');return end;S.fly=v;if not v then stopFly()end end)
  action('Fly Speed','Current: '..S.flySpeed,function()local a={25,50,75,100,150,250,400,600};local i=table.find(a,S.flySpeed)or 1;S.flySpeed=a[i%#a+1]end)
  toggle('Sprint',S.sprint,function(v)S.sprint=v;applyMovement()end)
  action('Gravity','Current: '..math.floor(S.gravity),function()local a={originalGravity,150,100,75,50,25,0};local i=1;for n,v in ipairs(a)do if v==S.gravity then i=n break end end;S.gravity=a[i%#a+1];workspace.Gravity=S.gravity end)
  action('Reset Movement','Restore movement defaults',function()S.walk=16;S.jump=50;S.flySpeed=60;S.sprint=false;S.fly=false;setNoclip(false);S.gravity=originalGravity;workspace.Gravity=originalGravity;stopFly();if S.travel then stopTravel() end;applyMovement();task.defer(function()if not S.dead then show('Movement')end end)end)
 elseif tab=='Utilities' then
  section('Utilities • 11 Features')
  toggle('1. FullBright',U.fullBright,function(v)U.fullBright=v;applyUtility()end)
  toggle('2. No Fog',U.noFog,function(v)U.noFog=v;applyUtility()end)
  toggle('3. Anti Void',U.antiVoid,function(v)U.antiVoid=v end)
  toggle('4. Sit',U.sit,function(v)U.sit=v;applyUtility()end)
  toggle('5. Platform Stand',U.platform,function(v)U.platform=v;applyUtility()end)
  toggle('6. Freeze Character',U.freeze,function(v)setFreeze(v)end)
  toggle('7. Auto Save Spawn',U.autoSpawn,function(v)U.autoSpawn=v end)
  toggle('8. Water Assist',U.waterWalk,function(v)U.waterWalk=v end)
  action('9. Camera FOV','Current: '..U.fov,function()
   local a={50,60,70,80,90,100,110,120};local i=table.find(a,U.fov) or 3;U.fov=a[i%#a+1];applyUtility();notify('FOV',tostring(U.fov))
  end)
  action('10. Hip Height','Current: '..U.hip,function()
   local a={2,2.5,3,4,5,6};local i=table.find(a,U.hip) or 1;U.hip=a[i%#a+1];applyUtility();notify('Hip Height',tostring(U.hip))
  end)
  action('11. Reset Character','Reset your current character',function()
   local h=humanoid();if h then h.Health=0 end
  end)
  action('Reset Utilities','Restore utility settings and lighting',function()resetUtility();task.defer(function()if not S.dead then show('Utilities')end end)end)
 elseif tab=='Settings' then
  section('Interface')
  toggle('Anti AFK',S.afk,function(v)S.afk=v end)
  toggle('Notifications',S.notify,function(v)S.notify=v end)
  action('Hide GUI','Show floating reopen button',function()main.Visible=false;reopen.Visible=true;S.hidden=true end)
  action('Center GUI','Return main UI to center',function()main.Position=UDim2.fromScale(.5,.5)end)
  action('Destroy','Remove RideAPet and restore states',function()
   S.dead=true;S.travelToken+=1;S.travel=false;S.fly=false;setNoclip(false);stopTravelVelocity();stopFly();clearAllEggESP();resetUtility();workspace.Gravity=originalGravity;disconnect(pageConnections);disconnect(charConnections);disconnect(cameraConnections);disconnect(connections);if G then G:Destroy()end
  end)
 end
end

for _,name in ipairs(tabs)do local b=button(side,name,UDim2.new(1,0,0,34));tabButtons[name]=b;conn(b.Activated,function()show(name)end)end
conn(hide.Activated,function()main.Visible=false;reopen.Visible=true;S.hidden=true end)
conn(reopen.Activated,function()main.Visible=true;reopen.Visible=false;S.hidden=false end)
conn(UIS.JumpRequest,function()if S.infJump and alive()then local h=humanoid();if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end end)
conn(RS.RenderStepped,function()
 if S.dead then return end
 if S.fly and not S.travel then
  local r=root();local cam=workspace.CurrentCamera
  if r and cam then
   if not flyVelocity or flyVelocity.Parent~=r then stopFly();flyVelocity=Instance.new('BodyVelocity');flyVelocity.Name='RideAPetFly';flyVelocity.MaxForce=Vector3.new(1e5,1e5,1e5);flyVelocity.P=15000;flyVelocity.Parent=r end
   local m=Vector3.zero
   if UIS:IsKeyDown(Enum.KeyCode.W)then m+=cam.LookVector end
   if UIS:IsKeyDown(Enum.KeyCode.S)then m-=cam.LookVector end
   if UIS:IsKeyDown(Enum.KeyCode.A)then m-=cam.RightVector end
   if UIS:IsKeyDown(Enum.KeyCode.D)then m+=cam.RightVector end
   if UIS:IsKeyDown(Enum.KeyCode.Space)then m+=Vector3.yAxis end
   if UIS:IsKeyDown(Enum.KeyCode.LeftControl)then m-=Vector3.yAxis end
   if m.Magnitude==0 then local h=humanoid();if h and h.MoveDirection.Magnitude>0 then m=h.MoveDirection end end
   flyVelocity.Velocity=m.Magnitude>0 and m.Unit*S.flySpeed or Vector3.zero
  end
 else stopFly()end
end)
conn(LP.Idled,function()
 if not S.afk then return end
 pcall(function()local cam=workspace.CurrentCamera;local cf=cam and cam.CFrame or CFrame.new();VU:Button2Down(Vector2.zero,cf);task.wait(.1);VU:Button2Up(Vector2.zero,cf)end)
end)
conn(LP.CharacterRemoving,function()S.travelToken+=1;S.travel=false;S.fly=false;stopTravelVelocity();stopFly();setNoclip(false);disconnect(charConnections)end)
conn(LP.CharacterAdded,function(c)
 if S.dead then return end
 disconnect(charConnections)
 table.clear(savedCollision)
 charConn(c.DescendantAdded,function(x)if S.noclip and x:IsA('BasePart')then if savedCollision[x]==nil then savedCollision[x]=x.CanCollide end;x.CanCollide=false end end)
 task.defer(function()task.wait(.3);if S.dead or LP.Character~=c then return end;local r=root();if r and not S.travel then S.spawn=r.CFrame end;if U.autoSpawn and r then S.spawn=r.CFrame end;applyMovement();if S.noclip then setNoclip(true)end;if S.eggESP then refreshESP()end end)
end)

local r=root();if r then S.spawn=r.CFrame end
show('Dashboard')
