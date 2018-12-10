% 校正S3多光谱相机预处理后的图像，先选择定标板图像，后选择待处理图像，
% 鼠标选择定标板白板部分，即自动校正保存为geotiff图像
clc;clear;
close all;
% 选择基准图片
[bg_file, bg_path] = uigetfile({'*.jpg; *.png; *.gif; *.tif';'*.*'},'选择基准图片');
if isequal(bg_file,0)||isequal(bg_path,0)
    msgbox('基准图未选择', 'warn' ,'help');
    return;
end
img_cali = imread([bg_path,bg_file]); % 基准图片
% 选择待处理图片
[file, path] = uigetfile({'*.jpg; *.png; *.gif; *.tif';'*.*'},'选择待处理图片',bg_path);
if isequal(file,0)||isequal(path,0)
    msgbox('待处理图未选择', 'warn' ,'help');
    return;
end

% 选择白板区域
figure,imshow(img_cali)
rect = getrect;
roi = imcrop(img_cali, rect);
figure,imshow(roi)
% 求基准计算相对反射率
tic;
param = mean(mean(roi));
% 带地理信息读取待处理tiff图像
[tiff, R] = geotiffread([path,file]);
info = geotiffinfo([path,file]);
% 分块处理
[~,name,~] = fileparts(file);
tiff_out = blockproc(tiff, [1024 1024], @(img)calc(img, param));
% 保存为geotiff文件
tiffTags = struct('TileLength',1024,'TileWidth',1024,'Compression','LZW');
geotiffwrite([path,name,'-cali.tif'], tiff_out, R,...
    'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag,...
    'TiffTags',tiffTags)
% 显示结果
res = imread([path,name,'-cali.tif']);
figure,imshow(res);
toc;

% 标定处理函数
function res = calc(img, param)
img = img.data;
if (size(img, 3) == 4)
    img(:,:,4) = [];
end
res = double(img) ./ param;
res = uint8(res .* 255);
end

