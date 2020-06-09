clear,clc
% ����particle-analyze׷�ٵĽ��
%% ��ȡ����
%[fname,pname]=uigetfile( '*.tif','ѡ��ԭͼ��');
%if fname(1)==0, return; end
%tname = [pname,fname];
tname = '2-1.tif'; %ԭʼͼ����
info = imfinfo(tname);
k = length(info); %֡��
sy = info.Width;
sx = info.Height;
%xlsreadֻ��ȡ���ֲ���
results = xlsread('Results.xlsx'); %ImageJ_particle_analyze����ļ���
%[Num1,Area2,Mean3,Min4,Max5,X6,Y7,XM8,YM9,Major10,Minor11,Angle12,Slice13]
%������Ž����ο�������μ������Results.csv�ļ�

%%
%ImageJ-MATLAB transform����[X,Y]����
A = results(:,3); %ImageJ��Area���Ӧ�������ֶ��޸ģ�
Y = results(:,5); %ImageJ��X�����Ӧ�������ֶ��޸ģ�
X = results(:,6); %ImageJ��Y�����Ӧ�������ֶ��޸ģ�
Slice = results(:,11); %ImageJ��֡������Ӧ�������ֶ��޸ģ�
particle = [X,Y,Slice,A];

%% ����ɸѡ��Ԥ��У����
% ������
flag1 = []; %��֡����
flag2 = []; %��֡����
flag3 = []; %��������֡����
if length(find(Slice==1))~=1
    fprintf('�����һ֡����ֻ��һ������\n');
    return;
end
for i = 1:k
    z = find(particle(:,3)==i);
    c = length(z);
    %������
    if  c == 0
        flag1 = [flag1;i];
        insert = [particle(i-1,1),particle(i-1,2),i,particle(i-1,4)];
        particle = [particle(1:i-1,:);insert;particle(i:end,:)];
    elseif c>1
        flag2 = [flag2;i];
        R = (particle(z,1)-particle(i-1,1)).^2+(particle(z,2)-particle(i-1,2)).^2;
        [~,w1] = min(R); %���ھ���
        [~,w2] = max(particle(z,4)); %�������
        if w1~=w2
            flag3 = [flag3;i];
        end
        z(w1) = [];
        particle(z,:) = [];
    end
end
fs1 = size(flag1,1);
if ~isempty(flag1)
    fprintf('����%d֡δ��������ѻ���ǰ��֡λ�ò�ȫ��\n',fs1);
    fprintf('%d,',flag1);
    fprintf('\n');
    r1 = input('�Ƿ�������ǿ�����ǣ�1����0��\n');
    if r1 ~= 0
        fprintf('�룡\n');
        return;
    end
end
if ~isempty(flag3)
    fprintf('����֡��⵽��������ѻ���ǰ��֡λ��ɸѡ��\n');
    fprintf('%d,',flag3);
    fprintf('\n');
    r2 = input('�Ƿ�������ǿ�����ǣ�1����0��\n');
    if r2 ~= 0
        fprintf('�룡\n');
        return;
    end
end
%�ٲ�ȫ
for i = 1:fs1
    q0 = flag1(i);
    q1 = q0-1; %ǰһʵ֡����
    q2 = min(Slice(Slice>q1)); %��һʵ֡����
    particle(q0,1:2) = (particle(q2,1:2)+(q2-q0)*particle(q1,1:2))/(q2-q0+1);
end
if size(particle,1) == k
    fprintf('*****1��Ԥ��������ɣ�*****\n');
else
    fprintf('Ԥ����������\n');
    return;
end
%���ˣ�������ÿ֡����ֻ��һ����׼ȷλ�á�

%% ���Ϲ켣-�ض�λ
dw = 5; %����ֱ��(dw=r+2)��������
list=[];
flag4 = []; %�ض�λʧЧ֡����
for i = 1 : k
    b = double(imread(tname,i)); %��ȡ8bitͼ��
    pk = round(particle(i,1:2));
    interactive = 0; %ͼ��
    cnt = cntrd(b,pk,dw,interactive); %����
    if isempty(cnt)||isnan(cnt(1))
        add = particle(i,1:3); %[X,Y,Slice]
        flag4 = [flag4;i];
    else
        add = [cnt(1,1:2),i]; %[X,Y,Slice]
    end
    list = [list;add]; %[X,Y,Slice]
end
fprintf('*****2�������ض�λ����ɣ�*****\n');
fs4 = size(flag4,1);
if fs4 ~= 0
    fprintf('����%d֡��ȡ���ض�λ��\n',fs4);
    fprintf('%d,',flag4);
    fprintf('\n');
end

%% track
maxdisp = 15; %�ƶ����룬���޸�
%tr = track(list,maxdisp); %[X,Y,Slice,Num]
%tr = [list,ones(size(list,1),1)];
param.mem = 0; %ʧ��֡��
param.dim = 2; %����ά��
param.good = floor(k*.01); %��ֵ֡��
param.quiet = 1; %1:��������ʾ
tr = track(list,maxdisp,param); %[X,Y,Slice,Num]
%save ('tr.mat','tr'); %����

%����-plot
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
    fprintf('*****3���Ѽ������켣��*****\n');
elseif ki==0
    fprintf('δ�������켣�����޸Ĳ�����\n');
    return;
else
    fprintf('����켣����һ�������޸Ĳ�����\n');
    return;
end

%% ӳ��
%ǰ�᣺�õ����Ĺ켣tr
%load ('tr.mat')
mean = [];
rp = 3;
flag5 = []; %�뾶����
for i = 1:k
    a = double(imread(tname,i)); %��ͨ��
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
fprintf('*****4��������ȡ����ɣ�*****\n');
f5 = size(flag5,1);
if f5~=0
    fprintf('����%d֡���󳬳���Ե������ȡ�������ȣ�\n',f5);
    fprintf('%d,',flag5);
    fprintf('\n');
end
xlswrite('mean.xlsx',mean); %����ΪExcel��ʽ