% =========================================================================
% MATLAB Script: Magnetic Response Curve (Updated Corrected Data)
% =========================================================================
clear; clc; close all;

% 1. ข้อมูล Sheet 1 (North Pole)[cite: 13]
B_sheet1 = [-29.9744, -29.8852, -27.6799, -17.8587, -12.068, -8.51771, ...
            -6.04085, -4.35773, -3.06652, -2.57917, -1.95183, -1.45226, ...
            -1.21107, -0.95475, -0.78686, -0.59687, 0.03716];

V_sheet1 = [0.15128, 0.155741, 0.266004, 0.757063, 1.0466, 1.224115, ...
            1.347958, 1.432113, 1.496674, 1.521041, 1.552409, 1.577387, ...
            1.589446, 1.602262, 1.610657, 1.620157, 1.651858];

% 2. ข้อมูล Sheet 2 (South Pole) - แก้ไขแรงดันสมบูรณ์[cite: 14]
B_sheet2 = [0.00456, 0.167686, 0.365221, 0.57394, 0.79934, 1.125792, ...
            1.50442, 2.117315, 2.902423, 4.181188, 5.596598, 7.68296, ...
            11.82548, 16.05485, 25.18016, 32.25992, 32.26291];

V_sheet2 = [1.650228, 1.658384, 1.668261, 1.678697, 1.689967, 1.70629, ...
            1.725221, 1.755866, 1.795121, 1.859059, 1.92983, 2.034148, ...
            2.241274, 2.452743, 2.909008, 3.262996, 3.263145];

% 3. สร้าง Figure (Dark Theme)[cite: 15]
fig = figure('Color', 'k', 'Position', [100, 100, 850, 520]);
ax = axes('Parent', fig, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
hold(ax, 'on');

% พล็อตกราฟ Sheet 1 (North Pole - สีฟ้า)[cite: 15]
plot(ax, B_sheet1, V_sheet1, '-o', 'Color', [0.35, 0.7, 1.0], 'LineWidth', 2.0, ...
    'MarkerSize', 5, 'MarkerFaceColor', [0.35, 0.7, 1.0], ...
    'DisplayName', 'Sheet 1 (North Pole)');

% พล็อตกราฟ Sheet 2 (South Pole - สีแดง)[cite: 15]
plot(ax, B_sheet2, V_sheet2, '-s', 'Color', [1.0, 0.25, 0.25], 'LineWidth', 2.0, ...
    'MarkerSize', 5, 'MarkerFaceColor', [1.0, 0.25, 0.25], ...
    'DisplayName', 'Sheet 2 (South Pole)');

% เส้นอ้างอิง[cite: 15]
yline(ax, 1.65, '--', 'V_{cc}/2 = 1.65 V', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2);
xline(ax, 0, '--', '0 mT', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2);

% ชื่อแกนและชื่อกราฟ[cite: 15]
title(ax, 'Magnetic Response: Sensor Voltage (V_{out}) vs Magnetic Flux Density (B)', ...
    'Color', 'w', 'FontSize', 13, 'FontWeight', 'bold');
xlabel(ax, '\leftarrow North (Negative B)   |   Magnetic Flux Density, B (mT)   |   South (Positive B) \rightarrow', ...
    'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
ylabel(ax, 'Sensor Output Voltage, V_{out} (V)', 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');

% ตั้งค่า Grid, Legend และ Limit แกน[cite: 15]
grid(ax, 'on'); box(ax, 'on');
ax.GridColor = [0.5, 0.5, 0.5]; ax.GridAlpha = 0.5;
legend(ax, 'TextColor', 'w', 'Color', 'none', 'EdgeColor', 'w', 'Location', 'northwest');

xlim(ax, [-35, 35]);
ylim(ax, [0, 3.5]); % ปรับสเกลแกน Y ให้เห็นค่าสูงสุดที่ 3.26V ได้อย่างสมบูรณ์

hold(ax, 'off');