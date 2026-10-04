% --- 1. ดึงข้อมูล ---
idx = 2; % สัญญาณ Gain Output
t1 = N_polerealtimeUS1.get(idx).Values.Time;
B1 = N_polerealtimeUS1.get(idx).Values.Data;
t2 = N_polerealtimeUS2.get(idx).Values.Time;
B2 = N_polerealtimeUS2.get(idx).Values.Data;
t3 = N_polerealtimeUS3.get(idx).Values.Time;
B3 = N_polerealtimeUS3.get(idx).Values.Data;

% --- 2. ตั้งค่าหน้าต่างกราฟ Dark Theme ---
fig = figure('Color', 'k');                    % พื้นหลังนอกกรอบสีดำสนิท
ax = axes('Parent', fig, 'Color', [0.1 0.1 0.1]); % พื้นหลังในกรอบกราฟสีเทาดำ

hold on;
plot(t1, B1, '-', 'Color', '#7B1FA2', 'LineWidth', 4.5, 'DisplayName', 'Run 1'); % Deep Purple
plot(t2, B2, '-', 'Color', '#007FFF', 'LineWidth', 3.0, 'DisplayName', 'Run 2'); % Azure Blue
plot(t3, B3, '-', 'Color', '#7DF9FF', 'LineWidth', 1.5, 'DisplayName', 'Run 3'); % Electric Blue
hold off;

% --- 3. เพิ่มความถี่ของ Grid และปรับแต่งสเกลแกน Y ขอบบน ---
grid on;
grid minor; 
set(ax, 'GridColor', [0.4 0.4 0.4], 'GridAlpha', 0.6);
set(ax, 'MinorGridColor', [0.25 0.25 0.25], 'MinorGridAlpha', 0.5);

xticks(0:5:110);        % แกน X แสดงทุกๆ 5 วินาที
ylim([-1 18]);          % กำหนดขอบเขตแกน Y ครอบคลุมฝั่งบวก (-1 ถึง 16)
yticks(0:2:18);         % แสดงตัวเลขแกน Y จาก 0 ถึง 16 เพิ่มขึ้นทีละ 2 (อ่านง่าย ไม่แน่นเกินไป)

% --- 4. ขยายขนาด Font และปรับสีข้อความ ---
set(ax, 'XColor', 'w', 'YColor', 'w', 'FontSize', 14, 'FontWeight', 'bold');
title('Real-time Data Repeatability Test (Unshield)', 'Color', 'w', 'FontSize', 18, 'FontWeight', 'bold');
xlabel('Time (s)', 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Magnetic Flux Density, B (mT)', 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');

% Legend แบบ Dark Theme
lgd = legend('Location', 'northeast');
set(lgd, 'Color', [0.15 0.15 0.15], 'TextColor', 'w', 'FontSize', 14, 'EdgeColor', [0.5 0.5 0.5]);

% --- 5. บันทึกรูปภาพความละเอียดสูง ---
exportgraphics(fig, 'RealTime_Repeatability_Dark.png', 'Resolution', 300, 'BackgroundColor', 'k');