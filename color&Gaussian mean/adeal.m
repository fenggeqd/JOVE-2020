clear,clc
% 利用particle-analyze追踪的结果
%% 读取数据
%[fname,pname]=uigetfile( '*.tif','选择原图像');
%if fname(1)==0, return; end
%tname = [pname,fname];
tname = '2-1.tif'; %原始图像名
info = imfinfo(tname);
k = length(info); %帧数
sy = info.Width;
sx = info.Height;
%xlsread只读取数字部分
results = xlsread('Results.xlsx'); %ImageJ_particle_analyze结果文件名
%[Num1,Area2,Mean3,Min4,Max5,X6,Y7,XM8,YM9,Major10,Minor11,Angle12,Slice13]
%上述序号仅供参考，具体参见读入的Results.csv文件

%%
%ImageJ-MATLAB transform——[X,Y]调换
A = results(:,3); %ImageJ中Area项对应列数，手动修改！
Y = results(:,5); %ImageJ中X坐标对应列数，手动修改！
X = results(:,6); %ImageJ中Y坐标对应列数，手动修改！
Slice = results(:,11); %ImageJ中帧序数对应列数，手动修改！
particle = [X,Y,Slice,A];

%% 数据筛选：预报校正法
% 结果检查
flag1 = []; %空帧序数
flag2 = []; %多帧序数
flag3 = []; %距离≠面积帧序数
if length(find(Slice==1))~=1
    fprintf('请检查第一帧有且只有一个对象！\n');
    return;
end
for i = 1:k
    z = find(particle(:,3)==i);
    c = length(z);
    %初处理
    if  c == 0
        flag1 = [flag1;i];
        insert = [particle(i-1,1),particle(i-1,2),i,particle(i-1,4)];
        particle = [particle(1:i-1,:);insert;particle(i:end,:)];
    elseif c>1
        flag2 = [flag2;i];
        R = (particle(z,1)-particle(i-1,1)).^2+(particle(z,2)-particle(i-1,2)).^2;
        [~,w1] = min(R); %基于距离
        [~,w2] = max(particle(z,4)); %基于面积
        if w1~=w2
            flag3 = [flag3;i];
        end
        z(w1) = [];
        particle(z,:) = [];
    end
end
fs1 = size(flag1,1);
if ~isempty(flag1)
    fprintf('如下%d帧未检出对象，已基于前后帧位置补全：\n',fs1);
    fprintf('%d,',flag1);
    fprintf('\n');
    r1 = input('是否自行增强？（是：1，否：0）\n');
    if r1 ~= 0
        fprintf('请！\n');
        return;
    end
end
if ~isempty(flag3)
    fprintf('如下帧检测到多个对象，已基于前后帧位置筛选：\n');
    fprintf('%d,',flag3);
    fprintf('\n');
    r2 = input('是否自行增强？（是：1，否：0）\n');
    if r2 ~= 0
        fprintf('请！\n');
        return;
    end
end
%再补全
for i = 1:fs1
    q0 = flag1(i);
    q1 = q0-1; %前一实帧序数
    q2 = min(Slice(Slice>q1)); %后一实帧序数
    particle(q0,1:2) = (particle(q2,1:2)+(q2-q0)*particle(q1,1:2))/(q2-q0+1);
end
if size(particle,1) == k
    fprintf('*****1：预处理已完成！*****\n');
else
    fprintf('预处理发生错误！\n');
    return;
end
%至此，对象在每帧有且只有一个较准确位置。

%% 整合轨迹-重定位
dw = 5; %窗口直径(dw=r+2)，奇数！
list=[];
flag4 = []; %重定位失效帧序数
for i = 1 : k
    b = double(imread(tname,i)); %读取8bit图像
    pk = round(particle(i,1:2));
    interactive = 0; %图像
    cnt = cntrd(b,pk,dw,interactive); %中心
    if isempty(cnt)||isnan(cnt(1))
        add = particle(i,1:3); %[X,Y,Slice]
        flag4 = [flag4;i];
    else
        add = [cnt(1,1:2),i]; %[X,Y,Slice]
    end
    list = [list;add]; %[X,Y,Slice]
end
fprintf('*****2：对象重定位已完成！*****\n');
fs4 = size(flag4,1);
if fs4 ~= 0
    fprintf('如下%d帧已取消重定位！\n',fs4);
    fprintf('%d,',flag4);
    fprintf('\n');
end

%% track
maxdisp = 15; %移动距离，可修改
%tr = track(list,maxdisp); %[X,Y,Slice,Num]
%tr = [list,ones(size(list,1),1)];
param.mem = 0; %失踪帧数
param.dim = 2; %坐标维度
param.good = floor(k*.01); %阈值帧数
param.quiet = 1; %1:无文字提示
tr = track(list,maxdisp,param); %[X,Y,Slice,Num]
%save ('tr.mat','tr'); %保存

%检验-plot
ki = max(tr(:,4));
if ki==1
    st = 1; % start plot
    for i = 1:ki
        en = st-1+length(find(tr(:,4)==i));
        col = rand(1,3);
        %col = [0.04617,0.09713,0.8235];
        plot(tr(st:en,1),tr(st:en,2),'Color',col);
        hold on
        st = en+1;
    end
    fprintf('*****3：已检出对象轨迹！*****\n');
elseif ki==0
    fprintf('未检出对象轨迹，请修改参数！\n');
    return;
else
    fprintf('对象轨迹多于一条，请修改参数！\n');
    return;
end

%% 映射
%前提：得到中心轨迹tr
%load ('tr.mat')
mean = [];
rp = 3;
flag5 = []; %半径过大
for i = 1:k
    a = double(imread(tname,i)); %三通道
    x = round(tr(i,1));
    y = round(tr(i,2));
    xa = x-rp;
    xb = x+rp;
    ya = y-rp;
    yb = y+rp;
    if xa>=1 && ya>=1 && xb<=sx && yb<=sy
        c0 = a(xa:xb,ya:yb,:);
        c =  reshape(c0,[],3);
        [u,~] = normfit(c);
        %cu = mean(c)
        %cM = max(max(c));
        %cm = min(min(c));
        au = [u,u(1)-u(2)];
        mean = [mean;au];
    else
        flag5 = [flag5;i];
        c0 = a(x,y,:);
        c =  reshape(c0,[],3);
        ac = [c,c(1)-c(2)];
        mean = [mean;ac];
    end
end
fprintf('*****4：亮度提取已完成！*****\n');
f5 = size(flag5,1);
if f5~=0
    fprintf('如下%d帧对象超出边缘，已提取中心亮度：\n',f5);
    fprintf('%d,',flag5);
    fprintf('\n');
end
xlswrite('mean.xlsx',mean); %保存为Excel格式