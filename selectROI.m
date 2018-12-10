% 手动选取roi区域作为训练集
close all;
clear;
clc;
picName = 'res';
img = imread([picName,'.jpg']);
roiFileName = ['roi_',picName]; % ROI文件名

figure;imshow(img);
% 添加一个结束按键
btn = uicontrol('Style', 'pushbutton', 'String', '结束',...
    'Position', [20 20 50 20], 'Callback', @btn_down);
global flag

flag = 0;
msgbox('取倒伏','一','help');
roi1 = []; %保存第一类roi
cnt = 0; %计数
pause;
while ~flag
    cnt = cnt + 1;
    disp(['第',num2str(cnt),'个']);
    rect = floor(getrect());
    rectangle('position', rect, 'EdgeColor', 'y', 'LineWidth',1); %画出矩形框
    roi1 = [roi1; rect];
    pause;
end

flag = 0;
msgbox('取正常','二','help');
roi2 = []; %保存第二类roi
cnt = 0; %计数
pause;
while ~flag
    cnt = cnt + 1;
    disp(['第',num2str(cnt),'个']);
    rect = floor(getrect());
    rectangle('position', rect, 'EdgeColor', 'b', 'LineWidth',1); %画出矩形框
    roi2 = [roi2; rect];
    pause;
end

eval(['save ', roiFileName, ' roi1 roi2'])

% 显示ROI结果
% eval(['load ', roiFileName]);
% % load roi_1
% figure;imshow(img);
% for i=1:size(roi1,1)
%     rectangle('position', roi1(i,:), 'EdgeColor', 'y', 'LineWidth',1); %画出矩形框
% end
% for i=1:size(roi2,1)
%     rectangle('position', roi2(i,:), 'EdgeColor', 'b', 'LineWidth',1); %画出矩形框
% end

% 按键响应函数
function btn_down(source,event)
    global flag
    flag = source.Value;
    disp('准备结束');
end
