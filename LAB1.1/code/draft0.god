% =========================================================================
% MATLAB Automated Data Logger (Ultra-Responsive GUI Version)
% =========================================================================
clc; clear; close all;

%% 1. ตั้งค่าสเกลหน้าบอร์ด (0 - 100% Rotation)
scale = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; 
num_pts = length(scale);
data_matrix = zeros(3, num_pts);

disp('============================================================');
disp('   ระบบบันทึกผลการทดลองอัตโนมัติ (Ultra-Responsive Mode)');
disp('============================================================');

%% 2. สร้างหน้าต่าง GUI ปุ่มกด
fig_control = figure('Name', 'Data Logger Controller', ...
                     'NumberTitle', 'off', ...
                     'Position', [400, 300, 450, 250], ...
                     'MenuBar', 'none', ...
                     'Color', [0.12 0.12 0.12]);

% ข้อความบอกสถานะและสเกล
lbl_status = uicontrol('Style', 'text', ...
                       'Parent', fig_control, ...
                       'Position', [20, 185, 410, 40], ...
                       'FontSize', 12, ...
                       'FontWeight', 'bold', ...
                       'ForegroundColor', [1 1 1], ...
                       'BackgroundColor', [0.12 0.12 0.12], ...
                       'String', 'เตรียมพร้อม...');

% ข้อความแสดงค่า mV แบบ Real-time ตัวใหญ่ชัดเจน (แยกออกจากปุ่ม)
lbl_live = uicontrol('Style', 'text', ...
                     'Parent', fig_control, ...
                     'Position', [20, 115, 410, 50], ...
                     'FontSize', 22, ...
                     'FontWeight', 'bold', ...
                     'ForegroundColor', [0 1 1], ...
                     'BackgroundColor', [0.12 0.12 0.12], ...
                     'String', 'LIVE: --- mV');

% ปุ่มกดบันทึก (อยู่นิ่งๆ เพื่อให้รับแรงคลิกได้ 100% ไม่หลุด)
btn_capture = uicontrol('Style', 'pushbutton', ...
                        'Parent', fig_control, ...
                        'Position', [50, 20, 350, 75], ...
                        'FontSize', 16, ...
                        'FontWeight', 'bold', ...
                        'String', 'save', ...
                        'BackgroundColor', [0 0.6 0.2], ...
                        'ForegroundColor', [1 1 1], ...
                        'Interruptible', 'off', ...
                        'BusyAction', 'cancel', ...
                        'Callback', @(src, ~) set(ancestor(src, 'figure'), 'UserData', true));

%% 3. ลูปรับข้อมูลอัตโนมัติ 3 รอบ (Triplicate)
for r = 1:3
    for i = 1:num_pts
        % รีเซ็ตสถานะการกดปุ่ม
        set(fig_control, 'UserData', false);
        
        % อัปเดตข้อความสถานะรอบและสเกล
        set(lbl_status, 'String', sprintf('รอบที่ %d / 3  |  mV: %d%%', r, scale(i)));
        
        % วนลูปรอการกดปุ่ม
        while ishandle(fig_control) && ~get(fig_control, 'UserData')
            if evalin('base', 'exist(''live_v'', ''var'')')
                v_now = evalin('base', 'live_v');
                % อัปเดตเฉพาะ Text Label ไม่ยุ่งกับตัวปุ่ม
                set(lbl_live, 'String', sprintf('LIVE: %.1f mV', v_now));
            else
                set(lbl_live, 'String', 'LIVE: รอสัญญาณ...');
            end
            
            drawnow limitrate; % ประมวลผล Event การคลิกเมาส์ทันที
            pause(0.02);       % ตอบสนองไวขึ้น 2.5 เท่า
        end
        
        if ~ishandle(fig_control)
            error('หน้าต่าง GUI ถูกปิดก่อนเก็บข้อมูลเสร็จสิ้น');
        end
        
        % อ่านค่า Real-Time ณ วินาทีที่กดปุ่ม
        if evalin('base', 'exist(''live_v'', ''var'')')
            current_v = evalin('base', 'live_v');
        else
            current_v = 0;
        end
        
        data_matrix(r, i) = current_v;
        fprintf('บันทึกสำเร็จ -> รอบ %d | สเกล %3d%% | แรงดัน = %.2f mV\n', r, scale(i), current_v);
        
        % เอฟเฟกต์ปุ่มกะพริบสีส้มแป๊บนึง ให้รู้ว่าบันทึกติดแล้ว
        set(btn_capture, 'BackgroundColor', [0.9 0.5 0]);
        pause(0.12);
        set(btn_capture, 'BackgroundColor', [0 0.6 0.2]);
    end
end

% ปิดหน้าต่างควบคุมเมื่อเก็บข้อมูลครบถ้วน
if ishandle(fig_control)
    close(fig_control);
end

%% 4. ประมวลผลและพล็อตกราฟ Dark Mode
v_mean = mean(data_matrix, 1);
v_sd   = std(data_matrix, 0, 1);

fig = figure('Name', 'Potentiometer Response Plot', 'Color', 'k');

errorbar(scale, v_mean, v_sd, '-o', ...
         'LineWidth', 2, ...
         'MarkerSize', 6, ...
         'Color', [0 1 1], ...
         'MarkerEdgeColor', [0 1 1], ...
         'MarkerFaceColor', [1 1 0], ...
         'DisplayName', 'Measured Voltage (Mean \pm SD)');

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