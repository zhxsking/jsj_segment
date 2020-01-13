close all;
clear;clc;
rng(1); % ���seed

pic_type = 'rgb';
picPath = ['D:\pic\jiansanjiang\contrast\', pic_type, '\img\', pic_type, '.jpg'];
img = imread(picPath);

scale = 0.25;
img = imresize(img, scale); % ��СͼƬ��������
img = im2double(img);

[m, n, k] = size(img);
preddata = single(reshape(img, m*n, k));

tic;
predlab = kmeans(preddata, 2, 'Distance', 'sqeuclidean');
toc;

bw = reshape(predlab - 1, m, n);
figure,imshow(bw);

