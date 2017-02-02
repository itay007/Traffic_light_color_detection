% Author: Itay Levitan & Amir Bushari
% e-mail: itay007@gmail.com & amirbushari@gmail.com
% Release: 1.0
% Release date: 17/1/2017


%% Read in image
%I=imread('Green_Light_Israel.png'); %read image
%I=imread('Red_Light_Israel.jpg'); %read image
%Io=imread('IMG_20161212_150010.jpg'); %read image 
%Io=imread('IMG_20161212_145937.jpg'); %read image 
Io=imread('IMG_20161218_132941.jpg'); %read image 
%I=imread('Green_Light_Israel1.jpg'); %read image

I = imresize(Io,0.13);

figure(1);
imshow(I);
title('Original Image')

%% RGB color space
rmat=I(:,:,1);
gmat=I(:,:,2);
bmat=I(:,:,3);


%% Color space to BW
levelr=0.32;
levelg=0.3;
levelb=0.32;
Ir=im2bw(rmat,levelr);
Ig=im2bw(gmat,levelg);
Ib=im2bw(bmat,levelb);

figure(2);
subplot(3,3,1), imshow(Ir);
title('2: Red Plane')
subplot(3,3,2), imshow(Ig);
title('3: Green Plane')
subplot(3,3,3), imshow(Ib);
title('4: Blue Plane')


%% Incomplement BW
Ir_c= imcomplement(Ir);
Ig_c= imcomplement(Ig);
Ib_c= imcomplement(Ib);

Isum_c=(Ir_c & Ig_c & Ib_c);

figure(4);
imshow(Isum_c);
title('xx: sum')

%% Find circular shape in the object

[centers_s_s, radii_s_s] = imfindcircles(Isum_c,[1 20],'ObjectPolarity','dark','Sensitivity',0.75);


figure(3);
imshow(Isum_c);
viscircles(centers_s_s, radii_s_s);
title('10: Isum')



%% Color detection

P = impixel(I,centers_s_s(:,1),centers_s_s(:,2));

figure(4);
imshow(I);
title('14: Result')

red=[1, 0, 0];
green=[0, 1, 0];
yellow=[1, 1, 0];

for i=1:size(P,1)
    R=P(i,1)/255;
    G=P(i,2)/255;
    B=P(i,3)/255;
    [clr,rgb] = colornames('HTML4', [R,G,B]);
        if strcmp(clr{1,1},'Red') ||strcmp(clr{1,1},'Green')||strcmp(clr{1,1},'Yellow')
            disp(clr{1,1});
            flag=i;
            viscircles(centers_s_s(flag,:),radii_s_s(flag,:));
        end
end





