function RG=RGextraction(Img,u,v)
% extract R and G values of a frame
% input: data of tif images read by imread function;pixel position in images(u,v) 
% output: R and G values

ImgR = Img(:,:,1);
ImgG = Img(:,:,2);
[mima,nima]=size(ImgR);
if u>1 && u<mima && v>1 && v<nima
    ImgR1=ImgR(u-1:u+1,v-1:v+1);
    ImgG1=ImgG(u-1:u+1,v-1:v+1);
else
    ImgR1=ImgR(u,v);
    ImgG1=ImgG(u,v);
end
RG(1,1)=mean(mean(ImgR1));%The mean value of 9 pixels is similar to their Gaussian mean
RG(1,2)=mean(mean(ImgG1));
end