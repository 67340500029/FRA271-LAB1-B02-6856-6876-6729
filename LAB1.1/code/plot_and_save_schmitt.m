% =========================================================================
% MATLAB Real-Time Schmitt Trigger (Universal & Auto-Aligned Data)
% =========================================================================
clc;

% 1. ดึงข้อมูล Analog
if exist('v_analog', 'var')
    if isa(v_analog, 'timeseries')
        time       = v_analog.Time;
        analog_val = v_analog.Data;
    elseif isnumeric(v_analog)
        if size(v_analog, 2) >= 2
            time       = v_analog(:, 1);
            analog_val = v_analog(:, 2);
        else
            analog_val = v_analog(:);
            if exist('tout', 'var') && length(tout) == length(analog_val)
                time = tout;
            else
                time = (1:length(analog_val))';
            end
        end
    end
else
    error('ไม่พบตัวแปร v_analog! กรุณาเช็กบล็อก To Workspace ใน Simulink');
end

% 2. ดึงข้อมูล Digital
if exist('v_digital', 'var')
    if isa(v_digital, 'timeseries')
        digital_val = v_digital.Data;
    elseif isnumeric(v_digital)
        if size(v_digital, 2) >= 2
            digital_val = v_digital(:, 2);
        else
            digital_val = v_digital(:);
        end
    end
else
    error('ไม่พบตัวแปร v_digital! กรุณาเช็กบล็อก To Workspace ใน Simulink');
end

% --- 💡 เพิ่มระบบตัดความยาวข้อมูลให้เท่ากัน 100% ป้องกัน Table Mismatch ---
min_len     = min([length(time), length(analog_val), length(digital_val)]);
time        = time(1:min_len);
analog_val  = analog_val(1:min_len);
digital_val = digital_val(1:min_len);

% 3. ตรวจสอบสเกลอัตโนมัติ (% หรือ mV) เพื่อตั้งค่า Threshold
is_percent = max(analog_val) <= 105;

if is_percent
    upper_th = 60;
    lower_th = 40;
    unit_str = '%';
    y_lim_analog = [-5, 105];
else
    upper_th = 2000;
    lower_th = 1000;
    unit_str = 'mV';
    y_lim_analog = [-100, 3400];
end

% 4. จัดการสถานะ Logic สำหรับลงตาราง
logic_state = cell(min_len, 1);
logic_state(digital_val >= 0.5) = {'1 (HIGH)'};
logic_state(digital_val < 0.5)  = {'0 (LOW)'};

% 5. บันทึกผลออกเป็นไฟล์ Excel (.xlsx) อัตโนมัติพร้อม Timestamp
timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
excel_filename = sprintf('Schmitt_Trigger_Data_%s.xlsx', timestamp);

T = table(time, analog_val, digital_val, logic_state, ...
    'VariableNames', {'Time_Seconds', sprintf('Analog_Input_%s', unit_str), 'Digital_Output', 'Logic_State'});

writetable(T, excel_filename);

fprintf('\n============================================================\n');
fprintf(' [Auto-Save] บันทึกไฟล์ Excel เรียบร้อย: %s\n', excel_filename);

% 6. สร้างรูปกราฟ Dark Mode
fig = figure('Name', 'Real-Time Schmitt Trigger Performance', 'Color', 'k', 'Position', [100 100 900 600]);

% --- Subplot 1: สัญญาณ Analog ขาเข้า ---
subplot(2, 1, 1);
plot(time, analog_val, 'Color', [1 0.5 0], 'LineWidth', 2, 'DisplayName', 'Analog Input');
hold on;
yline(upper_th, '--r', sprintf('Upper Threshold (%d %s)', upper_th, unit_str), ...
    'LineWidth', 1.5, 'Color', [1 0.3 0.3], 'LabelHorizontalAlignment', 'left', 'FontSize', 10);
yline(lower_th, '--g', sprintf('Lower Threshold (%d %s)', lower_th, unit_str), ...
    'LineWidth', 1.5, 'Color', [0.3 1 0.3], 'LabelHorizontalAlignment', 'left', 'FontSize', 10);
grid on; grid minor;
ax1 = gca;
ax1.Color = 'k'; ax1.XColor = 'w'; ax1.YColor = 'w'; ax1.FontSize = 10;
ax1.GridColor = 'w'; ax1.GridAlpha = 0.35; ax1.MinorGridColor = 'w'; ax1.MinorGridAlpha = 0.15;
ylabel(sprintf('Input Signal (%s)', unit_str), 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'w');
title('Real-Time Schmitt Trigger Hysteresis Performance', 'FontSize', 18, 'Color', 'w');
ylim(y_lim_analog);
legend('Location', 'northeast', 'TextColor', 'w', 'Color', [0.15 0.15 0.15]);

% --- Subplot 2: สัญญาณ Digital ขาออก ---
subplot(2, 1, 2);
plot(time, digital_val, 'Color', [0 1 1], 'LineWidth', 2, 'DisplayName', 'Digital Output (Relay)');
grid on; grid minor;
ax2 = gca;
ax2.Color = 'k'; ax2.XColor = 'w'; ax2.YColor = 'w'; ax2.FontSize = 10;
ax2.GridColor = 'w'; ax2.GridAlpha = 0.35; ax2.MinorGridColor = 'w'; ax2.MinorGridAlpha = 0.15;
xlabel('Time (Seconds)', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'w');
ylabel('Logic Level', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'w');
ylim([-0.2, 1.2]);
yticks([0 1]);
yticklabels({'0 (LOW)', '1 (HIGH)'});
legend('Location', 'northeast', 'TextColor', 'w', 'Color', [0.15 0.15 0.15]);

linkaxes([ax1, ax2], 'x');

% 7. บันทึกรูปกราฟเป็นไฟล์ PNG อัตโนมัติทันที
img_filename = sprintf('Schmitt_Trigger_Plot_%s.png', timestamp);
saveas(fig, img_filename);

fprintf(' [Auto-Save] บันทึกรูปกราฟ HD เรียบร้อย: %s\n', img_filename);
fprintf('============================================================\n');