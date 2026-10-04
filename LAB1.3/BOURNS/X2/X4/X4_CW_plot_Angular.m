clear; clc; close all;

files = {
    'BOURNS_X4_CW_1.xlsx'
    'BOURNS_X4_CW_2.xlsx'
    'BOURNS_X4_CW_3.xlsx'
    'BOURNS_X4_CWW_1.xlsx'
    'BOURNS_X4_CwW_2.xlsx'
    'BOURNS_X4_CWW_3.xlsx'
};

PPR  = 24;
mode = 4;
CPR  = PPR * mode;       % 96 counts/rev

% สร้างกราฟพื้นหลังขาว
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

for i = 1:3
    T = readtable(files{i});

    % หาจุดสิ้นสุดของการกด Home
    idxHome = find(T.home_trigger == 1,1,'last');

    if isempty(idxHome)
        error('ไม่พบ home_trigger ในไฟล์ %s',files{i});
    end

    % เริ่มใช้ข้อมูลหลังการ Homing
    idx = idxHome:length(T.time);

    time  = T.time(idx);
    count = T.homed_count(idx);

    % ทำให้ทุกชุดเริ่มต้นจากศูนย์
    time  = time-time(1);
    count = count-count(1);

    % แปลง Count เป็นองศา
    degree = count*360/CPR;

    plot(ax,time,degree,...
        'LineWidth',1.6,...
        'DisplayName',['รอบที่ ',num2str(i)]);
end

% เส้นค่าทฤษฎี
hTheory = yline(ax,360,'--k',' 360°',...
    'LineWidth',1.2,...
    'HandleVisibility','off');

hTheory.FontSize = 11;
hTheory.FontWeight = 'bold';
hTheory.LabelHorizontalAlignment = 'right';
hTheory.LabelVerticalAlignment = 'bottom';

% ชื่อกราฟและชื่อแกน
xlabel(ax,'Time (s)',...
    'Color','k',...
    'FontSize',13);

ylabel(ax,'Angular position (degree)',...
    'Color','k',...
    'FontSize',13);

title(ax,'BOURNS X4 CW: Angular Position vs Time',...
    'Color','k',...
    'FontSize',14,...
    'FontWeight','bold');

% Legend
lgd = legend(ax,'Location','best');
lgd.TextColor = 'k';
lgd.Color = 'w';
lgd.EdgeColor = 'k';
lgd.FontSize = 11;

grid(ax,'on');
grid(ax,'minor');

xlim(ax,[0 inf]);
ylim(ax,[-20 400]);

box(ax,'on');

% กำหนดขนาดภาพ
fig.Position = [100 100 1100 650];

% บันทึกภาพความละเอียดสูงสำหรับใส่รายงาน
exportgraphics(fig,'BOURNS_X4_CW_AngularPosition.png',...
    'Resolution',300);