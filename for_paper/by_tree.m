close all;
clear;clc;
rng(1); % ���seed

pic_type = 'rgb';
picPath = ['D:\pic\jiansanjiang\contrast\', pic_type, '\img\', pic_type, '.jpg'];
img = imread(picPath);
roiFileName = ['roi_', pic_type]; % ROI�ļ���

scale = 0.25;
img = imresize(img, scale); % ��СͼƬ��������
img = im2double(img);
hsv = rgb2hsv(img);
ycbcr = rgb2ycbcr(img);
lab = rgb2lab(img);

eval(['load ', roiFileName]);
fea_mat = cat(3,img,hsv,ycbcr,lab);

% ����roi1ȡ��һ������
data1 = [];
roi1 = fix(roi1 * scale);
for i=1:size(roi1,1)
    tmp = fea_mat(roi1(i,2):roi1(i,2)+roi1(i,4)-1,...
        roi1(i,1):roi1(i,1)+roi1(i,3)-1,:);
    tmp = reshape(tmp,[],size(fea_mat,3));
    data1 = [data1; tmp];
end
% ����roi2ȡ�ڶ�������
data2 = [];
roi2 = fix(roi2 * scale);
for i=1:size(roi2,1)
    tmp = fea_mat(roi2(i,2):roi2(i,2)+roi2(i,4)-1,...
        roi2(i,1):roi2(i,1)+roi2(i,3)-1,:);
    tmp = reshape(tmp,[],size(fea_mat,3));
    data2 = [data2; tmp];
end

data = double([data1; data2]);
[data, ps] = mapminmax(data'); % ��һ��
data = data';
label = [ones(size(data1,1),1); zeros(size(data2,1),1)];

% ��������
A = [data, label];
B = A(randperm(size(A,1)), :);

% ���ݻ���ѵ��������֤�������Լ�
[trainsamp, valsamp, testsamp] = dividerand(B',0.7,0.15,0.15);
[trainsamp, valsamp, testsamp] = deal(trainsamp', valsamp', testsamp');
s_d = size(B,2);
[traindata, trainlab] = deal(trainsamp(:,1:s_d-1), trainsamp(:,s_d));
[valdata, vallab] = deal(valsamp(:,1:s_d-1), valsamp(:,s_d));
[testdata, testlab] = deal(testsamp(:,1:s_d-1), testsamp(:,s_d));

% ѵ��
mdl_tree = fitctree(traindata, trainlab,'MaxNumSplits',50);
% view(mdl_tree,'Mode','graph');
eval(['save modle-tree-', pic_type, ' mdl_tree ps'])

% ��֤
lab = predict(mdl_tree, valdata);
acc = 1 - sum(lab ~= vallab) / size(lab,1);
disp(['��֤��׼ȷ�ʣ�', num2str(acc)]);

%% Ԥ��
[m,n,k] = size(img);
preddata = double(reshape(fea_mat,m*n,[]));
preddata = mapminmax('apply', preddata', ps);
preddata = preddata';
test_batch = 40000;
predlab = zeros(size(preddata,1), 1);
tic;
for i=1:ceil(size(preddata,1)/test_batch)
    end_pos = i*test_batch;
    if end_pos > size(preddata,1)
        end_pos = size(preddata,1);
    end
    predlab_tmp = predict(mdl_tree, preddata(1+(i-1)*test_batch:end_pos, :));
    predlab(1+(i-1)*test_batch:end_pos, :) = predlab_tmp;
end
toc;

% ����dice
bw = reshape(predlab, m, n);
figure;imshow(bw);

gt_Path = ['D:\pic\jiansanjiang\contrast\', pic_type, '\mask\', pic_type, '.jpg'];
gt = imread(gt_Path);
gt = imresize(gt, scale); % ��СͼƬ��������
gt(gt~=0) = 1;
figure;imshow(gt,[]);

dice = 2*double(sum(uint8(bw(:) & gt(:)))) / double(sum(uint8(bw(:))) + sum(uint8(gt(:))));
disp(['dice: ', num2str(dice)])





