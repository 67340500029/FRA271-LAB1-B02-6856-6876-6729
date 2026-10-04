% --- 1. ดึงข้อมูล (เลือก Run ที่สมบูรณ์ เช่น Run 3) ---
idx = 2; % สัญญาณ Gain Output
t = N_polerealtimeUS3.get(idx).Values.Time;
B = N_polerealtimeUS3.get(idx).Values.Data;

% --- 2. ตั้งค่าหน้าต่างกราฟ Dark Theme ---
fig = figure('Color', 'k');                    % พื้นหลังนอกกรอบสีดำสนิท
ax = axes('Parent', fig, 'Color', [0.1 0.1 0.1]); % พื้นหลังในกรอบกราฟสีเทาดำ

% พล็อตเส้นสัญญาณเดียว (ใช้สี Electric Blue #7DF9FF สว่างชัดเจนบนพื้นดำ)
plot(t, B, '-', 'Color', '#7DF9FF', 'LineWidth', 2.5, 'DisplayName', 'Run 3');

% --- 3. เพิ่มความถี่ของ Grid และปรับแต่งสเกลแกน Y ขอบบน ---
grid on;
grid minor; 
set(ax, 'GridColor', [0.4 0.4 0.4], 'GridAlpha', 0.6);
set(ax, 'MinorGridColor', [0.25 0.25 0.25], 'MinorGridAlpha', 0.5);

xticks(0:5:110);        % แกน X แสดงทุกๆ 5 วินาที
ylim([-1 18]);          % กำหนดขอบเขตแกน Y ครอบคลุมฝั่งบวก (-1 ถึง 18)
yticks(0:2:18);         % แสดงตัวเลขแกน Y จาก 0 ถึง 18 เพิ่มขึ้นทีละ 2

% --- 4. ขยายขนาด Font และปรับสีข้อความ ---
set(ax, 'XColor', 'w', 'YColor', 'w', 'FontSize', 14, 'FontWeight', 'bold');
title('Real-time Data Test (Unshield)', 'Color', 'w', 'FontSize', 18, 'FontWeight', 'bold');
xlabel('Time (s)', 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Magnetic Flux Density, B (mT)', 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');

% Legend แบบ Dark Theme
lgd = legend('Location', 'northeast');
set(lgd, 'Color', [0.15 0.15 0.15], 'TextColor', 'w', 'FontSize', 14, 'EdgeColor', [0.5 0.5 0.5]);

% --- 5. บันทึกรูปภาพความละเอียดสูง ---
exportgraphics(fig, 'RealTime_SingleRun_Dark.png', 'Resolution', 300, 'BackgroundColor', 'k');