-- RideAPet Free V4 | Egg Travel | Key: UltraSaven
local P=game:GetService('Players');local UIS=game:GetService('UserInputService');local RS=game:GetService('RunService');local VU=game:GetService('VirtualUser');local GS=game:GetService('GuiService');local SS=game:GetService('StarterGui')
local LP=P.LocalPlayer;local KEY='UltraSaven';local Cam=workspace.CurrentCamera;local originalGravity=workspace.Gravity
local S={esp=false,inf=false,noclip=false,fly=false,sprint=false,afk=false,flySpeed=50,eggSpeed=100,walk=16,jump=50,gravity=196.2,egg='',eggESP=false,travelBusy=false,spawn=nil,hidden=false,dead=false,notify=true,travelToken=0}
local cons={};local pageCons={}
local function C(x,f)local c=x:Connect(f);cons[#cons+1]=c;return c end
local function PC(x,f)local c=x:Connect(f);pageCons[#pageCons+1]=c;return c end
local function clearPageConnections()for i=#pageCons,1,-1 do pcall(function()pageCons[i]:Disconnect()end);pageCons[i]=nil end end
local function disconnectAll()for i=#cons,1,-1 do pcall(function()cons[i]:Disconnect()end);cons[i]=nil end end
local function N(t,m)if not S.notify then return end pcall(function()SS:SetCore('SendNotification',{Title=t,Text=m,Duration=3})end)end
local function root(p)local c=p and p.Character;return c and c:FindFirstChild('HumanoidRootPart')end
local function hum(p)local c=p and p.Character;return c and c:FindFirstChildOfClass('Humanoid')end
local function alive(p)local h=hum(p);return h and h.Health>0 end

-- GUI helpers
local G=Instance.new('ScreenGui');G.Name='RideAPet';G.ResetOnSpawn=false;G.IgnoreGuiInset=true;G.Parent=LP:WaitForChild('PlayerGui')
local function cr(o,r)local x=Instance.new('UICorner');x.CornerRadius=UDim.new(0,r or 8);x.Parent=o end
local function st(o,t)local x=Instance.new('UIStroke');x.Color=Color3.new(1,1,1);x.Transparency=t or .6;x.Thickness=1;x.Parent=o end
local function btn(par,text,size)local b=Instance.new('TextButton');b.Size=size or UDim2.new(1,0,0,34);b.BackgroundColor3=Color3.fromRGB(14,18,26);b.Text=text;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamMedium;b.TextSize=12;b.AutoButtonColor=true;b.Parent=par;cr(b);st(b);return b end
local function lab(par,text,size)local l=Instance.new('TextLabel');l.BackgroundTransparency=1;l.Size=size or UDim2.new(1,0,0,24);l.Text=text;l.TextColor3=Color3.new(1,1,1);l.Font=Enum.Font.GothamMedium;l.TextSize=12;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=par;return l end
local function toggle(par,text,v,fn)local b=btn(par,text,UDim2.new(1,-6,0,32));local on=v;local function draw()b.Text=text..'  ['..(on and'ON'or'OFF')..']' end;draw();PC(b.Activated,function()on=not on;draw();fn(on)end);return b end

-- Key UI
local key=Instance.new('Frame');key.AnchorPoint=Vector2.new(.5,.5);key.Position=UDim2.fromScale(.5,.5);key.Size=UDim2.new(0,320,0,270);key.BackgroundColor3=Color3.fromRGB(8,10,15);key.Parent=G;cr(key,14);st(key,.1)
local kscale=Instance.new('UIScale');kscale.Parent=key
local function fitKey()
 local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900,600)
 kscale.Scale=math.clamp(math.min(v.X/360,v.Y/300),0.78,1)
end
fitKey();if workspace.CurrentCamera then C(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),fitKey)end
local kt=lab(key,'RIDE A PET • FREE',UDim2.new(1,-40,0,35));kt.Position=UDim2.fromOffset(20,18);kt.Font=Enum.Font.GothamBold;kt.TextSize=21
local kb=Instance.new('TextBox');kb.Position=UDim2.fromOffset(20,68);kb.Size=UDim2.new(1,-40,0,42);kb.BackgroundColor3=Color3.fromRGB(18,22,30);kb.TextColor3=Color3.new(1,1,1);kb.PlaceholderText='Enter key...';kb.ClearTextOnFocus=false;kb.Font=Enum.Font.Gotham;kb.TextSize=13;kb.Parent=key;cr(kb);st(kb)
local kc=btn(key,'CHECK KEY',UDim2.new(1,-40,0,40));kc.Position=UDim2.fromOffset(20,120);kc.BackgroundColor3=Color3.new(1,1,1);kc.TextColor3=Color3.new(0,0,0)
local ks=lab(key,'Key required',UDim2.new(1,-40,0,22));ks.Position=UDim2.fromOffset(20,168);ks.TextColor3=Color3.fromRGB(170,170,170)
local wa=btn(key,'JOIN CHANNEL',UDim2.new(1,-40,0,32));wa.Position=UDim2.fromOffset(20,215);wa.TextSize=11
local WURL='https://whatsapp.com/channel/0029VbCQPwEGZNCoWjErZk3a';C(wa.Activated,function()local ok=false;pcall(function()GS:OpenBrowserWindow(WURL);ok=true end);if not ok then pcall(function()if setclipboard then setclipboard(WURL)end end);N('WhatsApp','Link copied.')end end)

-- Main UI
local M=Instance.new('Frame');M.AnchorPoint=Vector2.new(.5,.5);M.Position=UDim2.fromScale(.5,.5);M.Size=UDim2.fromOffset(570,370);M.ClipsDescendants=true;M.BackgroundColor3=Color3.fromRGB(7,10,16);M.Visible=false;M.Parent=G;cr(M,14);st(M,.1)
local mscale=Instance.new('UIScale');mscale.Parent=M
local function fitUI()
 local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900,600)
 local base=math.min(v.X/570,v.Y/370)
 mscale.Scale=math.clamp(base,0.72,1)
end
fitUI();if workspace.CurrentCamera then C(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),fitUI)end
local top=Instance.new('Frame');top.Size=UDim2.new(1,0,0,48);top.BackgroundColor3=Color3.fromRGB(14,17,24);top.Parent=M;cr(top,12)
local title=lab(top,'S  RIDE A PET',UDim2.new(1,-150,1,0));title.Position=UDim2.fromOffset(16,0);title.Font=Enum.Font.GothamBold;title.TextSize=16
local ver=lab(top,'FREE V4',UDim2.fromOffset(90,24));ver.Position=UDim2.new(1,-190,.5,-12);ver.TextXAlignment=Enum.TextXAlignment.Right
local hide=btn(top,'—',UDim2.fromOffset(34,30));hide.Position=UDim2.new(1,-44,.5,-15)
local side=Instance.new('Frame');side.Position=UDim2.fromOffset(7,56);side.Size=UDim2.fromOffset(125,300);side.BackgroundColor3=Color3.fromRGB(10,14,21);side.Parent=M;cr(side,10)
local sl=Instance.new('UIListLayout');sl.Padding=UDim.new(0,3);sl.Parent=side
local pad=Instance.new('UIPadding');pad.PaddingTop=UDim.new(0,6);pad.PaddingLeft=UDim.new(0,6);pad.PaddingRight=UDim.new(0,6);pad.Parent=side
local cont=Instance.new('ScrollingFrame');cont.Position=UDim2.fromOffset(138,56);cont.Size=UDim2.new(1,-145,1,-62);cont.BackgroundColor3=Color3.fromRGB(10,14,21);cont.BorderSizePixel=0;cont.ScrollBarThickness=4;cont.Parent=M;cr(cont,10)
local cp=Instance.new('UIPadding');cp.PaddingTop=UDim.new(0,12);cp.PaddingBottom=UDim.new(0,12);cp.PaddingLeft=UDim.new(0,12);cp.PaddingRight=UDim.new(0,12);cp.Parent=cont
local cl=Instance.new('UIListLayout');cl.Padding=UDim.new(0,7);cl.Parent=cont
C(cl:GetPropertyChangedSignal('AbsoluteContentSize'),function()cont.CanvasSize=UDim2.fromOffset(0,cl.AbsoluteContentSize.Y+25)end)
local reopen=btn(G,'S',UDim2.fromOffset(54,54));reopen.AnchorPoint=Vector2.new(.5,.5);reopen.Position=UDim2.fromScale(.5,.5);reopen.TextSize=24;reopen.Visible=false;cr(reopen,27)
local drag=function(o,h)local d=false;local s,p;local moved=false;C(h.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;s=i.Position;p=o.Position;moved=false end end);C(UIS.InputChanged,function(i)if d and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local q=i.Position-s;if q.Magnitude>5 then moved=true end;o.Position=UDim2.new(p.X.Scale,p.X.Offset+q.X,p.Y.Scale,p.Y.Offset+q.Y)end end);C(UIS.InputEnded,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end);return function()local x=moved;moved=false;return x end end
local reopenMoved=drag(reopen,reopen);drag(M,top)
local tabs={'Dashboard','ESP','Movement','Egg Travel','Settings'};local tb={}
local function clear()clearPageConnections();for _,x in ipairs(cont:GetChildren())do if not x:IsA('UIListLayout')and not x:IsA('UIPadding')then x:Destroy()end end end
local function feature(t,d,f)local b=btn(cont,'',UDim2.new(1,-4,0,50));local a=lab(b,t,UDim2.new(1,-18,0,21));a.Position=UDim2.fromOffset(10,4);a.Font=Enum.Font.GothamBold;local z=lab(b,d or'',UDim2.new(1,-18,0,18));z.Position=UDim2.fromOffset(10,25);z.TextSize=10;z.TextColor3=Color3.fromRGB(150,150,150);PC(b.Activated,f);return b end
local function section(t)local x=lab(cont,t:upper(),UDim2.new(1,0,0,22));x.Font=Enum.Font.GothamBold;x.TextSize=10 end

-- Advanced Egg ESP only
local ee={};local eggTags={};local eggClock=0
local EGG_RANGE=500
local function norm(x)return tostring(x or''):lower():gsub('[%s%-%_]','')end
local function part(x)if x:IsA('BasePart')then return x end;if x:IsA('Model')then return x.PrimaryPart or x:FindFirstChildWhichIsA('BasePart',true)end end
local function eggMatch(x)
 if not x or not x:IsDescendantOf(workspace) then return false end
 if not x:IsA('Model') and not x:IsA('BasePart') then return false end
 local n=norm(x.Name);if n=='' then return false end
 local q=norm(S.egg)
 if q~='' then return n==q or n:find(q,1,true)~=nil end
 if n:find('egg',1,true) then return true end
 return false
end
local function findEgg(q)
 q=tostring(q or ''):gsub('^%s+',''):gsub('%s+$','')
 if q=='' then return nil end
 local nq=norm(q)
 local best=nil;local bestD=math.huge;local my=root(LP)
 for _,x in ipairs(workspace:GetDescendants()) do
  if (x:IsA('Model') or x:IsA('BasePart')) and eggMatch(x) then
   local n=norm(x.Name)
   if n==nq or n:find(nq,1,true) then
    local p=part(x);local d=my and p and (p.Position-my.Position).Magnitude or math.huge
    if d<=EGG_RANGE and (not best or (n==nq and norm(best.Name)~=nq) or (n==nq and d<bestD) or (norm(best.Name)~=nq and d<bestD)) then best=x;bestD=d end
   end
  end
 end
 return best
end
local function clrEgg(x)
 if ee[x]then pcall(function()ee[x]:Destroy()end);ee[x]=nil end
 if eggTags[x]then pcall(function()eggTags[x]:Destroy()end);eggTags[x]=nil end
end
local function makeEggTag(x,p)
 local old=eggTags[x];if old and old.Parent==p then return old end
 if old then pcall(function()old:Destroy()end)end
 local bb=Instance.new('BillboardGui');bb.Name='RideAPetEggInfo';bb.Adornee=p;bb.AlwaysOnTop=true;bb.Size=UDim2.fromOffset(190,58);bb.StudsOffset=Vector3.new(0,3,0);bb.MaxDistance=EGG_RANGE;bb.Parent=p
 local n=Instance.new('TextLabel');n.Name='Name';n.BackgroundTransparency=1;n.Size=UDim2.new(1,0,0,20);n.Text=x.Name;n.TextColor3=Color3.fromRGB(255,225,70);n.TextStrokeTransparency=.25;n.Font=Enum.Font.GothamBold;n.TextSize=12;n.Parent=bb
 local i=Instance.new('TextLabel');i.Name='Info';i.BackgroundTransparency=1;i.Position=UDim2.fromOffset(0,19);i.Size=UDim2.new(1,0,0,17);i.TextColor3=Color3.new(1,1,1);i.TextStrokeTransparency=.35;i.Font=Enum.Font.GothamMedium;i.TextSize=10;i.Parent=bb
 local q=Instance.new('TextLabel');q.Name='Prompt';q.BackgroundTransparency=1;q.Position=UDim2.fromOffset(0,36);q.Size=UDim2.new(1,0,0,17);q.TextColor3=Color3.fromRGB(160,220,255);q.TextStrokeTransparency=.4;q.Font=Enum.Font.Gotham;q.TextSize=9;q.Parent=bb
 eggTags[x]=bb;return bb
end
local function eggESP(x)
 if not S.eggESP or not eggMatch(x) then return end
 local p=part(x);if not p then return end
 -- Avoid double-marking a child part when its parent model is already an egg.
 if x:IsA('BasePart') then
  local m=x:FindFirstAncestorOfClass('Model')
  if m and eggMatch(m) then return end
 end
 local my=root(LP)
 if not my or (p.Position-my.Position).Magnitude>EGG_RANGE then
  clrEgg(x)
  return
 end
 if ee[x] and ee[x].Parent then makeEggTag(x,p);return end
 clrEgg(x)
 local h=Instance.new('Highlight');h.Name='RideAPetEggESP';h.Adornee=x;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.FillTransparency=.38;h.OutlineTransparency=.05;h.FillColor=Color3.fromRGB(255,190,35);h.OutlineColor=Color3.fromRGB(255,245,120);h.Parent=x;ee[x]=h
 makeEggTag(x,p)
end
local function refreshEggESP()
 for x in pairs(ee)do clrEgg(x)end
 for x in pairs(eggTags)do clrEgg(x)end
 if not S.eggESP then return end
 for _,x in ipairs(workspace:GetDescendants())do eggESP(x)end
end
local function updateEggESP()
 if not S.eggESP then return end
 local my=root(LP);if not my then return end
 for x,h in pairs(ee)do
  local p=part(x);local tag=eggTags[x]
  if not x.Parent or not p or not eggMatch(x) then clrEgg(x) else
   local d=(p.Position-my.Position).Magnitude
   local visible=d<=EGG_RANGE
   h.Enabled=visible
   if tag then
    tag.Enabled=visible
    local info=tag:FindFirstChild('Info');if info then info.Text=string.format('%dm  •  %s',math.floor(d+.5),d<=35 and 'NEAR' or 'FOUND')end
    local prompt=tag:FindFirstChild('Prompt')
    if prompt then
     local ready=false
     for _,z in ipairs(x:GetDescendants())do if z:IsA('ProximityPrompt') and z.Enabled then ready=true;break end end
     prompt.Text=ready and '● INTERACTABLE' or '● EGG'
     prompt.TextColor3=ready and Color3.fromRGB(90,255,150) or Color3.fromRGB(160,220,255)
    end
   end
  end
 end
end
C(RS.Heartbeat,function(dt)eggClock+=dt;if eggClock>=.3 then eggClock=0;updateEggESP()end end)
C(workspace.DescendantAdded,function(x)if S.eggESP then task.defer(function()eggESP(x)end)end end)
C(workspace.DescendantRemoving,function(x)clrEgg(x)end)

-- Movement declared before UI callbacks
local noclipParts={};local function noclip(on)local c=LP.Character;if not c then return end;if on then for _,x in ipairs(c:GetDescendants())do if x:IsA('BasePart')then if noclipParts[x]==nil then noclipParts[x]=x.CanCollide end;x.CanCollide=false end end else for x,v in pairs(noclipParts)do if x and x.Parent then x.CanCollide=v end end;table.clear(noclipParts)end end
local function applyMove()local h=hum(LP);if not h then return end;h.WalkSpeed=math.max(0,S.sprint and S.walk*1.35 or S.walk);h.JumpPower=math.max(0,S.jump)end
local flyVel;local function stopFly()if flyVel then pcall(function()flyVel:Destroy()end);flyVel=nil end end
local function toggleFly(v)S.fly=not not v;if not S.fly then stopFly()end end

local function stopTravel()
 S.travelToken+=1;S.travelBusy=false
 local r=root(LP);if r then r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end
end
local function flyToPosition(destination,label,onArrive,target)
 if S.travelBusy then N('Egg Travel','A flight is already running');return false end
 local r=root(LP);if not r or not alive(LP) then N('Egg Travel','Character not ready');return false end
 if typeof(destination)~='Vector3' then return false end
 S.fly=false;stopFly()
 local start=r.Position
 local maxTime=math.clamp((destination-start).Magnitude/math.max(S.eggSpeed,40)+8,10,45)
 S.travelBusy=true;S.travelToken+=1;local token=S.travelToken
 task.spawn(function()
  local ok=false
  local v=Instance.new('BodyVelocity');v.Name='RideAPetTravelVelocity';v.MaxForce=Vector3.new(1e6,1e6,1e6);v.P=25000;v.Parent=r
  local started=os.clock()
  while S.travelBusy and S.travelToken==token and not S.dead and os.clock()-started<maxTime do
   r=root(LP);if not r or not alive(LP) then break end
   if target and target.Parent then
    local tp=part(target);if tp then destination=tp.Position+Vector3.new(0,4,0) end
   end
   local d=destination-r.Position
   if d.Magnitude<=6 then ok=true;break end
   v.Velocity=d.Unit*math.min(S.eggSpeed,math.max(40,d.Magnitude*2.5))
   RS.Heartbeat:Wait()
  end
  pcall(function()v:Destroy()end)
  if S.travelToken==token then S.travelBusy=false end
  r=root(LP);if r then r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end
  if ok then if onArrive then pcall(onArrive,r)end;N('Egg Travel',label or 'Arrived') elseif not S.dead and S.travelToken==token then N('Egg Travel','Flight stopped or timed out')end
 end)
 return true
end

local function show(tab)
 S.tab=tab;clear()
 if tab=='Dashboard'then section('Overview');feature('Players','Server count',function()N('Players',#P:GetPlayers())end);feature('Egg Travel','Fly to selected egg or return to spawn',function()N('Egg Travel','Use the Egg Travel tab')end)
 elseif tab=='ESP'then section('Advanced Egg ESP');toggle(cont,'ESP Egg',S.eggESP,function(v)S.eggESP=v;refreshEggESP()end);feature('Egg ESP Mode','All eggs when name filter is empty',function()N('Egg ESP','Leave egg name empty to detect all eggs')end);feature('ESP Range','Maximum: 500 studs',function()N('Egg ESP','Updates every 0.3 seconds for performance')end);feature('Refresh Egg ESP','Rescan all egg objects',function()refreshEggESP()end);feature('Clear Egg ESP','Remove all egg highlights',function()for x in pairs(ee)do clrEgg(x)end;for x in pairs(eggTags)do clrEgg(x)end end)
 elseif tab=='Movement'then section('Movement');feature('WalkSpeed','Current: '..S.walk,function()local a={16,24,32,50,75,100};local i=table.find(a,S.walk)or 1;S.walk=a[i%#a+1];applyMove()end);feature('JumpPower','Current: '..S.jump,function()local a={50,75,100,150};local i=table.find(a,S.jump)or 1;S.jump=a[i%#a+1];applyMove()end);toggle(cont,'Infinite Jump',S.inf,function(v)S.inf=v end);toggle(cont,'Noclip',S.noclip,function(v)S.noclip=v;if not v then noclip(false)end end);toggle(cont,'Fly',S.fly,function(v)toggleFly(v)end);feature('Fly Speed','Current: '..S.flySpeed,function()local a={25,50,100,200,400,800};local i=table.find(a,S.flySpeed)or 1;S.flySpeed=a[i%#a+1]end);toggle(cont,'Sprint',S.sprint,function(v)S.sprint=v;applyMove()end);feature('Gravity','Current: '..S.gravity,function()local a={196.2,150,100,50,0};local i=table.find(a,S.gravity)or 1;S.gravity=a[i%#a+1];workspace.Gravity=S.gravity end);feature('Reset Movement','Restore defaults',function()S.walk=16;S.jump=50;S.gravity=196.2;S.sprint=false;S.fly=false;S.noclip=false;workspace.Gravity=originalGravity;stopFly();noclip(false);applyMove()end)
 elseif tab=='Egg Travel'then section('Egg Travel');local box=Instance.new('TextBox');box.Size=UDim2.new(1,-4,0,38);box.BackgroundColor3=Color3.fromRGB(14,18,26);box.TextColor3=Color3.new(1,1,1);box.PlaceholderText='Egg name, e.g. Gorilla Egg';box.Text=S.egg;box.Font=Enum.Font.Gotham;box.TextSize=12;box.Parent=cont;cr(box);st(box);PC(box.FocusLost,function()S.egg=box.Text:gsub('^%s+',''):gsub('%s+$','');refreshEggESP()end);feature('Selected Egg','Target: '..(S.egg~='' and S.egg or 'type an egg name'),function()N('Egg Target',S.egg~='' and S.egg or 'Please enter an egg name')end);feature('Take to Egg','Fly to the selected egg',function()local e=findEgg(S.egg);local pp=e and part(e);local r=root(LP);if not pp or not r then N('Egg Travel','Egg tidak ditemui dalam jarak 500 studs');return end;S.spawn=S.spawn or r.CFrame;local startName=e.Name;flyToPosition(pp.Position+Vector3.new(0,4,0),'Arrived at '..startName,function()end,e)end);feature('Take Back to Spawn','Fly back to the last saved spawn',function()local dest=S.spawn;if not dest then N('Egg Travel','No spawn point saved');return end;if S.travelBusy then stopTravel();task.wait() end;flyToPosition(dest.Position+Vector3.new(0,2,0),'Returned to last spawn',function(r)if r then r.CFrame=dest;r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end end)end);feature('Stop Travel','Stop the current egg/base flight',function()if S.travelBusy then stopTravel();N('Egg Travel','Stopped')else N('Egg Travel','No flight running')end end);feature('Save Spawn','Save current position as the return base',function()local r=root(LP);if r then S.spawn=r.CFrame;N('Spawn','Spawn point saved')end end);feature('Clear Egg','Clear egg selection',function()S.egg='';box.Text='';refreshEggESP()end)
 elseif tab=='Settings'then section('Settings');toggle(cont,'Anti AFK',S.afk,function(v)S.afk=v end);toggle(cont,'Notifications',S.notify,function(v)S.notify=v end);feature('Hide GUI','Show reopen button',function()M.Visible=false;reopen.Visible=true;S.hidden=true end);feature('Reset UI','Center interface',function()M.Position=UDim2.fromScale(.5,.5)end);feature('Destroy','Remove UI',function()S.dead=true;S.travelToken+=1;S.travelBusy=false;S.fly=false;S.noclip=false;workspace.Gravity=originalGravity;stopFly();noclip(false);for x in pairs(ee)do clrEgg(x)end;for x in pairs(eggTags)do clrEgg(x)end;clearPageConnections();disconnectAll();if G then G:Destroy()end end)
 end
end
for _,n in ipairs(tabs)do local b=btn(side,n,UDim2.new(1,0,0,31));tb[n]=b;C(b.Activated,function()show(n)end)end
C(hide.Activated,function()M.Visible=false;reopen.Visible=true;S.hidden=true end);C(reopen.Activated,function()if reopenMoved()then return end;M.Visible=true;reopen.Visible=false;S.hidden=false end)
C(kc.Activated,function()local x=kb.Text:gsub('^%s+',''):gsub('%s+$','');if x==KEY then ks.Text='✓ Key valid';ks.TextColor3=Color3.fromRGB(70,220,145);task.wait(.2);key.Visible=false;M.Visible=true;show('Dashboard')else ks.Text='✕ Invalid key';ks.TextColor3=Color3.fromRGB(255,70,70);task.wait(.2);LP:Kick('Ride a Pet: Invalid Key')end end)
C(UIS.JumpRequest,function()if S.inf then local h=hum(LP);if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end end)
C(RS.RenderStepped,function()if S.dead then return end;if S.fly then local r=root(LP);local c=workspace.CurrentCamera;if r and c then if not flyVel or flyVel.Parent~=r then stopFly();flyVel=Instance.new('BodyVelocity');flyVel.MaxForce=Vector3.new(1e5,1e5,1e5);flyVel.P=15000;flyVel.Parent=r end;local m=Vector3.zero;if UIS:IsKeyDown(Enum.KeyCode.W)then m+=c.LookVector end;if UIS:IsKeyDown(Enum.KeyCode.S)then m-=c.LookVector end;if UIS:IsKeyDown(Enum.KeyCode.A)then m-=c.RightVector end;if UIS:IsKeyDown(Enum.KeyCode.D)then m+=c.RightVector end;if m.Magnitude==0 then local h=hum(LP);if h and h.MoveDirection.Magnitude>0 then m=h.MoveDirection end end;if UIS:IsKeyDown(Enum.KeyCode.Space)then m+=Vector3.yAxis end;if UIS:IsKeyDown(Enum.KeyCode.LeftControl)then m-=Vector3.yAxis end;flyVel.Velocity=m.Magnitude>0 and m.Unit*S.flySpeed or Vector3.zero end else stopFly()end;end)
C(LP.Idled,function()if S.afk then pcall(function()VU:Button2Down(Vector2.zero,Cam.CFrame);task.wait(.1);VU:Button2Up(Vector2.zero,Cam.CFrame)end)end end)

C(LP.CharacterRemoving,function()S.travelToken+=1;S.travelBusy=false;stopFly();noclip(false)end);C(LP.CharacterAdded,function()task.wait(.25);if S.dead then return end;local r=root(LP);if r and not S.travelBusy then S.spawn=r.CFrame end;applyMove();if S.noclip then noclip(true) end;end);C(LP.CharacterAdded,function(c)C(c.DescendantAdded,function(x)if S.noclip and x:IsA('BasePart') then if noclipParts[x]==nil then noclipParts[x]=x.CanCollide end;x.CanCollide=false end end)end)
local r=root(LP);if r then S.spawn=r.CFrame end;show('Dashboard')
