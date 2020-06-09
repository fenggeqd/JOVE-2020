% CSV数据提取处理
clear;
clc;
tic
data=csvread('1527_Tracks.csv',1,0);
[m,~]=size(data);
tau=300/3614;%Frame spacing
data(:,5)=data(:,3)*5.86/60;%xposition
data(:,6)=data(:,4)*5.86/60;%yposition
%%  title=['label','time','X','Y','x','y','displacement','stepsize','velocity','turningangle','MSD','Dt','alpha'];
%% Extract the number of points for each track
totalnum=data(m,1);%Number of tracks
aa=zeros(totalnum+1,3);
aa(1:totalnum+1,1)=(0:totalnum)';
for i=1:totalnum+1
    pointnum=find(data(:,1)==aa(i,1));
    aa(i,2)=max(pointnum);
    aa(i,3)=min(pointnum);
    data(aa(i,3),8:10)=nan;
    data(aa(i,3)+1,10)=nan;
end
%% MSD、Dt、α
for i=1:totalnum+1
    data1=data(aa(i,3):aa(i,2),:);
    data1(:,2)=data1(:,2)*tau;
    RL=aa(i,2)-aa(i,3)+1;%Rawlength 
    %% MSD Dt alpha
    msdn=30;
    for ii=1:msdn
        sum=0;
        for jj=1:RL-ii
            sum=sum+(data1(jj+ii,5)-data1(jj,5))^2+(data1(jj+ii,6)-data1(jj,6))^2;
        end
        MSD(ii,i)=sum/(RL-ii);%MSD
    end
end
xlswrite('result.xlsx',MSD);
toc
disp(['运行时间: ',num2str(toc)]);
