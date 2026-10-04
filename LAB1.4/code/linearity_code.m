% =========================================================================
% MATLAB Load Cell Calibration & Linearity Error Analysis Script
% =========================================================================
clc; clear; close all;

% 1. อ่านข้อมูลจากไฟล์ CSV
filename = 'LoadCell_Linear.csv';
if ~isfile(filename)
    error('❌ ไม่พบไฟล์ %s กรุณาตรวจสอบว่าอยู่ในโฟลเดอร์ปัจจุบัน', filename);
end
T = readtable(filename);

x = T.Actual_kg;      % น้ำหนักอ้างอิงจริง (kg)
y = T.Average_kg;     % ค่าเฉลี่ยการวัดจริง (kg)
FS = max(x) - min(x); % Full Scale Range (10 kg)

% 2. คำนวณ Linear Regression (y_fit = m*x + c)
p = polyfit(x, y, 1);
slope = p(1);        % Calibration Gain Factor (m)
intercept = p(2);    % Zero Offset (c)
y_fit = polyval(p, x);

% 3. คำนวณ Percentage Linearity Error (%FS)
abs_dev = abs(y - y_fit);                       % ความเบี่ยงเบนจากเส้น Best-Fit
max_dev = max(abs_dev);                         % ค่าเบี่ยงเบนสูงสุด
percent_linearity_error = (max_dev / FS) * 100; % Linearity Error (%FS)

% 4. คำนวณ R-squared (R²)
y_mean = mean(y);
SS_tot = sum((y - y_mean).^2);
SS_res = sum((y - y_fit).^2);
R_squared = 1 - (SS_res / SS_tot);

% 5. แสดงผลลัพธ์ใน Command Window
fprintf('==================================================\n');
fprintf('       📊 LOAD CELL CALIBRATION ANALYSIS RESULT     \n');
fprintf('==================================================\n');
fprintf('Calibration Factor (Slope m) : %.6f\n', slope);
fprintf('Zero Offset (Intercept c)    : %.6f kg\n', intercept);
fprintf('Linear Fit Equation          : y = %.6f*x + (%.6f)\n', slope, intercept);
fprintf('Full Scale Range (FS)        : %.2f kg\n', FS);
fprintf('Maximum Deviation (Max Dev)  : %.6f kg\n', max_dev);
fprintf('Percentage Linearity Error   : %.4f %%FS\n', percent_linearity_error);
fprintf('R-Squared (R²)               : %.6f\n', R_squared);
fprintf('==================================================\n');

% 6. พล้อตกราฟวิเคราะห์ผล Linearity
figure('Name', 'Linearity & Calibration Analysis', 'Color', 'w', 'Position', [100, 100, 1000, 420]);

% Subplot 1: Calibration Curve & Linearity Fit
subplot(1, 2, 1);
plot(x, y, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'Measured Average'); hold on;
plot(x, y_fit, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Best-Fit: y = %.3fx + %.3f', slope, intercept));
plot(x, x, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Ideal Line (y = x)');
grid on; xlabel('Actual Weight (kg)'); ylabel('Measured Weight (kg)');
title('Calibration Curve & Linear Regression'); legend('Location', 'northwest');

% Subplot 2: Linearity Error Distribution per Point
subplot(1, 2, 2);
stem(x, (abs_dev / FS) * 100, 'filled', 'm', 'LineWidth', 1.5);
grid on; xlabel('Actual Weight (kg)'); ylabel('Linearity Deviation (%FS)');
title(sprintf('Linearity Error Distribution (Max = %.4f %%FS)', percent_linearity_error));