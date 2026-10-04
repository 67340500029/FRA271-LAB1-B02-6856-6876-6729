% =========================================================================
% MATLAB Real-Time Load Cell UI (Weight kg + Signal mV + CSV Export)
% =========================================================================
clc; close all;

% 1. ตรวจสอบการเชื่อมต่อกับ Simulink
model_name = bdroot;
if isempty(model_name)
    errordlg('❌ ไม่พบโมเดล Simulink! กรุณาเปิดไฟล์ Simulink และกด RUN ก่อนเริ่มใช้งาน UI', 'Simulink Error');
    return;
end

% เส้นทางบล็อกใน Simulink (ต้องมีบล็อกชื่อ /Kg และ /mV)
display_block_kg = [model_name '/Kg'];
display_block_mv = [model_name '/mV']; 

% 2. ตัวแปรเก็บข้อมูล (1 รอบ: 0 ถึง 10 kg)
W_actual = 0:10;
n_weights = length(W_actual);

appData = struct();
appData.W_actual = W_actual;
appData.n_weights = n_weights;
appData.Data_kg = NaN(1, n_weights);           % เก็บค่าน้ำหนัก (kg)
appData.Data_mv = NaN(1, n_weights);           % เก็บค่าแรงดัน (mV)
appData.Time_matrix = NaN(1, n_weights);       % เก็บเวลาสะสม t (วินาที)
appData.Timestamp_matrix = strings(1, n_weights); % เก็บเวลานาฬิกาจริง
appData.current_w_idx = 1;
appData.display_block_kg = display_block_kg;
appData.display_block_mv = display_block_mv;

% ตัวแปรสำหรับ Real-Time Time-Series Logging
appData.t_start = tic;           
appData.time_log = [];          
appData.val_log_kg = [];         
appData.val_log_mv = [];         
appData.countdown_active = false;
appData.countdown_time = 0;     

% 3. ธีมสี Dark Mode
fig_bg   = [0.10 0.10 0.10];
panel_bg = [0.15 0.15 0.15];
ax_bg    = [0.20 0.20 0.20];
txt_col  = [1.00 1.00 1.00];
grid_col = [0.35 0.35 0.35];

% 4. UI Figure
fig = uifigure('Name', ['Real-Time Load Cell UI (kg & mV) - Model: ' model_name], ...
    'Color', fig_bg, 'Position', [50, 50, 1250, 750]);

grid_main = uigridlayout(fig, [1, 2]);
grid_main.ColumnWidth = {360, '1x'};

% PANEL 1: ด้านซ้าย (แผงควบคุม)
p_ctrl = uipanel(grid_main, 'Title', '🎛️ Control Panel', ...
    'BackgroundColor', panel_bg, 'ForegroundColor', txt_col, ...
    'FontSize', 14, 'FontWeight', 'bold');

p_ctrl_grid = uigridlayout(p_ctrl, [8, 1]);
p_ctrl_grid.RowHeight = {35, 55, 45, 45, 45, 45, 40, '1x'};

% เลือกน้ำหนักอ้างอิง (0 kg - 10 kg)
uilabel(p_ctrl_grid, 'Text', '⚖️ ค่าน้ำหนักอ้างอิง (Target Kg):', ...
    'FontColor', txt_col, 'FontWeight', 'bold');
drop_weight = uidropdown(p_ctrl_grid, ...
    'Items', arrayfun(@(x) sprintf('%d kg', x), W_actual, 'UniformOutput', false), ...
    'ItemsData', 1:n_weights, 'Value', 1);

% ค่า Live สด (แสดงทั้ง kg และ mV)
lbl_live_val = uilabel(p_ctrl_grid, 'Text', 'Live: 0.0000 kg | 0.000 mV', ...
    'FontColor', [0.3 1 0.3], 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% ปุ่มกด RECORD ทันที
btn_record = uibutton(p_ctrl_grid, 'Text', '📸 บันทึกทันที (Manual Record)', ...
    'BackgroundColor', [0.1 0.6 0.2], 'FontColor', [1 1 1], 'FontSize', 13, 'FontWeight', 'bold');

% ปุ่มกด AUTO HOLD TIMER (นับถอยหลัง 10 วินาที)
btn_auto_timer = uibutton(p_ctrl_grid, 'Text', '⏱️ ออโต้จับเวลา 10 วิ แล้วบันทึก', ...
    'BackgroundColor', [0.8 0.5 0.1], 'FontColor', [1 1 1], 'FontSize', 13, 'FontWeight', 'bold');

% ปุ่ม SAVE CSV
btn_save = uibutton(p_ctrl_grid, 'Text', '💾 เซฟไฟล์ CSV', ...
    'BackgroundColor', [0.1 0.4 0.8], 'FontColor', [1 1 1], 'FontSize', 13, 'FontWeight', 'bold');

% สถานะแจ้งเตือน
lbl_status = uilabel(p_ctrl_grid, 'Text', 'พร้อมบันทึกข้อมูล (1 รอบ)...', ...
    'FontColor', [0.8 0.8 0.8], 'FontSize', 11, 'HorizontalAlignment', 'center');

% PANEL 2: ด้านขวา (กราฟ Real-Time + Calibration)
p_plots = uipanel(grid_main, 'Title', '📊 Real-Time Dashboard', ...
    'BackgroundColor', panel_bg, 'ForegroundColor', txt_col, 'FontSize', 14, 'FontWeight', 'bold');
grid_plots = uigridlayout(p_plots, [2, 1]);
grid_plots.RowHeight = {'1x', '1x'};

% Axes 1: Real-Time Stream (น้ำหนัก vs เวลา t ช่วง 10 วินาที)
ax_stream = uiaxes(grid_plots);
style_axes_dark(ax_stream, '📈 Live Time-Series Signal (Weight vs Time t - 10s Window)', ax_bg, txt_col, grid_col);
xlabel(ax_stream, 'Elapsed Time t (seconds)'); ylabel(ax_stream, 'Measured Weight (kg)');

% Axes 2: Calibration Curve (mV vs Actual kg)
ax_cal = uiaxes(grid_plots);
style_axes_dark(ax_cal, '🎯 Calibration Curve (Voltage mV vs Actual kg)', ax_bg, txt_col, grid_col);
xlabel(ax_cal, 'Actual Weight (kg)'); ylabel(ax_cal, 'Measured Signal (mV)');

% บันทึก UserData
appData.drop_weight = drop_weight;
appData.lbl_live_val = lbl_live_val; appData.lbl_status = lbl_status;
appData.ax_stream = ax_stream; appData.ax_cal = ax_cal;
appData.ax_bg = ax_bg; appData.txt_col = txt_col; appData.grid_col = grid_col;
fig.UserData = appData;

% Callbacks
drop_weight.ValueChangedFcn = @(src, evt) change_weight_cb(fig, src.Value);
btn_record.ButtonPushedFcn = @(src, evt) record_data_cb(fig);
btn_auto_timer.ButtonPushedFcn = @(src, evt) start_auto_timer_cb(fig);
btn_save.ButtonPushedFcn = @(src, evt) save_csv_cb(fig);

% Timer อ่านค่า Real-Time สดทุก 0.1 วินาที
live_timer = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, ...
    'TimerFcn', @(~,~) update_realtime_loop(fig));
start(live_timer);
fig.CloseRequestFcn = @(~,~) close_gui_cb(fig, live_timer);

% =========================================================================
% LOCAL FUNCTIONS
% =========================================================================

function update_realtime_loop(fig)
    if ~isvalid(fig), return; end
    data = fig.UserData;
    
    val_kg = 0; val_mv = 0;
    try
        rto_kg = get_param(data.display_block_kg, 'RuntimeObject');
        if ~isempty(rto_kg), val_kg = rto_kg.InputPort(1).Data; end
    catch
        val_kg = 0;
    end
    
    try
        rto_mv = get_param(data.display_block_mv, 'RuntimeObject');
        if ~isempty(rto_mv), val_mv = rto_mv.InputPort(1).Data; end
    catch
        val_mv = NaN; % หากไม่พบบล็อก /mV จะแสดงเป็น NaN
    end

    t_now = toc(data.t_start);

    data.time_log(end+1) = t_now;
    data.val_log_kg(end+1) = val_kg;
    data.val_log_mv(end+1) = val_mv;

    % รักษาสาย Buffer แสดงย้อนหลัง 10 วินาทีล่าสุด
    idx_keep = data.time_log >= (t_now - 10);
    data.time_log = data.time_log(idx_keep);
    data.val_log_kg = data.val_log_kg(idx_keep);
    data.val_log_mv = data.val_log_mv(idx_keep);

    % อัปเดตข้อความ Live Display
    if isnan(val_mv)
        data.lbl_live_val.Text = sprintf('Live: %.4f kg | (No /mV Block) | t: %.1f s', val_kg, t_now);
    else
        data.lbl_live_val.Text = sprintf('Live: %.4f kg | %.3f mV | t: %.1f s', val_kg, val_mv, t_now);
    end

    % พล้อตกราฟสัญญาณสดช่วง 10 วินาที
    plot(data.ax_stream, data.time_log, data.val_log_kg, 'g-', 'LineWidth', 1.8);
    xlim(data.ax_stream, [max(0, t_now - 10), max(10, t_now)]);
    ylim(data.ax_stream, [-0.5, 11]);
    grid(data.ax_stream, 'on');

    % ตรวจสอบสถานะการนับถอยหลัง Auto Hold 10 วินาที
    if data.countdown_active
        data.countdown_time = data.countdown_time - 0.1;
        if data.countdown_time > 0
            data.lbl_status.Text = sprintf('⏳ กำลังรอน้ำหนักนิ่ง... นับถอยหลัง: %.1f วินาที', data.countdown_time);
        else
            data.countdown_active = false;
            fig.UserData = data;
            record_data_cb(fig);
            return;
        end
    end

    fig.UserData = data;
end

function start_auto_timer_cb(fig)
    data = fig.UserData;
    data.countdown_active = true;
    data.countdown_time = 10.0;
    fig.UserData = data;
end

function change_weight_cb(fig, val)
    data = fig.UserData;
    data.current_w_idx = val;
    data.lbl_status.Text = sprintf('เลือกน้ำหนักอ้างอิงเป็น: %d kg', data.W_actual(val));
    fig.UserData = data;
end

function record_data_cb(fig)
    data = fig.UserData;
    try
        val_kg = 0; val_mv = NaN;
        rto_kg = get_param(data.display_block_kg, 'RuntimeObject');
        if ~isempty(rto_kg), val_kg = rto_kg.InputPort(1).Data; end
        
        try
            rto_mv = get_param(data.display_block_mv, 'RuntimeObject');
            if ~isempty(rto_mv), val_mv = rto_mv.InputPort(1).Data; end
        catch
        end
        
        t_rec = toc(data.t_start);
        now_str = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));

        % บันทึกค่า kg, mV, เวลาสะสม และ Timestamp
        data.Data_kg(1, data.current_w_idx) = val_kg;
        data.Data_mv(1, data.current_w_idx) = val_mv;
        data.Time_matrix(1, data.current_w_idx) = t_rec;
        data.Timestamp_matrix(1, data.current_w_idx) = now_str;

        data.lbl_status.Text = sprintf('✅ บันทึก [%d kg] = %.4f kg (%.3f mV) เรียบร้อย!', ...
            data.W_actual(data.current_w_idx), val_kg, val_mv);

        if data.current_w_idx < data.n_weights
            data.current_w_idx = data.current_w_idx + 1;
            data.drop_weight.Value = data.current_w_idx;
        else
            uialert(fig, '🎉 วัดครบ 1 รอบ (0-10 kg) เรียบร้อยแล้ว! สามารถกดเซฟ CSV ได้เลย', 'Completed');
        end

        fig.UserData = data;
        draw_plots_cb(fig);
    catch
        uialert(fig, 'ไม่สามารถดึงค่าได้ โปรดตรวจสอบว่า Simulink กำลัง RUN อยู่', 'Error');
    end
end

function draw_plots_cb(fig)
    data = fig.UserData;
    W_actual = data.W_actual;
    Measured_mv = data.Data_mv(1, :);

    % พล้อต Calibration Curve ระหว่าง Actual (kg) vs Measured (mV)
    plot(data.ax_cal, W_actual, Measured_mv, 'cyan-o', 'LineWidth', 2, 'MarkerFaceColor', 'c');
    style_axes_dark(data.ax_cal, '🎯 Calibration Curve (Voltage mV vs Actual kg)', data.ax_bg, data.txt_col, data.grid_col);
    xlabel(data.ax_cal, 'Actual Weight (kg)'); ylabel(data.ax_cal, 'Measured Signal (mV)');
    xlim(data.ax_cal, [-0.5 10.5]); grid(data.ax_cal, 'on');
end

function save_csv_cb(fig)
    data = fig.UserData;
    W_actual = data.W_actual;
    Measured_kg = data.Data_kg(1, :);
    Measured_mv = data.Data_mv(1, :);
    Time_s = data.Time_matrix(1, :);
    Timestamps = data.Timestamp_matrix(1, :)';
    Error_kg = Measured_kg - W_actual;

    % สร้างตารางข้อมูลที่มี Timestamp, Elapsed Time, Actual kg, Measured kg, Measured mV และ Error kg
    T = table(Timestamps, Time_s', W_actual', Measured_kg', Measured_mv', Error_kg', ...
        'VariableNames', {'Timestamp', 'Elapsed_Time_s', 'Actual_kg', 'Measured_kg', 'Measured_mV', 'Error_kg'});

    filename = 'LoadCell_Realtime_UI_Data.csv';
    writetable(T, filename);
    uialert(fig, ['บันทึกไฟล์เรียบร้อย: ' filename], 'Success');
end

function close_gui_cb(fig, live_timer)
    if isvalid(live_timer)
        stop(live_timer);
        delete(live_timer);
    end
    delete(fig);
end

function style_axes_dark(ax, title_str, ax_bg, txt_col, grid_col)
    ax.Color = ax_bg; ax.XColor = txt_col; ax.YColor = txt_col;
    ax.GridColor = grid_col; ax.GridAlpha = 0.5; ax.FontSize = 10;
    title(ax, title_str, 'Color', txt_col, 'FontSize', 11, 'FontWeight', 'bold');
end