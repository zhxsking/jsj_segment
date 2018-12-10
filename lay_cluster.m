close all;
clear;clc;

img = imread('20180927-am4-1.jpg');
img = imresize(img, 0.25);
figure,imshow(img);

se = strel('disk', 5);
img_o = imopen(img, se);
img_or = imreconstruct(img_o, img);
img_ord = imdilate(img_or, se);
img_ordr = imreconstruct(imcomplement(img_ord), imcomplement(img_or));
img = imcomplement(img_ordr);
figure,imshow(img);

%% 
hsi = rgb2hsi(img);
lab = rgb2lab(img);
img_gray = rgb2gray(img);%?и░?ии?бе

[m, n, k] = size(img);
% position = ones(m*n, 2);
% for i=1:m
%     for j=1:n
%         position((i-1)*m+j, 1) = j;
%         position((i-1)*m+j, 2) = i;
%     end
% end
data_rgb = double(reshape(img, m*n, k));
data_hsi = double(reshape(hsi, m*n, k));
data_lab = double(reshape(lab, m*n, k));
data = [data_rgb, data_hsi, data_lab];

[idx, c] = kmeans(data_rgb, 2, 'Distance', 'sqeuclidean');

ind = idx - 1;
ind = reshape(ind, m, n);

% res = img_gray;
% res(ind==0) = 0;
% res(ind==1) = 128;
% res(ind==2) = 255;

res = img .* uint8(ind);
figure,imshow(res);