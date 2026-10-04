% =========================================================================
% MATLAB Linearity & Curve Fitting Analyzer (Sensors 1 - 5)
% =========================================================================
clc; clear; close all;

% 1. ค้นหาไฟล์ Excel ของ Potentiometer ทั้งหมดในโฟลเดอร์ปัจจุบัน
excel_files = dir('Sensor_*.xlsx');

if isempty(excel_files)
    error('ไม่พบไฟล์ Excel! กรุณารันสคริปต์เก็บข้อมูล Potentiometer ให้ครบก่อน');
end

fig = figure('Name', 'All Sensors Linearity Analysis', 'Color', 'k');
hold on;
colors = lines(length(excel_files)); % สุ่มโทนสีให้แตกต่างกันชัดเจน

fprintf('============================================================\n');
fprintf('       ผลการวิเคราะห์ Linearity (R^2) และประเภทเซนเซอร์\n');
fprintf('============================================================\n');

% 2. ลูปอ่านไฟล์และคำนวณ Linearity ของแต่ละเซนเซอร์
for k = 1:length(excel_files)
    file_name = excel_files(k).name;
    T = readtable(file_name);
    
    x = T.Rotation_Percent; % ค่า % การหมุน (0 - 100%)
    y = T.Mean_mV;          % ค่าแรงดันเฉลี่ย (mV)
    
    % --- คำนวณ Linear Regression Fitting และค่า R-squared ---
    p = polyfit(x, y, 1);          % p(1) คือ ความชัน (Slope), p(2) คือ Intercept
    y_fit = polyval(p, x);         % ค่าที่ได้จากการสร้างเส้นเชิงเส้นอุดมคติ
    
    ss_res = sum((y - y_fit).^2);  % Residual Sum of Squares
    ss_tot = sum((y - mean(y)).^2);% Total Sum of Squares
    r2 = 1 - (ss_res / ss_tot);    % ค่า R-squared
    
    % --- จำแนกประเภทของ Potentiometer ---
    if r2 >= 0.98
        pot_type = 'Linear (B-Type)';
    elseif y(round(end/2)) < (max(y)/2) % ใช้ round() ป้องกัน Index ทศนิยม
        pot_type = 'Logarithmic (A-Type)';
    else
        pot_type = 'Reverse-Log (C-Type)';
    end
    
    % ดึงชื่อไฟล์มาแสดง
    [~, clean_name, ~] = fileparts(file_name);
    
    % --- พล็อตกราฟของเซนเซอร์แต่ละตัว ---
    plot(x, y, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', colors(k, :), ...
         'DisplayName', sprintf('%s (R^2 = %.4f | %s)', clean_name, r2, pot_type));
    
    % แสดงผลสรุปทาง Command Window
    fprintf('-> %-30s : R^2 = %.4f | Slope = %.2f mV/%% | ชนิด: %s\n', ...
            clean_name, r2, p(1), pot_type);
end

% 3. ตกแต่งกราฟ Dark Mode
grid on; grid minor;
ax = gca; 
ax.Color = 'k'; ax.XColor = 'w'; ax.YColor = 'w'; ax.FontSize = 10;
ax.XTick = 0:10:100; ax.YTick = 0:250:3500;
ax.GridColor = 'w'; ax.GridAlpha = 0.35; 
ax.MinorGridColor = 'w'; ax.MinorGridAlpha = 0.15;

xlabel('Rotation Percentage (%)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel('Output Voltage (mV)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
title('Potentiometer Linearity & Curve Comparison (Sensors 1 - 5)', 'FontSize', 14, 'Color', 'w');
xlim([-5, 105]); ylim([-100, 3400]);

lgd = legend('Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
lgd.Color = [0.15 0.15 0.15]; lgd.TextColor = 'w'; lgd.EdgeColor = 'w';