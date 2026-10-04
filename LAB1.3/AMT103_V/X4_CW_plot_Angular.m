clear; clc; close all;

files = {
    'AMT103_X4_CW_1.xlsx'
    'AMT103_X4_CW_2.xlsx'
    'AMT103_X4_CW_3.xlsx'
};

PPR  = 2048;
mode = 4;
CPR  = PPR*mode;          % 24 counts/rev

fig = figure('Color','w');
ax = axes(fig);

ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.65 0.65 0.65];
ax.MinorGridColor = [0.80 0.80 0.80];
ax.FontName = 'Arial';
ax.FontSize = 12;

hold(ax,'on');

maxTime = 0;

for i = 1:length(files)

    T = readtable(files{i},...
        'VariableNamingRule','preserve');

    % ตรวจว่ามีคอลัมน์ที่ต้องใช้
    if ~ismember('home_trigger',T.Properties.VariableNames)
        error('ไม่พบคอลัมน์ home_trigger ในไฟล์ %s',files{i});
    end

    if ~ismember('homed_count',T.Properties.VariableNames)
        error('ไม่พบคอลัมน์ homed_count ในไฟล์ %s',files{i});
    end

    % หาตำแหน่งสุดท้ายที่กด Home
    idxHome = find(T.home_trigger == 1,1,'last');

    if isempty(idxHome)
        error('ไม่พบการกด Home ในไฟล์ %s',files{i});
    end

    % เริ่มจากตัวอย่างถัดจากการปล่อย Home
    idxStart = idxHome+1;

    if idxStart > height(T)
        error('ไม่มีข้อมูลหลัง Home ในไฟล์ %s',files{i});
    end

    time  = double(T.time(idxStart:end));
    count = double(T.homed_count(idxStart:end));

    % ทำให้เริ่มจากศูนย์
    time  = time-time(1);
    count = count-count(1);

    % แปลง Count เป็นองศา
    degree = count*360/CPR;

    % X1 มีลักษณะขั้นบันได จึงใช้ stairs
    stairs(ax,time,degree,...
        'LineWidth',1.6,...
        'DisplayName',['รอบที่ ',num2str(i)]);

    maxTime = max(maxTime,time(end));

    % แสดงค่าตรวจสอบใน Command Window
    fprintf('รอบที่ %d: Final count = %.0f, Final degree = %.2f°\n',...
        i,count(end),degree(end));
end

% เส้นค่าทฤษฎี
hTheory = yline(ax,360,'--k',' 360°',...
    'LineWidth',1.2,...
    'HandleVisibility','off');

hTheory.FontSize = 11;
hTheory.FontWeight = 'bold';
hTheory.LabelHorizontalAlignment = 'right';
hTheory.LabelVerticalAlignment = 'bottom';

xlabel(ax,'Time (s)',...
    'Color','k',...
    'FontSize',13);

ylabel(ax,'Angular position (degree)',...
    'Color','k',...
    'FontSize',13);

% ชื่อกราฟ
title(ax,'AMT103 X4 CW: Angular Position vs Time',...
    'Color','k',...
    'FontSize',14,...
    'FontWeight','bold');

lgd = legend(ax,'Location','best');
lgd.TextColor = 'k';
lgd.Color = 'w';
lgd.EdgeColor = 'k';
lgd.FontSize = 11;

grid(ax,'on');
grid(ax,'minor');
box(ax,'on');

xlim(ax,[0 maxTime]);
ylim(ax,[-20 400]);

fig.Position = [100 100 1100 650];

% แก้ชื่อไฟล์
exportgraphics(fig,...
    'AMT103_X4_CW_AngularPosition.png',...
    'Resolution',300);