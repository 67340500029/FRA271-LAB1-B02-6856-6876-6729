clear; clc; close all;

CW  = readtable('BOURNS_X4_CW_1.xlsx',...
    'VariableNamingRule','preserve');

CCW = readtable('BOURNS_X4_CCW_1.xlsx',...
    'VariableNamingRule','preserve');

PPR  = 24;
mode = 4;
CPR  = PPR*mode;       % 96 counts/rev

% หาจุดสิ้นสุดการกด Home
idxHomeCW = find(CW.home_trigger == 1,1,'last');
idxHomeCCW = find(CCW.home_trigger == 1,1,'last');

if isempty(idxHomeCW) || isempty(idxHomeCCW)
    error('ไม่พบ home_trigger ในไฟล์ CW หรือ CCW');
end

% ตัดข้อมูลหลัง Homing
idxCW  = idxHomeCW+1:height(CW);
idxCCW = idxHomeCCW+1:height(CCW);

timeCW  = double(CW.time(idxCW));
timeCCW = double(CCW.time(idxCCW));

countCW  = double(CW.homed_count(idxCW));
countCCW = double(CCW.homed_count(idxCCW));

% ทำให้เริ่มจากศูนย์
timeCW  = timeCW-timeCW(1);
timeCCW = timeCCW-timeCCW(1);

countCW  = countCW-countCW(1);
countCCW = countCCW-countCCW(1);

% แปลง Count เป็นองศา โดยไม่ใช้ abs()
degreeCW  = countCW*360/CPR;
degreeCCW = countCCW*360/CPR;

% สร้างกราฟ
fig = figure('Color','w');
ax = axes(fig);

plot(ax,timeCW,degreeCW,...
    'b','LineWidth',1.6,...
    'DisplayName','CW');

hold(ax,'on');

plot(ax,timeCCW,degreeCCW,...
    'r','LineWidth',1.6,...
    'DisplayName','CCW');

yline(ax,360,'--b','+360°',...
    'HandleVisibility','off');

yline(ax,-360,'--r','-360°',...
    'HandleVisibility','off');

xlabel(ax,'Time (s)','Color','k');
ylabel(ax,'Angular position (degree)','Color','k');

title(ax,'BOURNS X4: CW vs CCW',...
    'Color','k',...
    'FontWeight','bold');

lgd = legend(ax,'Location','best');
lgd.Color = 'w';
lgd.TextColor = 'k';
lgd.EdgeColor = 'k';

grid(ax,'on');
grid(ax,'minor');
box(ax,'on');

ax.Color = 'w';
ax.XColor = 'k';
ax.YColor = 'k';
ax.GridColor = [0.7 0.7 0.7];

ylim(ax,[-400 400]);

fig.Position = [100 100 1100 650];

exportgraphics(fig,...
    'BOURNS_X4_CW_vs_CCW.png',...
    'Resolution',300);