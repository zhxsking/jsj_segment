close all;
clear;
clc;

picName = 'res';
img = imread([picName,'.jpg']);
scale = 0.25;
img = imresize(img, scale); % ��СͼƬ��������
img = im2double(img);

tic; 
hsv = rgb2hsv(img);
ycbcr = rgb2ycbcr(img);
toc;

tic;
st = stdfilt(img, true(3));toc;tic;
ra = rangefilt(img, true(3));
toc;
fea_mat = cat(3,img,hsv,ycbcr,st,ra);

load modle-tree-res % ����ģ��

% Ԥ��
[m,n,k] = size(img);
preddata = double(reshape(fea_mat,m*n,[]));
preddata = mapminmax('apply', preddata', ps);
preddata = preddata';
predlab = predict(mdl_tree, preddata);
% ����
bw = reshape(predlab, m, n);
% figure;imshow(bw);
bw1 = bwareaopen(bw,500);
% figure;imshow(bw1);
bwf = fillsmallholes(bw1, 100);
% figure;imshow(bwf);

res = bwf .* img;
ratio = (1 - sum(sum(bwf)) ./ (m .* n)) .* 100; % ����ռ��
ratio = round(ratio, 2); % ����2λС��
figure;
subplot(121);imshow(img);title('ԭͼ')
subplot(122);imshow(res);title(['���ͼ������ռ��Ϊ', num2str(ratio), '%'])
imwrite(res,[picName,'-res.jpg']);


