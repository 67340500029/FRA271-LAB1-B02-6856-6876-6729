% --- 1. ดึงข้อมูล ---
idx = 2; % หากต้องการสลับเป็นสัญญาณ Gain ให้เปลี่ยนเป็นลำดับที่ถูกต้อง

t1 = N_polerealtime1.get(idx).Values.Time;
B1 = N_polerealtime1.get(idx).Values.Data;

t2 = N_polerealtime2.get(idx).Values.Time;
B2 = N_polerealtime2.get(idx).Values.Data;

t3 = N_polerealtime3.get(idx).Values.Time;
B3 = N_polerealtime3.get(idx).Values.Data;

% --- 2. ตั้งค่าหน้าต่างกราฟ Dark Theme ---
fig = figure('Color', 'k');                    % พื้นหลังนอกกรอบสีดำสนิท
ax = axes('Parent', fig, 'Color', [0.1 0.1 0.1]); % พื้นหลังในกรอบกราฟสีเทาดำ

hold on;
% ปรับขนาดความหนาเส้น (LineWidth) ให้ไม่เท่ากัน โดยใช้ชุดสีใหม่สำหรับ N pole (ขั้วเหนือ)
plot(t1, B1, '-', 'Color', '#7B1FA2', 'LineWidth', 4.5, 'DisplayName', 'Run 1'); % Deep Purple (ม่วงเข้ม, เส้นหนาสุดอยู่หลัง)
plot(t2, B2, '-', 'Color', '#007FFF', 'LineWidth', 3.0, 'DisplayName', 'Run 2'); % Azure Blue (ฟ้าคราม, กลาง)
plot(t3, B3, '-', 'Color', '#7DF9FF', 'LineWidth', 1.5, 'DisplayName', 'Run 3'); % Electric Blue (ฟ้านีออน, เส้นบางสุดทับบน)
hold off;

% --- 3. เพิ่มความถี่ของ Grid และตัวเลขแกน (Ticks) ---
grid on;
grid minor; 
set(ax, 'GridColor', [0.4 0.4 0.4], 'GridAlpha', 0.6);
set(ax, 'MinorGridColor', [0.25 0.25 0.25], 'MinorGridAlpha', 0.5);

% กำหนดสเกลแกน X และ Y ให้ตรงกับช่วงข้อมูล Gain จริง
xticks(0:5:100);        % แกน X แสดงทุกๆ 5 วินาที
ylim([-16 1]);          % กำหนดขอบเขตแกน Y จาก -16 ถึง 1
yticks(-16:1:0);        % แสดงตัวเลขแกน Y จาก -16 ถึง 0 เพิ่มขึ้นทีละ 2

% --- 4. ขยายขนาด Font และปรับสีข้อความ ---
set(ax, 'XColor', 'w', 'YColor', 'w', 'FontSize', 14, 'FontWeight', 'bold'); % เลขแกน X, Y

title('Real-time Data Repeatability Test', 'Color', 'w', 'FontSize', 18, 'FontWeight', 'bold');
xlabel('Time (s)', 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('Magnetic Flux Density, B (mT)', 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');

% Legend แบบ Dark Theme
lgd = legend('Location', 'northeast');
set(lgd, 'Color', [0.15 0.15 0.15], 'TextColor', 'w', 'FontSize', 14, 'EdgeColor', [0.5 0.5 0.5]);

% --- 5. บันทึกรูปภาพความละเอียดสูง ---
exportgraphics(fig, 'RealTime_Repeatability_Dark.png', 'Resolution', 300, 'BackgroundColor', 'k');