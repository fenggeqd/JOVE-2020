clc;
clear;
data=csvread('1541_Tracks.csv',1);
[m,~]=size(data);
tau=300/3614;%Frame spacing
%% %% Extract the number of points for each track
totalnum=data(m,1);
aa=zeros(totalnum+1,3);
aa(1:totalnum+1)=(0:totalnum)';
for i=1:totalnum+1
    pointnum=find(data(:,1)==aa(i,1));
    aa(i,2)=max(pointnum);
    aa(i,3)=min(pointnum);
end
%% 
RG(:,1:2)=zeros();
for i=1:totalnum+1
    Position=data(aa(i,3):aa(i,2),3:4);
    POSITION=xycoordination(Position);
    RrGg=zeros();
    [num,~]=size(POSITION);
    for j=1:num
        u=POSITION(j,2);
        v=POSITION(j,1);
        Img = imread('1541.tif',j);
        RrGg(j,1:2)=RGextraction(Img,u,v);
    end 
    RG=[RG;RrGg];
end
%% polarangle    
Polar=zeros();
polar=polarangle(RG);
for i=1:totalnum+1
    RL=aa(i,2)-aa(i,3)+1;
    Polar(1:RL,i)=polar(aa(i,3):aa(i,2),1);
end
%% save
xlswrite('result.xlsx',Polar);

