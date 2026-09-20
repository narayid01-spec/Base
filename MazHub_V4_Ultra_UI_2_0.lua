-- MazHub V4 Ultra | UI 2.0 | Single LocalScript
-- Place in StarterPlayer > StarterPlayerScripts

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local LP=Players.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")
local Cam=workspace.CurrentCamera

local CFG={KEY="MAZHUBV4",WALKMAX=1000,FLYMAX=1000,AIMMAX=2000,AIMDEFAULT=250,FOV=350,SMOOTH=.18}
local S={Unlocked=false,Walk=16,WalkOn=false,Fly=100,Flying=false,Noclip=false,InfJump=false,ESP=false,AimV1=false,Team="",Range=250,Vert=0,Target=nil,Original=16}
local V2={On=false,Team="",Range=250,FOV=350,Smooth=.18,Target=nil,Part=nil,HL=nil,Last=0}
local Char,Hum,Root,FlyBV

local C={BG=Color3.fromRGB(8,8,10),BG2=Color3.fromRGB(13,13,16),Panel=Color3.fromRGB(18,18,22),Panel2=Color3.fromRGB(23,23,28),Red=Color3.fromRGB(225,35,48),Red2=Color3.fromRGB(255,65,75),DarkRed=Color3.fromRGB(95,18,25),White=Color3.fromRGB(245,245,248),Gray=Color3.fromRGB(160,160,170),Gray2=Color3.fromRGB(105,105,115),Green=Color3.fromRGB(55,220,125)}

local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 8);x.Parent=o;return x end
local function stroke(o,c,t,tr)local x=Instance.new("UIStroke");x.Color=c or C.Red;x.Thickness=t or 1;x.Transparency=tr or 0;x.Parent=o;return x end
local function grad(o,a,b,r)local x=Instance.new("UIGradient");x.Color=ColorSequence.new(a,b);x.Rotation=r or 0;x.Parent=o end
local function tw(o,p,d)TweenService:Create(o,TweenInfo.new(d or .15,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play()end
local function clamp(v,a,b,f)local n=tonumber(v);return n and math.clamp(n,a,b) or f end
local function note(t,x,d)pcall(function()game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=x,Duration=d or 3})end)end
local function drag(o,h)
 h=h or o;local on=false;local st,sp
 h.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=true;st=i.Position;sp=o.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then on=false end end)end end)
 UIS.InputChanged:Connect(function(i)if on and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-st;o.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)
end

local function setup(ch)
 Char=ch;Hum=ch:WaitForChild("Humanoid",10);Root=ch:WaitForChild("HumanoidRootPart",10)
 if Hum then S.Original=Hum.WalkSpeed;S.WalkOn=false end
 S.Flying=false;S.Vert=0;S.Target=nil;V2.Target=nil;V2.Part=nil
 if V2.HL then V2.HL:Destroy();V2.HL=nil end
end
if LP.Character then task.spawn(setup,LP.Character) end
LP.CharacterAdded:Connect(setup)

local GUI=Instance.new("ScreenGui");GUI.Name="MazHubV4Ultra";GUI.ResetOnSpawn=false;GUI.IgnoreGuiInset=true;GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;GUI.Parent=PG

local Main=Instance.new("Frame");Main.AnchorPoint=Vector2.new(.5,.5);Main.Position=UDim2.fromScale(.5,.5);Main.Size=UDim2.new(.92,0,0,470);Main.BackgroundColor3=C.BG;Main.BackgroundTransparency=.08;Main.Visible=false;Main.Parent=GUI;corner(Main,14);stroke(Main,C.DarkRed,1.5,.15);grad(Main,Color3.fromRGB(12,12,15),Color3.fromRGB(7,7,9),90)
local mc=Instance.new("UISizeConstraint");mc.MinSize=Vector2.new(320,400);mc.MaxSize=Vector2.new(620,650);mc.Parent=Main

local Head=Instance.new("Frame");Head.Size=UDim2.new(1,0,0,66);Head.BackgroundColor3=C.Panel;Head.Parent=Main;corner(Head,14)
local line=Instance.new("Frame");line.Size=UDim2.new(1,0,0,2);line.Position=UDim2.new(0,0,1,-2);line.BackgroundColor3=C.Red;line.BorderSizePixel=0;line.Parent=Head;grad(line,C.Red,Color3.fromRGB(100,10,20),0)
local logo=Instance.new("Frame");logo.Size=UDim2.fromOffset(44,44);logo.Position=UDim2.fromOffset(12,11);logo.BackgroundColor3=C.Red;logo.Parent=Head;corner(logo,12);grad(logo,C.Red2,Color3.fromRGB(125,12,22),45)
local lt=Instance.new("TextLabel");lt.Size=UDim2.fromScale(1,1);lt.BackgroundTransparency=1;lt.Text="M";lt.TextColor3=Color3.new(1,1,1);lt.Font=Enum.Font.GothamBlack;lt.TextSize=25;lt.Parent=logo
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(68,9);title.Size=UDim2.new(1,-150,0,26);title.Text="MazHub";title.TextColor3=C.White;title.Font=Enum.Font.GothamBold;title.TextSize=21;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=Head
local ver=Instance.new("TextLabel");ver.BackgroundTransparency=1;ver.Position=UDim2.fromOffset(69,34);ver.Size=UDim2.new(1,-150,0,18);ver.Text="V4 Ultra  •  Premium Control";ver.TextColor3=C.Gray;ver.Font=Enum.Font.Gotham;ver.TextSize=11;ver.TextXAlignment=Enum.TextXAlignment.Left;ver.Parent=Head
local hide=Instance.new("TextButton");hide.Size=UDim2.fromOffset(38,38);hide.Position=UDim2.new(1,-50,0,14);hide.BackgroundColor3=C.Panel2;hide.Text="—";hide.TextColor3=C.White;hide.Font=Enum.Font.GothamBold;hide.TextSize=19;hide.AutoButtonColor=false;hide.Parent=Head;corner(hide,10);stroke(hide,C.Gray2,1,.55)

local Side=Instance.new("Frame");Side.Position=UDim2.fromOffset(10,76);Side.Size=UDim2.new(0,128,1,-86);Side.BackgroundColor3=C.Panel;Side.Parent=Main;corner(Side,12);stroke(Side,Color3.fromRGB(45,45,50),1,.6)
local sl=Instance.new("UIListLayout");sl.Padding=UDim.new(0,6);sl.HorizontalAlignment=Enum.HorizontalAlignment.Center;sl.SortOrder=Enum.SortOrder.LayoutOrder;sl.Parent=Side
local spad=Instance.new("UIPadding");spad.PaddingTop=UDim.new(0,10);spad.PaddingLeft=UDim.new(0,7);spad.PaddingRight=UDim.new(0,7);spad.Parent=Side
local Content=Instance.new("Frame");Content.Position=UDim2.fromOffset(148,76);Content.Size=UDim2.new(1,-158,1,-86);Content.BackgroundTransparency=1;Content.Parent=Main
local Pages={}
local function page(n)local p=Instance.new("ScrollingFrame");p.Name=n;p.Size=UDim2.fromScale(1,1);p.BackgroundTransparency=1;p.BorderSizePixel=0;p.ScrollBarThickness=3;p.ScrollBarImageColor3=C.Red;p.AutomaticCanvasSize=Enum.AutomaticSize.Y;p.Visible=false;p.Parent=Content;local q=Instance.new("UIPadding");q.PaddingTop=UDim.new(0,2);q.PaddingBottom=UDim.new(0,12);q.PaddingLeft=UDim.new(0,2);q.PaddingRight=UDim.new(0,8);q.Parent=p;local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,10);l.Parent=p;Pages[n]=p;return p end
local Home=page("Home");local PlayerPage=page("Player");local Visual=page("Visual");local Combat=page("Combat");local Movement=page("Movement");local Credits=page("Credits")
local function card(p,t,sub,h)local f=Instance.new("Frame");f.Size=UDim2.new(1,-2,0,h or 90);f.BackgroundColor3=C.Panel;f.Parent=p;corner(f,11);stroke(f,Color3.fromRGB(45,45,52),1,.5);local a=Instance.new("Frame");a.Size=UDim2.fromOffset(3,(h or 90)-35);a.Position=UDim2.fromOffset(0,17);a.BackgroundColor3=C.Red;a.BorderSizePixel=0;a.Parent=f;corner(a,2);local x=Instance.new("TextLabel");x.BackgroundTransparency=1;x.Position=UDim2.fromOffset(15,10);x.Size=UDim2.new(1,-25,0,22);x.Text=t;x.TextColor3=C.White;x.Font=Enum.Font.GothamBold;x.TextSize=14;x.TextXAlignment=Enum.TextXAlignment.Left;x.Parent=f;local y=Instance.new("TextLabel");y.BackgroundTransparency=1;y.Position=UDim2.fromOffset(15,34);y.Size=UDim2.new(1,-25,0,35);y.Text=sub or "";y.TextColor3=C.Gray;y.Font=Enum.Font.Gotham;y.TextSize=10;y.TextWrapped=true;y.TextXAlignment=Enum.TextXAlignment.Left;y.TextYAlignment=Enum.TextYAlignment.Top;y.Parent=f;return f end
local function input(p,ph,txt)local b=Instance.new("TextBox");b.Size=UDim2.new(1,0,0,40);b.BackgroundColor3=C.BG2;b.TextColor3=C.White;b.PlaceholderColor3=C.Gray2;b.PlaceholderText=ph;b.Text=txt or "";b.ClearTextOnFocus=false;b.Font=Enum.Font.Gotham;b.TextSize=12;b.TextXAlignment=Enum.TextXAlignment.Left;b.Parent=p;corner(b,9);stroke(b,Color3.fromRGB(55,55,62),1,.35);local q=Instance.new("UIPadding");q.PaddingLeft=UDim.new(0,12);q.PaddingRight=UDim.new(0,12);q.Parent=b;return b end
local function status(p,t)local x=Instance.new("TextLabel");x.Size=UDim2.new(1,0,0,30);x.BackgroundColor3=C.BG2;x.Text=t;x.TextColor3=C.Gray;x.Font=Enum.Font.GothamMedium;x.TextSize=11;x.Parent=p;corner(x,8);return x end
local function toggle(p,t,initial,cb)local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,44);b.BackgroundColor3=C.Panel2;b.Text="";b.AutoButtonColor=false;b.Parent=p;corner(b,9);stroke(b,Color3.fromRGB(48,48,55),1,.5);local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Position=UDim2.fromOffset(12,0);l.Size=UDim2.new(1,-78,1,0);l.Text=t;l.TextColor3=C.White;l.Font=Enum.Font.GothamMedium;l.TextSize=12;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=b;local pill=Instance.new("Frame");pill.Size=UDim2.fromOffset(48,24);pill.Position=UDim2.new(1,-58,.5,-12);pill.BackgroundColor3=Color3.fromRGB(45,45,50);pill.Parent=b;corner(pill,20);local dot=Instance.new("Frame");dot.Size=UDim2.fromOffset(18,18);dot.Position=UDim2.fromOffset(3,3);dot.BackgroundColor3=C.Gray2;dot.Parent=pill;corner(dot,20);local on=initial==true;local function refresh()if on then tw(pill,{BackgroundColor3=C.DarkRed});tw(dot,{Position=UDim2.new(1,-21,0,3),BackgroundColor3=C.Red2})else tw(pill,{BackgroundColor3=Color3.fromRGB(45,45,50)});tw(dot,{Position=UDim2.fromOffset(3,3),BackgroundColor3=C.Gray2})end end;refresh();b.MouseButton1Click:Connect(function()on=not on;refresh();if cb then cb(on)end end);return{Set=function(v)on=v;refresh();if cb then cb(on)end end,Get=function()return on end}end
local function action(p,t,cb)local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,40);b.BackgroundColor3=C.Panel2;b.Text=t;b.TextColor3=C.White;b.Font=Enum.Font.GothamMedium;b.TextSize=12;b.AutoButtonColor=false;b.Parent=p;corner(b,9);stroke(b,Color3.fromRGB(50,50,57),1,.45);b.MouseButton1Click:Connect(function()if cb then cb()end end);return b end

-- Home
local hero=card(Home,"Welcome to MazHub","V4 Ultra • Compact control hub\nBuilt for mobile & desktop.",125);local ready=status(hero,"●  SYSTEM READY");ready.Position=UDim2.new(0,17,1,-38);ready.Size=UDim2.new(1,-34,0,26);ready.TextColor3=C.Green;ready.BackgroundColor3=Color3.fromRGB(12,28,20);card(Home,"Quick Info","Use the sidebar to access Player, Visual, Combat, Movement and Credits.")
card(PlayerPage,"Player Controls","Basic player movement and utility settings.")

-- Visual
local vc=card(Visual,"Player ESP","Body highlight only. No names or distance labels.",120);local vbox=Instance.new("Frame");vbox.BackgroundTransparency=1;vbox.Position=UDim2.fromOffset(15,64);vbox.Size=UDim2.new(1,-30,0,45);vbox.Parent=vc
local function addESP(plr)if plr==LP or not S.ESP or not plr.Character or plr.Character:FindFirstChild("MazHub_PlayerESP")then return end;local h=Instance.new("Highlight");h.Name="MazHub_PlayerESP";h.Adornee=plr.Character;h.FillColor=C.Red;h.FillTransparency=.72;h.OutlineColor=C.Red2;h.OutlineTransparency=.1;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=plr.Character end
local function clearESP()for _,p in ipairs(Players:GetPlayers())do if p~=LP and p.Character then local h=p.Character:FindFirstChild("MazHub_PlayerESP");if h then h:Destroy()end end end end
toggle(vbox,"Player ESP",false,function(on)S.ESP=on;if on then for _,p in ipairs(Players:GetPlayers())do addESP(p)end else clearESP()end end)
Players.PlayerAdded:Connect(function(p)p.CharacterAdded:Connect(function()task.wait(.4);addESP(p)end)end)

-- Combat
local TeamBox,RangeBox,TargetText,V1,V2
local tc=card(Combat,"Target Team","Type your team name, e.g. Blue. Same-team players are ignored.",120);local tb=Instance.new("Frame");tb.BackgroundTransparency=1;tb.Position=UDim2.fromOffset(15,63);tb.Size=UDim2.new(1,-30,0,40);tb.Parent=tc;TeamBox=input(tb,"Your Team","");TeamBox.FocusLost:Connect(function()S.Team=TeamBox.Text;V2.Team=TeamBox.Text end)
local rc=card(Combat,"Aim Distance","Maximum world distance for target selection.",120);local rb=Instance.new("Frame");rb.BackgroundTransparency=1;rb.Position=UDim2.fromOffset(15,63);rb.Size=UDim2.new(1,-30,0,40);rb.Parent=rc;RangeBox=input(rb,"Distance 1 - 2000","250");RangeBox.FocusLost:Connect(function()S.Range=clamp(RangeBox.Text,1,CFG.AIMMAX,CFG.AIMDEFAULT);V2.Range=S.Range;RangeBox.Text=tostring(S.Range)end)
local v1c=card(Combat,"Auto AIM V1","Nearest valid enemy target.",120);local v1b=Instance.new("Frame");v1b.BackgroundTransparency=1;v1b.Position=UDim2.fromOffset(15,63);v1b.Size=UDim2.new(1,-30,0,45);v1b.Parent=v1c;V1=toggle(v1b,"Auto AIM V1",false,function(on)S.AimV1=on;if on and V2.On then V2.On=false;if V2 then V2Toggle.Set(false)end end end)
local v2c=card(Combat,"AIM Lock V2","Smooth camera lock with FOV target selection.",120);local v2b=Instance.new("Frame");v2b.BackgroundTransparency=1;v2b.Position=UDim2.fromOffset(15,63);v2b.Size=UDim2.new(1,-30,0,45);v2b.Parent=v2c
local V2Toggle=toggle(v2b,"AIM Lock V2",false,function(on)V2.On=on;if on then S.AimV1=false;V1.Set(false)else V2.Target=nil;V2.Part=nil end end)
local stc=card(Combat,"Target Status","Current automatically selected target.",120);local stbox=Instance.new("Frame");stbox.BackgroundTransparency=1;stbox.Position=UDim2.fromOffset(15,63);stbox.Size=UDim2.new(1,-30,0,30);stbox.Parent=stc;TargetText=status(stbox,"Target: None");TargetText.Size=UDim2.fromScale(1,1)

-- Movement
local wc=card(Movement,"WalkSpeed","Maximum 1000. OFF restores original character speed.",145);local wb=Instance.new("Frame");wb.BackgroundTransparency=1;wb.Position=UDim2.fromOffset(15,62);wb.Size=UDim2.new(1,-30,0,92);wb.Parent=wc;local wl=Instance.new("UIListLayout");wl.Padding=UDim.new(0,6);wl.Parent=wb;local WalkBox=input(wb,"WalkSpeed 1 - 1000","16");local WalkT=toggle(wb,"Enable WalkSpeed",false,function(on)S.WalkOn=on;if not on and Hum then Hum.WalkSpeed=S.Original end end);WalkBox.FocusLost:Connect(function()S.Walk=clamp(WalkBox.Text,1,CFG.WALKMAX,S.Walk);WalkBox.Text=tostring(S.Walk);if S.WalkOn and Hum then Hum.WalkSpeed=S.Walk end end)
local fc=card(Movement,"Fly","Joystick controls horizontal movement; ▲/▼ controls vertical.",145);local fb=Instance.new("Frame");fb.BackgroundTransparency=1;fb.Position=UDim2.fromOffset(15,62);fb.Size=UDim2.new(1,-30,0,92);fb.Parent=fc;local fl=Instance.new("UIListLayout");fl.Padding=UDim.new(0,6);fl.Parent=fb;local FlyBox=input(fb,"Fly Speed 1 - 1000","100");toggle(fb,"Enable Fly",false,function(on)S.Flying=on end);FlyBox.FocusLost:Connect(function()S.Fly=clamp(FlyBox.Text,1,CFG.FLYMAX,S.Fly);FlyBox.Text=tostring(S.Fly)end)
local uc=card(Movement,"Movement Utilities","Noclip and Infinite Jump.",145);local ub=Instance.new("Frame");ub.BackgroundTransparency=1;ub.Position=UDim2.fromOffset(15,62);ub.Size=UDim2.new(1,-30,0,94);ub.Parent=uc;local ul=Instance.new("UIListLayout");ul.Padding=UDim.new(0,6);ul.Parent=ub;toggle(ub,"Noclip",false,function(on)S.Noclip=on end);toggle(ub,"Infinite Jump",false,function(on)S.InfJump=on end)

-- Credits
local cc=card(Credits,"MazHub V4 Ultra","UI 2.0",180);local cb=Instance.new("Frame");cb.BackgroundTransparency=1;cb.Position=UDim2.fromOffset(15,62);cb.Size=UDim2.new(1,-30,0,120);cb.Parent=cc;local cl=Instance.new("UIListLayout");cl.Padding=UDim.new(0,6);cl.Parent=cb;status(cb,"Created by: adamhdhbbb");status(cb,"UI / Script: BaconPro90258");local db=action(cb,"Discord • Get Updates",function()local u="https://discord.gg/zUXgk4XT";if setclipboard then pcall(function()setclipboard(u)end);note("MazHub","Discord link copied.")else note("MazHub","discord.gg/zUXgk4XT",5)end end);db.TextColor3=C.Red2

-- Sidebar
local SB={}
local function select(n)for k,p in pairs(Pages)do p.Visible=k==n end;for k,d in pairs(SB)do local a=k==n;if a then tw(d.B,{BackgroundColor3=Color3.fromRGB(42,17,21)});d.I.BackgroundTransparency=0;d.T.TextColor3=C.White else tw(d.B,{BackgroundColor3=C.Panel2});d.I.BackgroundTransparency=1;d.T.TextColor3=C.Gray end end end
local function side(n,ic)local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,42);b.BackgroundColor3=C.Panel2;b.Text="";b.AutoButtonColor=false;b.Parent=Side;corner(b,9);local i=Instance.new("Frame");i.Size=UDim2.fromOffset(3,22);i.Position=UDim2.fromOffset(0,10);i.BackgroundColor3=C.Red;i.BackgroundTransparency=1;i.Parent=b;corner(i,3);local il=Instance.new("TextLabel");il.BackgroundTransparency=1;il.Position=UDim2.fromOffset(9,0);il.Size=UDim2.fromOffset(25,42);il.Text=ic;il.TextColor3=C.Gray;il.Font=Enum.Font.GothamBold;il.TextSize=15;il.Parent=b;local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(35,0);t.Size=UDim2.new(1,-42,1,0);t.Text=n;t.TextColor3=C.Gray;t.Font=Enum.Font.GothamMedium;t.TextSize=11;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=b;b.MouseButton1Click:Connect(function()select(n)end);SB[n]={B=b,I=i,T=t}end
side("Home","⌂");side("Player","●");side("Visual","◉");side("Combat","✦");side("Movement","↗");side("Credits","i");select("Home")

-- Floating M
local Float=Instance.new("TextButton");Float.AnchorPoint=Vector2.new(.5,.5);Float.Position=UDim2.fromScale(.5,.5);Float.Size=UDim2.fromOffset(58,58);Float.BackgroundColor3=C.Red;Float.Text="M";Float.TextColor3=Color3.new(1,1,1);Float.Font=Enum.Font.GothamBlack;Float.TextSize=25;Float.AutoButtonColor=false;Float.Visible=false;Float.Parent=GUI;corner(Float,29);stroke(Float,C.Red2,2,.1);grad(Float,C.Red2,Color3.fromRGB(105,10,20),45);drag(Float)
Float.MouseButton1Click:Connect(function()Float.Visible=false;Main.Visible=true end)
hide.MouseButton1Click:Connect(function()Main.Visible=false;Float.Visible=true end)
drag(Main,Head)

-- Mobile Fly controls
local FC=Instance.new("Frame");FC.AnchorPoint=Vector2.new(1,1);FC.Position=UDim2.new(1,-18,1,-25);FC.Size=UDim2.fromOffset(65,132);FC.BackgroundTransparency=1;FC.Visible=false;FC.Parent=GUI;local FCL=Instance.new("UIListLayout");FCL.Padding=UDim.new(0,7);FCL.HorizontalAlignment=Enum.HorizontalAlignment.Center;FCL.VerticalAlignment=Enum.VerticalAlignment.Bottom;FCL.Parent=FC
local function flyBtn(txt,val)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(58,58);b.BackgroundColor3=C.Panel;b.Text=txt;b.TextColor3=C.White;b.Font=Enum.Font.GothamBold;b.TextSize=22;b.AutoButtonColor=false;b.Parent=FC;corner(b,16);stroke(b,C.Red,1.5,.2);b.MouseButton1Down:Connect(function()S.Vert=val end);b.MouseButton1Up:Connect(function()if S.Vert==val then S.Vert=0 end end);return b end
flyBtn("▲",1);flyBtn("▼",-1)
local function stopFly()if FlyBV then FlyBV:Destroy();FlyBV=nil end;S.Vert=0;FC.Visible=false end
local function startFly()if not Root then return end;if FlyBV then FlyBV:Destroy()end;FlyBV=Instance.new("BodyVelocity");FlyBV.Name="MazHubFlyVelocity";FlyBV.MaxForce=Vector3.new(math.huge,math.huge,math.huge);FlyBV.P=9000;FlyBV.Parent=Root;if UIS.TouchEnabled then FC.Visible=true end end
UIS.InputBegan:Connect(function(i,p)if p then return end;if i.KeyCode==Enum.KeyCode.Space then S.Vert=1 elseif i.KeyCode==Enum.KeyCode.LeftControl then S.Vert=-1 end end)
UIS.InputEnded:Connect(function(i)if i.KeyCode==Enum.KeyCode.Space and S.Vert==1 then S.Vert=0 elseif i.KeyCode==Enum.KeyCode.LeftControl and S.Vert==-1 then S.Vert=0 end end)
UIS.JumpRequest:Connect(function()if S.InfJump and Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping)end end)

-- Targeting
local function team(p)return p and p.Team and p.Team.Name or "" end
local function enemy(p,own)if not p or p==LP then return false end;local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if not h or h.Health<=0 then return false end;local pt=team(p);if own~="" then return pt~=own end;if LP.Team then return pt~=LP.Team.Name end;return true end
local function part(p)return p.Character and(p.Character:FindFirstChild("UpperTorso")or p.Character:FindFirstChild("Torso")or p.Character:FindFirstChild("HumanoidRootPart"))end
local function findV1()if not Root then return end;local own=S.Team;if own=="" and LP.Team then own=LP.Team.Name end;local best,bd=nil,S.Range;for _,p in ipairs(Players:GetPlayers())do if enemy(p,own)then local q=part(p);if q then local d=(Root.Position-q.Position).Magnitude;if d<=bd then bd=d;best=p end end end end;return best end
local function clearV2()V2.Target=nil;V2.Part=nil;if V2.HL then V2.HL:Destroy();V2.HL=nil end end
local function setV2(p)if V2.Target==p then return end;if V2.HL then V2.HL:Destroy();V2.HL=nil end;V2.Target=p;V2.Part=part(p);if p and p.Character then local h=Instance.new("Highlight");h.Name="MazHub_AimTarget";h.Adornee=p.Character;h.FillColor=C.Red;h.FillTransparency=.85;h.OutlineColor=C.Red2;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=p.Character;V2.HL=h end end
local function retarget()if not Root then clearV2();return end;local own=V2.Team;if own=="" and LP.Team then own=LP.Team.Name end;local best,bpart,score=nil,nil,math.huge;local vs=Cam.ViewportSize;local center=Vector2.new(vs.X/2,vs.Y/2);for _,p in ipairs(Players:GetPlayers())do if enemy(p,own)then local q=part(p);if q then local wd=(Root.Position-q.Position).Magnitude;if wd<=V2.Range then local sp,vis=Cam:WorldToViewportPoint(q.Position);if vis and sp.Z>0 then local sd=(Vector2.new(sp.X,sp.Y)-center).Magnitude;if sd<=V2.FOV then local sc=sd*.7+wd*.3;if sc<score then score=sc;best=p;bpart=q end end end end end end;if best then setV2(best);V2.Part=bpart else clearV2()end end
local function aimV1()if not S.AimV1 then return end;local p=S.Target;if not p or not p.Parent or not enemy(p,S.Team)then p=findV1();S.Target=p end;if p then local q=part(p);if q then Cam.CFrame=CFrame.lookAt(Cam.CFrame.Position,q.Position)else S.Target=nil end end end
local function aimV2(dt)if not V2.On then return end;local p=V2.Target;local q=p and part(p);if not p or not p.Parent or not q or not enemy(p,V2.Team)then clearV2();return end;V2.Part=q;local desired=CFrame.lookAt(Cam.CFrame.Position,q.Position);local a=1-math.exp(-V2.Smooth*60*dt);Cam.CFrame=Cam.CFrame:Lerp(desired,math.clamp(a,0,1))end
Players.PlayerRemoving:Connect(function(p)if S.Target==p then S.Target=nil end;if V2.Target==p then clearV2()end end)

-- Key system
local KF=Instance.new("Frame");KF.AnchorPoint=Vector2.new(.5,.5);KF.Position=UDim2.fromScale(.5,.5);KF.Size=UDim2.new(.85,0,0,285);KF.BackgroundColor3=C.BG;KF.Parent=GUI;corner(KF,15);stroke(KF,C.Red,1.5,.15);grad(KF,Color3.fromRGB(17,9,11),Color3.fromRGB(7,7,9),90);local kc=Instance.new("UISizeConstraint");kc.MinSize=Vector2.new(300,260);kc.MaxSize=Vector2.new(430,350);kc.Parent=KF
local KH=Instance.new("Frame");KH.Size=UDim2.new(1,0,0,70);KH.BackgroundColor3=C.Panel;KH.Parent=KF;corner(KH,15);local KL=Instance.new("TextLabel");KL.BackgroundTransparency=1;KL.Position=UDim2.fromOffset(14,13);KL.Size=UDim2.fromOffset(43,43);KL.BackgroundColor3=C.Red;KL.Text="M";KL.TextColor3=Color3.new(1,1,1);KL.Font=Enum.Font.GothamBlack;KL.TextSize=24;KL.Parent=KH;corner(KL,11)
local KT=Instance.new("TextLabel");KT.BackgroundTransparency=1;KT.Position=UDim2.fromOffset(68,11);KT.Size=UDim2.new(1,-80,0,24);KT.Text="MazHub";KT.TextColor3=C.White;KT.Font=Enum.Font.GothamBold;KT.TextSize=20;KT.TextXAlignment=Enum.TextXAlignment.Left;KT.Parent=KH
local KS=Instance.new("TextLabel");KS.BackgroundTransparency=1;KS.Position=UDim2.fromOffset(69,37);KS.Size=UDim2.new(1,-80,0,18);KS.Text="V4 Ultra • Premium Version";KS.TextColor3=C.Red2;KS.Font=Enum.Font.GothamMedium;KS.TextSize=10;KS.TextXAlignment=Enum.TextXAlignment.Left;KS.Parent=KH
local KB=Instance.new("Frame");KB.BackgroundTransparency=1;KB.Position=UDim2.fromOffset(15,84);KB.Size=UDim2.new(1,-30,1,-96);KB.Parent=KF;local KBL=Instance.new("UIListLayout");KBL.Padding=UDim.new(0,8);KBL.Parent=KB
local Key=input(KB,"Enter MazHub Key","")
action(KB,"GET KEY • COPY DISCORD",function()local u="https://discord.gg/zUXgk4XT";if setclipboard then pcall(function()setclipboard(u)end);note("MazHub","Discord link copied.")else note("MazHub","discord.gg/zUXgk4XT",5)end end)
action(KB,"PASTE KEY",function()if getclipboard then local ok,v=pcall(getclipboard);if ok and v then Key.Text=v;note("MazHub","Key pasted.")end else note("MazHub","Clipboard API not available.")end end)
local unlock=action(KB,"UNLOCK MAZHUB",function()if Key.Text==CFG.KEY then S.Unlocked=true;KF.Visible=false;Main.Visible=true;note("MazHub V4 Ultra","Unlocked successfully.")else note("MazHub","Wrong key.");pcall(function()LP:Kick("MazHub: Wrong Key")end)end end);unlock.BackgroundColor3=C.DarkRed;stroke(unlock,C.Red,1,.2);drag(KF,KH)

Main.Visible=false;Float.Visible=false;KF.Visible=true
local et=0
RunService.RenderStepped:Connect(function(dt)
 if not Char or not Char.Parent or not Hum or Hum.Health<=0 or not Root or not Root.Parent then stopFly();return end
 if S.WalkOn then Hum.WalkSpeed=S.Walk else if Hum.WalkSpeed~=S.Original then Hum.WalkSpeed=S.Original end end
 if S.Noclip then for _,o in ipairs(Char:GetDescendants())do if o:IsA("BasePart")then o.CanCollide=false end end end
 if S.Flying then if not FlyBV or not FlyBV.Parent then startFly()end;if FlyBV then FlyBV.Velocity=Hum.MoveDirection*S.Fly+Vector3.new(0,S.Vert*S.Fly,0)end else if FlyBV then stopFly()end end
 if S.AimV1 and not V2.On then aimV1()end
 if V2.On then if os.clock()-V2.Last>=.05 then V2.Last=os.clock();retarget()end;aimV2(dt)end
 et+=dt;if et>=.25 then et=0;if S.ESP then for _,p in ipairs(Players:GetPlayers())do addESP(p)end end end
 local p=V2.On and V2.Target or S.Target;if p and p.Parent then TargetText.Text="Target:  "..p.DisplayName;TargetText.TextColor3=C.Green else TargetText.Text="Target:  None";TargetText.TextColor3=C.Gray end
end)
LP:GetPropertyChangedSignal("Team"):Connect(function()if TeamBox and TeamBox.Text==""then V2.Team=team(LP)end end)
GUI.Destroying:Connect(function()stopFly();clearV2()end)
print("MazHub V4 Ultra UI 2.0 loaded")
