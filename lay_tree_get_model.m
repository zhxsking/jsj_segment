close all;
clear;
clc;

picName = 'res';
img = imread([picName,'.jpg']);
scale = 0.25;
img = imresize(img, scale); % 缩小图片加速运行
img = im2double(img);

tic;
hsv = rgb2hsv(img);
ycbcr = rgb2ycbcr(img);
toc;

tic;
st = stdfilt(img, true(3));toc;tic;
ra = rangefilt(img, true(3));
toc;

% eval(['load roi_',picName]);
load roi_res
% 根据roi1取第一类样本
fea_mat = cat(3,img,hsv,ycbcr,st,ra);

data1 = [];
roi1 = fix(roi1 * scale);
for i=1:size(roi1,1)
    tmp = fea_mat(roi1(i,2):roi1(i,2)+roi1(i,4)-1,...
        roi1(i,1):roi1(i,1)+roi1(i,3)-1,:);
    tmp = reshape(tmp,[],size(fea_mat,3));
    data1 = [data1; tmp];
end
% 根据roi2取第二类样本
data2 = [];
roi2 = fix(roi2 * scale);
for i=1:size(roi2,1)
    tmp = fea_mat(roi2(i,2):roi2(i,2)+roi2(i,4)-1,...
        roi2(i,1):roi2(i,1)+roi2(i,3)-1,:);
    tmp = reshape(tmp,[],size(fea_mat,3));
    data2 = [data2; tmp];
end

data = double([data1; data2]);
[data, ps] = mapminmax(data'); % 归一化
data = data';
label = [zeros(size(data1,1),1); ones(size(data2,1),1)];
% 打乱数据
A = [data, label];
rng(1); % 随机seed
B = A(randperm(size(A,1)), :);
% 数据划分训练集、验证集、测试集
[trainsamp, valsamp, testsamp] = dividerand(B',0.7,0.15,0.15);
[trainsamp, valsamp, testsamp] = deal(trainsamp', valsamp', testsamp');
s_d = size(B,2);
[traindata, trainlab] = deal(trainsamp(:,1:s_d-1), trainsamp(:,s_d));
[valdata, vallab] = deal(valsamp(:,1:s_d-1), valsamp(:,s_d));
[testdata, testlab] = deal(testsamp(:,1:s_d-1), testsamp(:,s_d));

% 训练
% mdl_tree = fitctree(traindata, trainlab,'MaxNumSplits',10,'CrossVal','on');
% view(mdl_tree.Trained{1},'Mode','graph');
% lab = kfoldPredict(mdl_tree);
mdl_tree = fitctree(traindata, trainlab,'MaxNumSplits',10);
% view(mdl_tree,'Mode','graph');
eval(['save modle-tree-',picName,' mdl_tree ps'])

lab = predict(mdl_tree, valdata);
acc = 1 - sum(lab ~= vallab) / size(lab,1);
disp(['验证集准确率：', num2str(acc)]);
% 自变量权重
imp = predictorImportance(mdl_tree);

figure;
bar(1:size(traindata,2), imp);
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
xticks(1:size(traindata,2));
h = gca;
h.XTickLabel = mdl_tree.PredictorNames;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
% 预测
[m,n,k] = size(img);
preddata = double(reshape(fea_mat,m*n,[]));
preddata = mapminmax('apply', preddata', ps);
preddata = preddata';
predlab = predict(mdl_tree, preddata);
% 后处理
bw = reshape(predlab, m, n);
% figure;imshow(bw);
bw1 = bwareaopen(bw,500);
% figure;imshow(bw1);
bwf = fillsmallholes(bw1, 100);
% figure;imshow(bwf);

res = bwf .* img;
ratio = (1 - sum(sum(bwf)) ./ (m .* n)) .* 100; % 倒伏占比
ratio = round(ratio, 2); % 保留2位小数
figure;
subplot(121);imshow(img);title('原图')
subplot(122);imshow(res);title(['结果图，受灾占比为', num2str(ratio), '%'])
imwrite(res,[picName,'-res.jpg']);


