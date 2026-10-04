% =========================================================================
% MATLAB Script: North Pole Unshielded - Corrected Negative Sign
% =========================================================================
clear; clc; close all;

% 1. ระยะทาง Distance (mm)
Distance = [12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44];

% 2. ข้อมูล B (mT) จากไฟล์ N Pole Unshielded (ปรับเครื่องหมาย - ตามมาตรฐาน N Pole)
Run1 = -[31.69977, 31.70782, 31.67953, 20.75486, 13.88091, 8.45762, ...
         5.776835, 4.196657, 2.649611, 1.88157, 1.143827, 0.698446, ...
         0.442343, 0.172115, -0.12522, -0.30012, -0.52549];

Run2 = -[32.20169, 32.20096, 32.15125, 19.86596, 14.29649, 9.311868, ...
         7.352516, 4.487262, 3.273697, 2.515802, 1.834634, 2.249983, ...
         1.480994, 0.938799, 0.473569, 0.348307, 0.039458];

Run3 = -[32.27614, 32.27537, 32.21407, 21.2613, 13.04704, 8.730351, ...
         6.227527, 4.48667, 3.254414, 2.544889, 1.795063, 1.28838, ...
         0.873755, 0.651825, 0.443716, 0.279541, 0.010415];

Data = [Run1; Run2; Run3];

% 3. คำนวณหาค่าเฉลี่ย (Mean) และ SD
B_mean = mean(Data, 1);
B_sd   = std(Data, 0, 1);

% 4. สร้าง Figure และตั้งค่า Dark Theme
fig = figure('Color', 'k', 'Position', [100, 100, 1000, 600]);
ax = axes('Parent', fig, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
hold(ax, 'on');

% 5. พล็อต Error Bars (Mean ± SD)
hErr = errorbar(ax, Distance, B_mean, B_sd, '-o', ...
    'Color', [1, 0.35, 0.35], ...       % สีแดงส้มอ่อน
    'LineWidth', 2.0, ...
    'MarkerSize', 7, ...
    'MarkerFaceColor', [1, 0.35, 0.35], ...
    'MarkerEdgeColor', [1, 0.35, 0.35], ...
    'CapSize', 6);

% 6. ตั้งค่ารายละเอียดกราฟ
title(ax, 'North Pole (Unshielded): Magnetic Flux Density vs Distance', 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');
xlabel(ax, 'Distance, d (mm)', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(ax, 'Magnetic Flux Density, B (mT)', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');

xticks(ax, Distance);
xlim(ax, [11.5, 44.5]);

grid(ax, 'on');
set(ax, 'Layer', 'top');
ax.GridColor = [0.4, 0.4, 0.4];
ax.GridAlpha = 0.5;
ax.LineWidth = 1.2;
ax.FontName = 'Arial';
ax.FontSize = 12;
ax.FontWeight = 'bold';

box(ax, 'on');
legend(ax, 'Mean \pm SD (N Pole Unshielded)', 'TextColor', 'w', 'Color', 'none', 'EdgeColor', 'w', 'Location', 'southeast');
hold(ax, 'off');