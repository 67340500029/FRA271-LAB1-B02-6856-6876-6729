clear; clc; close all;

% ถ้ายังใช้ชื่อ CWW ให้เขียนชื่อตามไฟล์จริง
fileCW  = 'BOURNS_X4_AB_CW_1.xlsx';
fileCCW = 'BOURNS_X4_AB_CCW_1.xlsx';

CW  = readtable(fileCW,...
    'VariableNamingRule','preserve');

CCW = readtable(fileCCW,...
    'VariableNamingRule','preserve');

%% เลือกช่วงข้อมูลที่เห็น Quadrature ชัดเจน

% ช่วง CW
tStartCW = 10.75;
tEndCW   = 12.00;

idxCW = CW.time >= tStartCW & CW.time <= tEndCW;

timeCW = double(CW.time(idxCW));
A_CW   = double(CW.signal_A(idxCW));
B_CW   = double(CW.signal_B(idxCW));

% ทำให้เวลาเริ่มจากศูนย์
timeCW = timeCW-timeCW(1);

% ช่วง CCW
tStartCCW = 14.65;
tEndCCW   = 15.30;

idxCCW = CCW.time >= tStartCCW & CCW.time <= tEndCCW;

timeCCW = double(CCW.time(idxCCW));
A_CCW   = double(CCW.signal_A(idxCCW));
B_CCW   = double(CCW.signal_B(idxCCW));

% ทำให้เวลาเริ่มจากศูนย์
timeCCW = timeCCW-timeCCW(1);

%% สร้างกราฟ

fig = figure('Color','w');
tl = tiledlayout(2,1,...
    'Padding','compact',...
    'TileSpacing','compact');

% เลื่อนสัญญาณ A ขึ้น เพื่อไม่ให้ทับกับ B
offsetA = 1.4;

%% กราฟ CW

ax1 = nexttile;

stairs(ax1,timeCW,A_CW+offsetA,...
    'b','LineWidth',1.8,...
    'DisplayName','Signal A');

hold(ax1,'on');

stairs(ax1,timeCW,B_CW,...
    'r','LineWidth',1.8,...
    'DisplayName','Signal B');

title(ax1,'BOURNS X4: Phase Relationship — CW',...
    'Color','k',...
    'FontWeight','bold');

ylabel(ax1,'Digital state');

yticks(ax1,[0 1 offsetA offsetA+1]);
yticklabels(ax1,...
    {'B LOW','B HIGH','A LOW','A HIGH'});

ylim(ax1,[-0.2 2.6]);

lgd1 = legend(ax1,'Location','eastoutside');
lgd1.Color = 'w';
lgd1.TextColor = 'k';
lgd1.EdgeColor = 'k';
grid(ax1,'on');
grid(ax1,'minor');
box(ax1,'on');

ax1.Color  = 'w';
ax1.XColor = 'k';
ax1.YColor = 'k';

%% กราฟ CCW

ax2 = nexttile;

stairs(ax2,timeCCW,A_CCW+offsetA,...
    'b','LineWidth',1.8,...
    'DisplayName','Signal A');

hold(ax2,'on');

stairs(ax2,timeCCW,B_CCW,...
    'r','LineWidth',1.8,...
    'DisplayName','Signal B');

title(ax2,'BOURNS X4: Phase Relationship — CCW',...
    'Color','k',...
    'FontWeight','bold');

xlabel(ax2,'Time from selected interval (s)');
ylabel(ax2,'Digital state');

yticks(ax2,[0 1 offsetA offsetA+1]);
yticklabels(ax2,...
    {'B LOW','B HIGH','A LOW','A HIGH'});

ylim(ax2,[-0.2 2.6]);

lgd2 = legend(ax2,'Location','eastoutside');
lgd2.Color = 'w';
lgd2.TextColor = 'k';
lgd2.EdgeColor = 'k';
grid(ax2,'on');
grid(ax2,'minor');
box(ax2,'on');

ax2.Color  = 'w';
ax2.XColor = 'k';
ax2.YColor = 'k';

% กำหนดขนาดภาพ
fig.Position = [100 100 1100 750];

% บันทึกภาพ
exportgraphics(fig,...
    'BOURNS_X4_AB_Phase_CW_vs_CCW.png',...
    'Resolution',300);