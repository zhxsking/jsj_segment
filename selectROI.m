% �ֶ�ѡȡroi������Ϊѵ����
close all;
clear;
clc;
picName = 'res';
img = imread([picName,'.jpg']);
roiFileName = ['roi_',picName]; % ROI�ļ���

figure;imshow(img);
% ���һ����������
btn = uicontrol('Style', 'pushbutton', 'String', '����',...
    'Position', [20 20 50 20], 'Callback', @btn_down);
global flag

flag = 0;
msgbox('ȡ����','һ','help');
roi1 = []; %�����һ��roi
cnt = 0; %����
pause;
while ~flag
    cnt = cnt + 1;
    disp(['��',num2str(cnt),'��']);
    rect = floor(getrect());
    rectangle('position', rect, 'EdgeColor', 'y', 'LineWidth',1); %�������ο�
    roi1 = [roi1; rect];
    pause;
end

flag = 0;
msgbox('ȡ����','��','help');
roi2 = []; %����ڶ���roi
cnt = 0; %����
pause;
while ~flag
    cnt = cnt + 1;
    disp(['��',num2str(cnt),'��']);
    rect = floor(getrect());
    rectangle('position', rect, 'EdgeColor', 'b', 'LineWidth',1); %�������ο�
    roi2 = [roi2; rect];
    pause;
end

eval(['save ', roiFileName, ' roi1 roi2'])

% ��ʾROI���
% eval(['load ', roiFileName]);
% % load roi_1
% figure;imshow(img);
% for i=1:size(roi1,1)
%     rectangle('position', roi1(i,:), 'EdgeColor', 'y', 'LineWidth',1); %�������ο�
% end
% for i=1:size(roi2,1)
%     rectangle('position', roi2(i,:), 'EdgeColor', 'b', 'LineWidth',1); %�������ο�
% end

% ������Ӧ����
function btn_down(source,event)
    global flag
    flag = source.Value;
    disp('׼������');
end
