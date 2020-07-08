% CSV数据提取处理
clear;
clc;
tic
data=csvread('1527_Tracks.csv',1,0);
[m,~]=size(data);
tau=300/3614;%Frame spacing
data(:,5)=data(:,3)*5.86/60;%xposition
data(:,6)=data(:,4)*5.86/60;%yposition
data(2:end,8)=sqrt((data(2:end,5)-data(1:end-1,5)).^2+(data(2:end,6)-data(1:end-1,6)).^2);%step size
data(:,9)=data(:,8)./tau;%velocity
%turnig angle
for k=3:m
    A=[data(k-1,5)-data(k-2,5),data(k-1,6)-data(k-2,6)];
    B=[data(k,5)-data(k-1,5),data(k,6)-data(k-1,6)];
    if norm(A)==0||norm(B)==0
        data(k,10)=200;%nan
    else
        data(k,10)=180*acos(dot(A,B)/(norm(A)*norm(B)))/pi;%cos∠(A,B) =A·B/(|A||B|).
    end
end
%%  title=['label','time','X','Y','x','y','displacement','stepsize','velocity','turningangle','MSD','Dt','alpha'];
%% Extract the number of points for each track
totalnum=data(m,1);
aa=zeros(totalnum+1,3);
aa(1:totalnum+1,1)=(0:totalnum)';
for i=1:totalnum+1
    pointnum=find(data(:,1)==aa(i,1));
    aa(i,2)=max(pointnum);
    aa(i,3)=min(pointnum);
    data(aa(i,3),8:10)=nan;
    data(aa(i,3)+1,10)=nan;
end
%% 
for i=1:totalnum+1
    data1=data(aa(i,3):aa(i,2),:);
    data1(:,2)=data1(:,2)*tau;
    RL=aa(i,2)-aa(i,3)+1;%Rawlength 
    data(aa(i,3):aa(i,2),7)=sqrt((data1(:,5)-data1(1,5)).^2+(data1(:,6)-data1(1,6)).^2);% displacement pdist函数
    maxdis(i,1)=max(data(aa(i,3):aa(i,2),7));
    %% Rg
    Rg2=0;
    for iii=1:RL
        Rg2=Rg2+((data1(iii,5)-mean(data1(:,5)))^2+(data1(iii,6)-mean(data1(:,6)))^2); 
    end
    data(i,14)=sqrt(Rg2/RL);%meanRg
    if data(i,14)>0.5
        data(aa(i,3):aa(i,2),15)=1;
    else
        data(aa(i,3):aa(i,2),15)=0;
    end
end
data(1:totalnum+1,11)=(0:totalnum)';
xlswrite('result.xlsx',data,1);
xlswrite('result.xlsx',MSD,2);
xlswrite('result.xlsx',maxdis,3);
toc
disp(['运行时间: ',num2str(toc)]);
