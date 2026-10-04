% =========================================================================
% MATLAB Automated Data Logger (Configurable Trials + Dynamic Excel Export)
% =========================================================================
clc; clear; close all;

%% 1. ตั้งค่าการทดลอง (กำหนดจำนวนรอบตรงนี้ได้เลย)
num_trials = 5; % <--- แก้เป็น 3 หรือ 5 ตรงนี้ได้ตามต้องการ
scale      = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; 

num_pts     = length(scale);
data_matrix = zeros(num_trials, num_pts);

disp('============================================================');
fprintf('   ระบบบันทึกผลการทดลองอัตโนมัติ (จำนวนทำซ้ำ: %d รอบ)\n', num_trials);
disp('============================================================');

%% 2. สร้างหน้าต่าง GUI ปุ่มกด
fig_control = figure('Name', 'Data Logger Controller', ...
                     'NumberTitle', 'off', ...
                     'Position', [400, 300, 450, 250], ...
                     'MenuBar', 'none', ...
                     'Color', [0.12 0.12 0.12]);

lbl_status = uicontrol('Style', 'text', ...
                       'Parent', fig_control, ...
                       'Position', [20, 185, 410, 40], ...
                       'FontSize', 12, ...
                       'FontWeight', 'bold', ...
                       'ForegroundColor', [1 1 1], ...
                       'BackgroundColor', [0.12 0.12 0.12], ...
                       'String', 'เตรียมพร้อม...');

lbl_live = uicontrol('Style', 'text', ...
                     'Parent', fig_control, ...
                     'Position', [20, 115, 410, 50], ...
                     'FontSize', 22, ...
                     'FontWeight', 'bold', ...
                     'ForegroundColor', [0 1 1], ...
                     'BackgroundColor', [0.12 0.12 0.12], ...
                     'String', 'LIVE: --- mV');

btn_capture = uicontrol('Style', 'pushbutton', ...
                        'Parent', fig_control, ...
                        'Position', [50, 20, 350, 75], ...
                        'FontSize', 16, ...
                        'FontWeight', 'bold', ...
                        'String', 'SAVE', ...
                        'BackgroundColor', [0 0.6 0.2], ...
                        'ForegroundColor', [1 1 1], ...
                        'Interruptible', 'off', ...
                        'BusyAction', 'cancel', ...
                        'Callback', @(src, ~) set(ancestor(src, 'figure'), 'UserData', true));

%% 3. ลูปรับข้อมูลอัตโนมัติ (ตามจำนวน num_trials)
for r = 1:num_trials
    for i = 1:num_pts
        set(fig_control, 'UserData', false);
        set(lbl_status, 'String', sprintf('รอบที่ %d / %d  |  mV: %d%%', r, num_trials, scale(i)));
        
        while ishandle(fig_control) && ~get(fig_control, 'UserData')
            if evalin('base', 'exist(''live_v'', ''var'')')
                v_now = evalin('base', 'live_v');
                set(lbl_live, 'String', sprintf('LIVE: %.1f mV', v_now));
            else
                set(lbl_live, 'String', 'LIVE: รอสัญญาณ...');
            end
            drawnow limitrate;
            pause(0.02);
        end
        
        if ~ishandle(fig_control)
            error('หน้าต่าง GUI ถูกปิดก่อนเก็บข้อมูลเสร็จสิ้น');
        end
        
        if evalin('base', 'exist(''live_v'', ''var'')')
            current_v = evalin('base', 'live_v');
        else
            current_v = 0;
        end
        
        data_matrix(r, i) = current_v;
        fprintf('บันทึกสำเร็จ -> รอบ %d/%d | สเกล %3d%% | แรงดัน = %.2f mV\n', r, num_trials, scale(i), current_v);
        
        set(btn_capture, 'BackgroundColor', [0.9 0.5 0]);
        pause(0.12);
        set(btn_capture, 'BackgroundColor', [0 0.6 0.2]);
    end
end

if ishandle(fig_control)
    close(fig_control);
end

%% 4. ประมวลผลข้อมูล
v_mean = mean(data_matrix, 1);
v_sd   = std(data_matrix, 0, 1);

%% 5. บันทึกผลออกเป็นไฟล์ Excel (.xlsx) แบบขยายคอลัมน์ให้อัตโนมัติ
sensor_list = {'Sensor 1', 'Sensor 2', 'Sensor 3', 'Sensor 4', 'Sensor 5'};
s_idx = listdlg('PromptString', 'เลือกเซนเซอร์ที่เพิ่งทดลองเสร็จ:', ...
                'SelectionMode', 'single', ...
                'ListString', sensor_list);

if isempty(s_idx)
    s_name = 'Sensor_Unknown';
else
    s_name = sprintf('Sensor_%d', s_idx);
end

timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
excel_filename = sprintf('Potentiometer_%s_%s.xlsx', s_name, timestamp);

% สร้างชื่อหัวคอลัมน์ตามจำนวนรอบแบบ Dynamic (Trial_1_mV ถึง Trial_N_mV)
trial_headers = arrayfun(@(x) sprintf('Trial_%d_mV', x), 1:num_trials, 'UniformOutput', false);
var_names     = [{'Rotation_Percent'}, trial_headers, {'Mean_mV', 'SD_mV'}];

% รวมข้อมูลทั้งหมดเข้าตาราง
combined_data = [scale', data_matrix', v_mean', v_sd'];
T = array2table(combined_data, 'VariableNames', var_names);

% เขียนลงไฟล์ Excel
writetable(T, excel_filename);

fprintf('\n============================================================\n');
fprintf(' [System] บันทึกไฟล์ข้อมูล %d รอบ ของ %s เรียบร้อย: %s\n', num_trials, s_name, excel_filename);
fprintf('============================================================\n');

%% 6. พล็อตกราฟ Dark Mode
fig = figure('Name', 'Potentiometer Response Plot', 'Color', 'k');

errorbar(scale, v_mean, v_sd, '-o', ...
         'LineWidth', 2, ...
         'MarkerSize', 6, ...
         'Color', [0 1 1], ...
         'MarkerEdgeColor', [0 1 1], ...
         'MarkerFaceColor', [1 1 0], ...
         'DisplayName', sprintf('Measured Voltage (Mean \\pm SD, %d Trials)', num_trials));

grid on; grid minor;
ax = gca; 
ax.Color = 'k'; ax.XColor = 'w'; ax.YColor = 'w'; ax.FontSize = 10;
ax.XTick = 0:10:100; ax.YTick = 0:250:3500;
ax.GridColor = 'w'; ax.GridAlpha = 0.35; 
ax.MinorGridColor = 'w'; ax.MinorGridAlpha = 0.15;

xlabel('Rotation Percentage (%)', 'FontSize', 18, 'FontWeight', 'bold', 'Color', 'w');
ylabel('Output Voltage (mV)', 'FontSize', 18, 'FontWeight', 'bold', 'Color', 'w');
title('Potentiometer Voltage vs Rotation Percentage Characteristic', 'FontSize', 20, 'Color', 'w');
xlim([-5, 105]); ylim([-100, 3400]);

lgd = legend('Location', 'northwest', 'FontSize', 11);
lgd.Color = [0.15 0.15 0.15]; lgd.TextColor = 'w'; lgd.EdgeColor = 'w';