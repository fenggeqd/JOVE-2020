clear,clc
% 根据轨迹提取亮度，使用二维高斯拟合(相关系数≠0)
%% 读取数据
%[fname,pname]=uigetfile( '*.tif','选择原图像');
%if fname(1)==0, return; end
%tname = [pname,fname];
tname = '2.tif'; %原始图像名，手动修改！
info = imfinfo(tname);
k = length(info); %帧数
sy = info.Width;
sx = info.Height;
%xlsread只读取数字部分
results = xlsread('Results.csv'); %particle-tracker追踪结果轨迹文件名
%[Num1,Area2,Mean3,Min4,Max5,X6,Y7,XM8,YM9,Major10,Minor11,Angle12,Slice13]
%上述序号仅供参考，具体参见读入的Results.csv文件

%%
%ImageJ-MATLAB transform——[X,Y]调换
%A = results(:,3); %ImageJ中Area项对应列数，手动修改！
Y = results(:,4); %ImageJ中X坐标对应列数，手动修改！
X = results(:,5); %ImageJ中Y坐标对应列数，手动修改！
%Slice = results(:,11); %ImageJ中帧序数对应列数，手动修改！
%particle = [X,Y,Slice,A];
tr = [X,Y];
ki = size(tr,1);

%% plot
col = rand(1,3);
%col = [0.04617,0.09713,0.8235];
plot(tr(:,1),tr(:,2),'Color',col);
hold on

%% 映射
%前提：得到中心轨迹tr
%load ('tr.mat')
fit = [];
rp = 2; %半径
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
        % 读取亮度
        c0 = a(xa:xb,ya:yb,1:2);
        c =  reshape(c0,[],2);
        cm = mean(c);
        cM = max(c);
        % 2D高斯拟合
        [U,V] = meshgrid(xa:xb,ya:yb);
        I = [U(:),V(:)];
        X = [ones(size(I,1),1), I(:,1).^2, I(:,2).^2, I(:,1).*I(:,2), I(:,1), I(:,2)];
        y_ = log(c+10^(-8));
        [B, ~, ~, ~, STATS] = regress(y_(:,1), X);
        FM(1) = exp((B(1)*B(2)*B(3)*4-B(2)*B(6)^2-B(1)*B(4)^2-B(3)*B(5)^2+B(4)*B(5)*B(6))/(B(2)*B(3)*4-B(4)^2));
        u1(1) = -(B(3)*B(5)*2-B(4)*B(6))/(B(2)*B(3)*4-B(4)^2);
        u2(1) = -(B(2)*B(6)*2-B(4)*B(5))/(B(2)*B(3)*4-B(4)^2);
        R2(1) = STATS(1);
        [B, ~, ~, ~, STATS] = regress(y_(:,2), X);
        FM(2) = exp((B(1)*B(2)*B(3)*4-B(2)*B(6)^2-B(1)*B(4)^2-B(3)*B(5)^2+B(4)*B(5)*B(6))/(B(2)*B(3)*4-B(4)^2));
        u1(2) = -(B(3)*B(5)*2-B(4)*B(6))/(B(2)*B(3)*4-B(4)^2);
        u2(2) = -(B(2)*B(6)*2-B(4)*B(5))/(B(2)*B(3)*4-B(4)^2);
        R2(2) = STATS(1);
        au = [cm,cM,x,y,min(FM,255),u1,u2,R2];
        fit = [fit;au];
    else
        flag5 = [flag5;i];
        c0 = a(x,y,1:2);
        c =  reshape(c0,[],2);
        ac = [c,c,x,y,zeros(1,8)];
        fit = [fit;c];
    end
end
fprintf('亮度提取已完成！\n');
f5 = size(flag5,1);
if f5~=0
    fprintf('如下%d帧对象超出边缘，已提取中心亮度：\n',f5);
    fprintf('%d,',flag5);
    fprintf('\n');
end

%% 保存为Excel格式
columns = {'R-mean', 'G-mean', 'R-max', 'G-max', 'X', 'Y', 'R-fit', 'G-fit', 'XR-fit',...
    'XG-fit', 'YR-fit', 'YG-fit', 'R2', 'R2'};
fname = 'Fitting2.xlsx';
xlswrite(fname,columns,1,'A1')
xlswrite(fname,fit,1,'A2');