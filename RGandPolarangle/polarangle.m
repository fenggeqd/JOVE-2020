function polar=polarangle(RG)
% polarangle calculation
% input: all RG values
% output: all polar angles

RL=length(RG);%Rawlength
RminusG=zeros(RL,1);
for j=1:RL
    RminusG(j,1)=RG(j,1)-RG(j,2);
end
StoL=sort(RminusG);
y=std(StoL(1:30));%Standard deviation of the first 30 minimum values
z=std(StoL(RL-29:RL));%Standard deviation of the first 30 maximum values
RminusGMax=max(RminusG)-3*z;
RminusGMin=min(RminusG)+3*y;
SquareSin(:,1)=(RminusG-RminusGMin)./((RminusGMax-RminusGMin));%sin2q
for j=1:RL
    if SquareSin(j,1)>1
        SquareSin(j,1)=1;
    end
    if SquareSin(j,1)<0
        SquareSin(j,1)=0;
    end
end
polar(:,1)=180*asin(sqrt(SquareSin(:,1)))./pi;