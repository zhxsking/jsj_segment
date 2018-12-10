% У��S3��������Ԥ������ͼ����ѡ�񶨱��ͼ�񣬺�ѡ�������ͼ��
% ���ѡ�񶨱��װ岿�֣����Զ�У������Ϊgeotiffͼ��
clc;clear;
close all;
% ѡ���׼ͼƬ
[bg_file, bg_path] = uigetfile({'*.jpg; *.png; *.gif; *.tif';'*.*'},'ѡ���׼ͼƬ');
if isequal(bg_file,0)||isequal(bg_path,0)
    msgbox('��׼ͼδѡ��', 'warn' ,'help');
    return;
end
img_cali = imread([bg_path,bg_file]); % ��׼ͼƬ
% ѡ�������ͼƬ
[file, path] = uigetfile({'*.jpg; *.png; *.gif; *.tif';'*.*'},'ѡ�������ͼƬ',bg_path);
if isequal(file,0)||isequal(path,0)
    msgbox('������ͼδѡ��', 'warn' ,'help');
    return;
end

% ѡ��װ�����
figure,imshow(img_cali)
rect = getrect;
roi = imcrop(img_cali, rect);
figure,imshow(roi)
% ���׼������Է�����
tic;
param = mean(mean(roi));
% ��������Ϣ��ȡ������tiffͼ��
[tiff, R] = geotiffread([path,file]);
info = geotiffinfo([path,file]);
% �ֿ鴦��
[~,name,~] = fileparts(file);
tiff_out = blockproc(tiff, [1024 1024], @(img)calc(img, param));
% ����Ϊgeotiff�ļ�
tiffTags = struct('TileLength',1024,'TileWidth',1024,'Compression','LZW');
geotiffwrite([path,name,'-cali.tif'], tiff_out, R,...
    'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag,...
    'TiffTags',tiffTags)
% ��ʾ���
res = imread([path,name,'-cali.tif']);
figure,imshow(res);
toc;

% �궨������
function res = calc(img, param)
img = img.data;
if (size(img, 3) == 4)
    img(:,:,4) = [];
end
res = double(img) ./ param;
res = uint8(res .* 255);
end

