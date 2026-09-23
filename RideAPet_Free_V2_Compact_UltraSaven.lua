-- RideAPet Free V2 | compact build | Key: UltraSaven
local P=game:GetService('Players');local UIS=game:GetService('UserInputService');local RS=game:GetService('RunService');local VU=game:GetService('VirtualUser');local GS=game:GetService('GuiService');local SS=game:GetService('StarterGui')
local LP=P.LocalPlayer;local KEY='UltraSaven';local Cam=workspace.CurrentCamera
local S={role='Auto',esp=false,aim=false,lock=false,vis=true,autoRetarget=true,inf=false,noclip=false,fly=false,sprint=false,afk=false,flySpeed=50,eggSpeed=100,walk=16,jump=50,gravity=196.2,egg='',eggBusy=false,spawn=nil,hidden=false,dead=false,notify=true}
local cons={};local function C(x,f)local c=x:Connect(f);cons[#cons+1]=c;return c end
local function N(t,m)if not S.notify then return end pcall(function()SS:SetCore('SendNotification',{Title=t,Text=m,Duration=3})end)end
local function root(p)local c=p and p.Character;return c and c:FindFirstChild('HumanoidRootPart')end
local function hum(p)local c=p and p.Character;return c and c:FindFirstChildOfClass('Humanoid')end
local function alive(p)local h=hum(p);return h and h.Health>0 end
local function role(p)local r=p and p:GetAttribute('Role');if typeof(r)=='string' then r=r:lower();if r=='sherif'or r=='sheriff'then return'Sherif'end;if r=='murder'or r=='murderer'then return'Murder'end;if r=='innocent'then return'Innocent'end end;return'Unknown'end
local function allowed(p)if not p or p==LP or not alive(p)or not root(p)then return false end;local r=S.role=='Auto'and role(LP)or S.role;return r~='Sherif'or role(p)=='Murder'end
local function dist(p)local a,b=root(LP),root(p);return a and b and(a.Position-b.Position).Magnitude or math.huge end

-- GUI helpers
local G=Instance.new('ScreenGui');G.Name='RideAPet';G.ResetOnSpawn=false;G.IgnoreGuiInset=true;G.Parent=LP:WaitForChild('PlayerGui')
local function cr(o,r)local x=Instance.new('UICorner');x.CornerRadius=UDim.new(0,r or 8);x.Parent=o end
local function st(o,t)local x=Instance.new('UIStroke');x.Color=Color3.new(1,1,1);x.Transparency=t or .6;x.Thickness=1;x.Parent=o end
local function btn(par,text,size)local b=Instance.new('TextButton');b.Size=size or UDim2.new(1,0,0,34);b.BackgroundColor3=Color3.fromRGB(14,18,26);b.Text=text;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamMedium;b.TextSize=12;b.AutoButtonColor=true;b.Parent=par;cr(b);st(b);return b end
local function lab(par,text,size)local l=Instance.new('TextLabel');l.BackgroundTransparency=1;l.Size=size or UDim2.new(1,0,0,24);l.Text=text;l.TextColor3=Color3.new(1,1,1);l.Font=Enum.Font.GothamMedium;l.TextSize=12;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=par;return l end
local function toggle(par,text,v,fn)local b=btn(par,text,UDim2.new(1,-6,0,32));local on=v;local function draw()b.Text=text..'  ['..(on and'ON'or'OFF')..']' end;draw();C(b.Activated,function()on=not on;draw();fn(on)end);return b end

-- Key UI
local key=Instance.new('Frame');key.AnchorPoint=Vector2.new(.5,.5);key.Position=UDim2.fromScale(.5,.5);key.Size=UDim2.fromOffset(320,270);key.BackgroundColor3=Color3.fromRGB(8,10,15);key.Parent=G;cr(key,14);st(key,.1)
local kt=lab(key,'RIDE A PET • FREE',UDim2.new(1,-40,0,35));kt.Position=UDim2.fromOffset(20,18);kt.Font=Enum.Font.GothamBold;kt.TextSize=21
local kb=Instance.new('TextBox');kb.Position=UDim2.fromOffset(20,68);kb.Size=UDim2.new(1,-40,0,42);kb.BackgroundColor3=Color3.fromRGB(18,22,30);kb.TextColor3=Color3.new(1,1,1);kb.PlaceholderText='Enter key...';kb.ClearTextOnFocus=false;kb.Font=Enum.Font.Gotham;kb.TextSize=13;kb.Parent=key;cr(kb);st(kb)
local kc=btn(key,'CHECK KEY',UDim2.new(1,-40,0,40));kc.Position=UDim2.fromOffset(20,120);kc.BackgroundColor3=Color3.new(1,1,1);kc.TextColor3=Color3.new(0,0,0)
local ks=lab(key,'Key required',UDim2.new(1,-40,0,22));ks.Position=UDim2.fromOffset(20,168);ks.TextColor3=Color3.fromRGB(170,170,170)
local wa=btn(key,'JOIN CHANNEL',UDim2.new(1,-40,0,32));wa.Position=UDim2.fromOffset(20,215);wa.TextSize=11
local WURL='https://whatsapp.com/channel/0029VbCQPwEGZNCoWjErZk3a';C(wa.Activated,function()local ok=false;pcall(function()GS:OpenBrowserWindow(WURL);ok=true end);if not ok then pcall(function()if setclipboard then setclipboard(WURL)end end);N('WhatsApp','Link copied.')end end)

-- Main UI
local M=Instance.new('Frame');M.AnchorPoint=Vector2.new(.5,.5);M.Position=UDim2.fromScale(.5,.5);M.Size=UDim2.fromOffset(570,370);M.BackgroundColor3=Color3.fromRGB(7,10,16);M.Visible=false;M.Parent=G;cr(M,14);st(M,.1)
local top=Instance.new('Frame');top.Size=UDim2.new(1,0,0,48);top.BackgroundColor3=Color3.fromRGB(14,17,24);top.Parent=M;cr(top,12)
local title=lab(top,'S  RIDE A PET',UDim2.new(1,-150,1,0));title.Position=UDim2.fromOffset(16,0);title.Font=Enum.Font.GothamBold;title.TextSize=16
local ver=lab(top,'FREE V2',UDim2.fromOffset(90,24));ver.Position=UDim2.new(1,-190,.5,-12);ver.TextXAlignment=Enum.TextXAlignment.Right
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
local tabs={'Dashboard','Role','ESP','Aim','Movement','Auto Egg','Settings'};local tb={}
local function clear()for _,x in ipairs(cont:GetChildren())do if not x:IsA('UIListLayout')and not x:IsA('UIPadding')then x:Destroy()end end end
local function feature(t,d,f)local b=btn(cont,'',UDim2.new(1,-4,0,50));local a=lab(b,t,UDim2.new(1,-18,0,21));a.Position=UDim2.fromOffset(10,4);a.Font=Enum.Font.GothamBold;local z=lab(b,d or'',UDim2.new(1,-18,0,18));z.Position=UDim2.fromOffset(10,25);z.TextSize=10;z.TextColor3=Color3.fromRGB(150,150,150);C(b.Activated,f);return b end
local function section(t)local x=lab(cont,t:upper(),UDim2.new(1,0,0,22));x.Font=Enum.Font.GothamBold;x.TextSize=10 end

-- Player ESP
local pe={};local function clr(p)if pe[p]then pe[p]:Destroy();pe[p]=nil end end
local function esp(p)if not S.esp or not allowed(p)then clr(p);return end;local c=p.Character;if not c then return end;if pe[p]and pe[p].Parent==c then return end;clr(p);local h=Instance.new('Highlight');h.Name='RideAPetESP';h.Adornee=c;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.FillTransparency=.72;h.FillColor=role(p)=='Murder'and Color3.fromRGB(255,60,60)or Color3.fromRGB(70,180,255);h.OutlineColor=h.FillColor;h.Parent=c;pe[p]=h end
local function refreshESP()for _,p in ipairs(P:GetPlayers())do if p~=LP then esp(p)end end end
local function clearESP()for p in pairs(pe)do clr(p)end end

-- Egg search + ESP
local ee={};local function norm(x)return tostring(x or''):lower():gsub('[%s%-%_]','')end
local function part(x)if x:IsA('BasePart')then return x end;if x:IsA('Model')then return x.PrimaryPart or x:FindFirstChildWhichIsA('BasePart',true)end end
local function findEgg(q)local w=norm(q);if w==''then return end;local partial;for _,x in ipairs(workspace:GetDescendants())do if(x:IsA('Model')or x:IsA('BasePart'))then local n=norm(x.Name);if n==w then return x elseif not partial and(n:find(w,1,true)or w:find(n,1,true))then partial=x end end end;return partial end
local function clrEgg(x)if ee[x]then ee[x]:Destroy();ee[x]=nil end end
local function eggESP(x)if not x:IsA('Model')and not x:IsA('BasePart')then return end;local q=norm(S.egg);if q==''or not S.eggESP then return end;local n=norm(x.Name);if n~=q and not n:find(q,1,true)then return end;if ee[x]and ee[x].Parent then return end;local h=Instance.new('Highlight');h.Name='RideAPetEggESP';h.Adornee=x;h.FillColor=Color3.fromRGB(255,205,45);h.OutlineColor=Color3.fromRGB(255,235,100);h.FillTransparency=.45;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=x;ee[x]=h end
local function refreshEggESP()for x in pairs(ee)do clrEgg(x)end;if not S.eggESP then return end;for _,x in ipairs(workspace:GetDescendants())do eggESP(x)end end
C(workspace.DescendantAdded,function(x)if S.eggESP then task.defer(function()eggESP(x)end)end end);C(workspace.DescendantRemoving,function(x)clrEgg(x)end)

-- Movement declared before UI callbacks
local noclipParts={};local function noclip(on)local c=LP.Character;if not c then return end;if on then for _,x in ipairs(c:GetDescendants())do if x:IsA('BasePart')then if noclipParts[x]==nil then noclipParts[x]=x.CanCollide end;x.CanCollide=false end end else for x,v in pairs(noclipParts)do if x.Parent then x.CanCollide=v end end;noclipParts={} end end
local function applyMove()local h=hum(LP);if not h then return end;h.WalkSpeed=S.sprint and S.walk*1.35 or S.walk;h.JumpPower=S.jump end
local flyVel;local function stopFly()if flyVel then flyVel:Destroy();flyVel=nil end end
local function toggleFly(v)S.fly=v;if not v then stopFly()end end

-- Aim
local function target()local best,score=nil,math.huge;local m=UIS:GetMouseLocation();local c=workspace.CurrentCamera;for _,p in ipairs(P:GetPlayers())do if allowed(p)then local r=root(p);if r then local pos,ok=c:WorldToViewportPoint(r.Position);if ok and pos.Z>0 then local d=(Vector2.new(pos.X,pos.Y)-m).Magnitude;if d<180 and d<score then score=d;best=p end end end end end;return best end
local function aim(p)local r=root(p);local c=workspace.CurrentCamera;if r and c then c.CFrame=c.CFrame:Lerp(CFrame.lookAt(c.CFrame.Position,r.Position),.18)end end

local function show(tab)
 S.tab=tab;clear()
 if tab=='Dashboard'then section('Overview');feature('Role','Current: '..role(LP),function()N('Role',role(LP))end);feature('Players','Server count',function()N('Players',#P:GetPlayers())end);feature('Target','Eligible targets',function()local n=0;for _,p in ipairs(P:GetPlayers())do if allowed(p)then n+=1 end end;N('Targets',n)end)
 elseif tab=='Role'then section('Role');feature('Sherif Mode','Target Murder only',function()S.role='Sherif';S.target=nil;refreshESP()end);feature('Murder Mode','Target all players',function()S.role='Murder';S.target=nil;refreshESP()end);feature('Auto Role','Read Role attribute',function()S.role='Auto';S.target=nil;refreshESP()end);feature('Role Status','Current role',function()N('Role',role(LP))end)
 elseif tab=='ESP'then section('Player ESP');toggle(cont,'Player ESP',S.esp,function(v)S.esp=v;if v then refreshESP()else clearESP()end end);feature('Murder ESP','Sherif targeting mode',function()S.role='Sherif';S.esp=true;refreshESP()end);feature('Clear ESP','Remove player highlights',function()clearESP()end)
 elseif tab=='Aim'then section('Aim');toggle(cont,'Aim',S.aim,function(v)S.aim=v;if not v then S.target=nil end end);toggle(cont,'Target Lock',S.lock,function(v)S.lock=v end);toggle(cont,'Visibility Check',S.vis,function(v)S.vis=v end);feature('Select Target','Choose nearest target',function()S.target=target();N('Target',S.target and S.target.Name or'None')end)
 elseif tab=='Movement'then section('Movement');feature('WalkSpeed','Current: '..S.walk,function()local a={16,24,32,50,75,100};local i=table.find(a,S.walk)or 1;S.walk=a[i%#a+1];applyMove()end);feature('JumpPower','Current: '..S.jump,function()local a={50,75,100,150};local i=table.find(a,S.jump)or 1;S.jump=a[i%#a+1];applyMove()end);toggle(cont,'Infinite Jump',S.inf,function(v)S.inf=v end);toggle(cont,'Noclip',S.noclip,function(v)S.noclip=v;if not v then noclip(false)end end);toggle(cont,'Fly',S.fly,function(v)toggleFly(v)end);feature('Fly Speed','Current: '..S.flySpeed,function()local a={25,50,100,200,400,800};local i=table.find(a,S.flySpeed)or 1;S.flySpeed=a[i%#a+1]end);toggle(cont,'Sprint',S.sprint,function(v)S.sprint=v;applyMove()end);feature('Gravity','Current: '..S.gravity,function()local a={196.2,150,100,50,0};local i=table.find(a,S.gravity)or 1;S.gravity=a[i%#a+1];workspace.Gravity=S.gravity end);feature('Reset Movement','Restore defaults',function()S.walk=16;S.jump=50;S.gravity=196.2;S.sprint=false;S.fly=false;S.noclip=false;workspace.Gravity=196.2;stopFly();noclip(false);applyMove()end)
 elseif tab=='Auto Egg'then section('Auto Egg');local box=Instance.new('TextBox');box.Size=UDim2.new(1,-4,0,38);box.BackgroundColor3=Color3.fromRGB(14,18,26);box.TextColor3=Color3.new(1,1,1);box.PlaceholderText='Egg name, e.g. Gorilla Egg';box.Text=S.egg;box.Font=Enum.Font.Gotham;box.TextSize=12;box.Parent=cont;cr(box);st(box);C(box.FocusLost,function()S.egg=box.Text:gsub('^%s+',''):gsub('%s+$','');refreshEggESP()end);toggle(cont,'ESP Egg',S.eggESP,function(v)S.eggESP=v;refreshEggESP()end);feature('Refresh Egg','Check selected egg',function()local e=findEgg(S.egg);N('Egg',e and('Found: '..e.Name)or'Not found')end);feature('Auto Egg Speed','Current: '..S.eggSpeed,function()local a={25,50,75,100,150,200,300,500,800,1000};local i=table.find(a,S.eggSpeed)or 1;S.eggSpeed=a[i%#a+1]end);feature('Run Auto Egg','Fly to egg and return',function()if S.eggBusy then return end;local e=findEgg(S.egg);local pp=e and part(e);local r=root(LP);if not pp or not r then N('Auto Egg','Egg/character not found');return end;S.eggBusy=true;S.spawn=S.spawn or r.CFrame;task.spawn(function()local v=Instance.new('BodyVelocity');v.MaxForce=Vector3.new(1e6,1e6,1e6);v.Parent=r;local function go(pos,t)local stt=os.clock();while os.clock()-stt<t and not S.dead do r=root(LP);if not r then break end;local d=pos-r.Position;if d.Magnitude<6 then return true end;v.Velocity=d.Unit*math.min(S.eggSpeed,math.max(40,d.Magnitude*3));RS.Heartbeat:Wait()end;return false end;local ok=go(pp.Position+Vector3.new(0,3,0),12);if ok then for _,x in ipairs(e:GetDescendants())do if x:IsA('ProximityPrompt')then pcall(function()fireproximityprompt(x)end)end end;task.wait(.3)end;go(S.spawn.Position+Vector3.new(0,2,0),12);r=root(LP);if r then r.CFrame=S.spawn;r.AssemblyLinearVelocity=Vector3.zero end;v:Destroy();S.eggBusy=false;N('Auto Egg',ok and'Returned to spawn'or'Could not reach egg')end)end);feature('Save Spawn','Save current return point',function()local r=root(LP);if r then S.spawn=r.CFrame end end);feature('Clear Egg','Clear selection',function()S.egg='';box.Text='';refreshEggESP()end)
 elseif tab=='Settings'then section('Settings');toggle(cont,'Anti AFK',S.afk,function(v)S.afk=v end);toggle(cont,'Notifications',S.notify,function(v)S.notify=v end);feature('Hide GUI','Show reopen button',function()M.Visible=false;reopen.Visible=true;S.hidden=true end);feature('Reset UI','Center interface',function()M.Position=UDim2.fromScale(.5,.5)end);feature('Destroy','Remove UI',function()S.dead=true;clearESP();for x in pairs(ee)do clrEgg(x)end;stopFly();G:Destroy()end)
 end
end
for _,n in ipairs(tabs)do local b=btn(side,n,UDim2.new(1,0,0,31));tb[n]=b;C(b.Activated,function()show(n)end)end
C(hide.Activated,function()M.Visible=false;reopen.Visible=true;S.hidden=true end);C(reopen.Activated,function()if reopenMoved()then return end;M.Visible=true;reopen.Visible=false;S.hidden=false end)
C(kc.Activated,function()local x=kb.Text:gsub('^%s+',''):gsub('%s+$','');if x==KEY then ks.Text='✓ Key valid';ks.TextColor3=Color3.fromRGB(70,220,145);task.wait(.2);key.Visible=false;M.Visible=true;show('Dashboard')else ks.Text='✕ Invalid key';ks.TextColor3=Color3.fromRGB(255,70,70);task.wait(.2);LP:Kick('Ride a Pet: Invalid Key')end end)
C(UIS.JumpRequest,function()if S.inf then local h=hum(LP);if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end end)
C(RS.RenderStepped,function()if S.dead then return end;if S.aim and not S.hidden then if not S.lock or not allowed(S.target)then if S.autoRetarget then S.target=target()end end;if allowed(S.target)then aim(S.target)end end;if S.fly then local r=root(LP);if r then if not flyVel then flyVel=Instance.new('BodyVelocity');flyVel.MaxForce=Vector3.new(1e5,1e5,1e5);flyVel.Parent=r end;local c=workspace.CurrentCamera;local m=Vector3.zero;if UIS:IsKeyDown(Enum.KeyCode.W)then m+=c.LookVector end;if UIS:IsKeyDown(Enum.KeyCode.S)then m-=c.LookVector end;if UIS:IsKeyDown(Enum.KeyCode.A)then m-=c.RightVector end;if UIS:IsKeyDown(Enum.KeyCode.D)then m+=c.RightVector end;if UIS:IsKeyDown(Enum.KeyCode.Space)then m+=Vector3.yAxis end;if UIS:IsKeyDown(Enum.KeyCode.LeftControl)then m-=Vector3.yAxis end;flyVel.Velocity=m.Magnitude>0 and m.Unit*S.flySpeed or Vector3.zero end elseif flyVel then stopFly()end;end)
C(LP.Idled,function()if S.afk then pcall(function()VU:Button2Down(Vector2.zero,Cam.CFrame);task.wait(.1);VU:Button2Up(Vector2.zero,Cam.CFrame)end)end end)
C(P.PlayerAdded,function(p)C(p.CharacterAdded,function()task.wait(.2);if S.esp then esp(p)end end)end);C(P.PlayerRemoving,function(p)clr(p)end);for _,p in ipairs(P:GetPlayers())do if p~=LP then C(p.CharacterAdded,function()task.wait(.2);if S.esp then esp(p)end end)end end
C(LP.CharacterAdded,function()task.wait(.25);S.target=nil;local r=root(LP);if r and not S.spawn then S.spawn=r.CFrame end;applyMove();end)
local r=root(LP);if r then S.spawn=r.CFrame end;show('Dashboard')
