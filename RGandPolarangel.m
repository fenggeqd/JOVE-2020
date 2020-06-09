clc;
clear;
data=csvread('1541_Tracks.csv',1,0);
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
for i=1:totalnum+1
    Position=data(aa(i,3):aa(i,2),3:4);
    RL=aa(i,2)-aa(i,3)+1;%Rawlength 
    POSITION=round(Position);
    POSITION=POSITION+1;%coordinate unification
    RG=zeros();
    [num,~]=size(POSITION);
    for j=1:num
        Img = imread('1541.tif',j);
        ImgR = Img(:,:,1);
        ImgG = Img(:,:,2);
        u=POSITION(j,1);
        v=POSITION(j,2);
        if u>3 && u<496 && v>3 && v<590
            ImgR1=ImgR(u-3:u+3,v-3:v+3);
            ImgG1=ImgG(u-3:u+3,v-3:v+3);
        else
            ImgR1=ImgR(u-1,v-1);
            ImgG1=ImgG(u-1,v-1);
        end
        RG(j,1)=mean(mean(ImgR1));%The mean value of 9 pixels is similar to their Gaussian mean
        RG(j,2)=mean(mean(ImgG1));
    end
    % polarangle
    Polar=zeros();

    RminusG=zeros(m,1);
    for j=1:RL
        RminusG(j,1)=RG(j,1)-RG(j,2);
    end
    StoL=sort(RminusG);
    y=std(StoL(1:30));%Standard deviation of the first 30 minimum values
    z=std(StoL(m-29:m));%Standard deviation of the first 30 maximum values
    RminusGMax=max(RminusG)-3*z;
    RminusGMin=min(RminusG)+3*y;
    SquareSin(1:RL,1)=(RminusG(1:RL)-RminusGMin)/((RminusGMax-RminusGMin));%sin2q
    for j=1:RL
        if SquareSin(j,1)>1
            SquareSin(j,1)=1;
        end
        if SquareSin(j,1)<0
            SquareSin(j,1)=0;
        end
    end
    Polar(1:RL,i)=180*asin(sqrt(SquareSin(1:RL,1)))/pi;  
end
xlswrite('result.xlsx',Polar);

