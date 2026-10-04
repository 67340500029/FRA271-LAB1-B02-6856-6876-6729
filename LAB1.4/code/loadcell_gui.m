% =========================================================================
% MATLAB Real-Time Load Cell Calibration UI (3 Runs: Actual kg vs mV Plot)
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

% 2. ตัวแปรเก็บข้อมูล (เริ่มตั้งแต่ 0 ถึง 10 kg)
W_actual = 0:10;
n_weights = length(W_actual); % 11 จุด
n_runs = 3;

% เก็บข้อมูลโครงสร้างไว้ใน struct
appData = struct();
appData.W_actual = W_actual;
appData.n_weights = n_weights;
appData.n_runs = n_runs;
appData.Data_kg = NaN(n_runs, n_weights); % 3 Rows x 11 Columns (เก็บค่า kg)
appData.Data_mv = NaN(n_runs, n_weights); % 3 Rows x 11 Columns (เก็บค่า mV)
appData.current_run = 1;
appData.current_w_idx = 1;
appData.display_block_kg = display_block_kg;
appData.display_block_mv = display_block_mv;

% 3. ธีมสี Dark Mode & Font
fig_bg   = [0.10 0.10 0.10];
panel_bg = [0.15 0.15 0.15];
ax_bg    = [0.20 0.20 0.20];
txt_col  = [1.00 1.00 1.00];
grid_col = [0.35 0.35 0.35];

% 4. สร้างหน้าต่าง UI Figure
fig = uifigure('Name', ['Load Cell Live Calibration UI (mV vs Kg) - Model: ' model_name], ...
    'Color', fig_bg, 'Position', [50, 50, 1300, 800]);

grid_main = uigridlayout(fig, [1, 2]);
grid_main.ColumnWidth = {340, '1x'};

% -------------------------------------------------------------------------
% PANEL 1: คอนโทรลและปุ่มกด (ด้านซ้าย)
% -------------------------------------------------------------------------
p_ctrl = uipanel(grid_main, 'Title', '🎛 Control Panel', ...
    'BackgroundColor', panel_bg, 'ForegroundColor', txt_col, ...
    'FontSize', 14, 'FontWeight', 'bold');

p_ctrl_grid = uigridlayout(p_ctrl, [9, 1]);
p_ctrl_grid.RowHeight = {40, 60, 40, 40, 50, 30, 40, 40, '1x'};

% เลือกรอบ Run
uilabel(p_ctrl_grid, 'Text', '📍 เลือกรอบการวัด (Run):', ...
    'FontColor', txt_col, 'FontSize', 12, 'FontWeight', 'bold');
drop_run = uidropdown(p_ctrl_grid, ...
    'Items', {'Run 1', 'Run 2', 'Run 3'}, ...
    'ItemsData', [1, 2, 3], ...
    'Value', appData.current_run, 'FontSize', 12);

% เลือน้ำหนักอ้างอิง (0 kg - 10 kg)
uilabel(p_ctrl_grid, 'Text', '⚖️ ค่าน้ำหนักอ้างอิง (Target Kg):', ...
    'FontColor', txt_col, 'FontSize', 12, 'FontWeight', 'bold');
drop_weight = uidropdown(p_ctrl_grid, ...
    'Items', arrayfun(@(x) sprintf('%d kg', x), W_actual, 'UniformOutput', false), ...
    'ItemsData', 1:n_weights, ...
    'Value', appData.current_w_idx, 'FontSize', 12);

% ค่า Live สดจาก Simulink (แสดงทั้ง kg และ mV)
lbl_live_val = uilabel(p_ctrl_grid, ...
    'Text', 'Live Signal: 0.0000 kg | 0.0000 mV', ...
    'FontColor', [0.3 1 0.3], ...
    'FontSize', 15, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center');

% ปุ่มกด RECORD DATA
btn_record = uibutton(p_ctrl_grid, ...
    'Text', '📸 บันทึกค่า (Record)', ...
    'BackgroundColor', [0.1 0.6 0.2], 'FontColor', [1 1 1], ...
    'FontSize', 14, 'FontWeight', 'bold');

% ปุ่มกด SAVE CSV
btn_save = uibutton(p_ctrl_grid, ...
    'Text', '💾 เซฟไฟล์ CSV', ...
    'BackgroundColor', [0.1 0.4 0.8], 'FontColor', [1 1 1], ...
    'FontSize', 13, 'FontWeight', 'bold');

% สถานะแจ้งเตือน
lbl_status = uilabel(p_ctrl_grid, ...
    'Text', 'พร้อมบันทึกข้อมูล...', ...
    'FontColor', [0.8 0.8 0.8], 'FontSize', 11, ...
    'HorizontalAlignment', 'center');

% -------------------------------------------------------------------------
% PANEL 2: แสดงกราฟ 4 ช่องแบบ Dark Mode (ด้านขวา - mV vs kg)
% -------------------------------------------------------------------------
p_plots = uipanel(grid_main, 'Title', '📊 Voltage vs Weight Calibration Dashboard', ...
    'BackgroundColor', panel_bg, 'ForegroundColor', txt_col, ...
    'FontSize', 14, 'FontWeight', 'bold');

grid_plots = uigridlayout(p_plots, [2, 2]);
ax1 = uiaxes(grid_plots); style_axes_dark(ax1, 'Run 1: Voltage Signal (mV)', ax_bg, txt_col, grid_col);
ax2 = uiaxes(grid_plots); style_axes_dark(ax2, 'Run 2: Voltage Signal (mV)', ax_bg, txt_col, grid_col);
ax3 = uiaxes(grid_plots); style_axes_dark(ax3, 'Run 3: Voltage Signal (mV)', ax_bg, txt_col, grid_col);
ax4 = uiaxes(grid_plots); style_axes_dark(ax4, 'All Runs & Average mV Comparison', ax_bg, txt_col, grid_col);

% ผูกออบเจกต์ UI เข้ากับ UserData
appData.drop_run = drop_run;
appData.drop_weight = drop_weight;
appData.lbl_live_val = lbl_live_val;
appData.lbl_status = lbl_status;
appData.ax1 = ax1; appData.ax2 = ax2; appData.ax3 = ax3; appData.ax4 = ax4;
appData.ax_bg = ax_bg; appData.txt_col = txt_col; appData.grid_col = grid_col;
fig.UserData = appData;

% กำหนด Event Callback
drop_run.ValueChangedFcn = @(src, evt) change_run_cb(fig, src.Value);
drop_weight.ValueChangedFcn = @(src, evt) change_weight_cb(fig, src.Value);
btn_record.ButtonPushedFcn = @(src, evt) record_data_cb(fig);
btn_save.ButtonPushedFcn = @(src, evt) save_csv_cb(fig);

% Timer อ่านค่าสด Real-time ทุกๆ 0.1 วินาที
live_timer = timer(...
    'ExecutionMode', 'fixedRate', ...
    'Period', 0.1, ...
    'TimerFcn', @(~,~) update_live_reading_cb(fig));
start(live_timer);
fig.CloseRequestFcn = @(~,~) close_gui_cb(fig, live_timer);

% =========================================================================
% LOCAL FUNCTIONS (ฟังก์ชันย่อยสำหรับการทำงาน)
% =========================================================================

function update_live_reading_cb(fig)
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
        val_mv = NaN;
    end
    
    if isnan(val_mv)
        data.lbl_live_val.Text = sprintf('Live: %.4f kg | (No /mV)', val_kg);
    else
        data.lbl_live_val.Text = sprintf('Live: %.4f kg | %.4f mV', val_kg, val_mv);
    end
end

function change_run_cb(fig, val)
    data = fig.UserData;
    data.current_run = val;
    data.lbl_status.Text = sprintf('เลือกรอบเป็น: Run %d', val);
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
        val_kg = 0; val_mv = 0;
        rto_kg = get_param(data.display_block_kg, 'RuntimeObject');
        if ~isempty(rto_kg), val_kg = rto_kg.InputPort(1).Data; end
        
        try
            rto_mv = get_param(data.display_block_mv, 'RuntimeObject');
            if ~isempty(rto_mv), val_mv = rto_mv.InputPort(1).Data; end
        catch
            val_mv = NaN;
        end
        
        % บันทึกค่าทั้ง kg และ mV
        data.Data_kg(data.current_run, data.current_w_idx) = val_kg;
        data.Data_mv(data.current_run, data.current_w_idx) = val_mv;
        
        data.lbl_status.Text = sprintf('✅ Run %d [%d kg] = %.4f kg (%.4f mV) สำเร็จ!', ...
            data.current_run, data.W_actual(data.current_w_idx), val_kg, val_mv);
        
        if data.current_w_idx < data.n_weights
            data.current_w_idx = data.current_w_idx + 1;
            data.drop_weight.Value = data.current_w_idx;
        else
            if data.current_run < data.n_runs
                data.current_run = data.current_run + 1;
                data.current_w_idx = 1;
                data.drop_run.Value = data.current_run;
                data.drop_weight.Value = data.current_w_idx;
                uialert(fig, sprintf('รอบที่ %d ครบแล้ว! กำลังเริ่ม Run %d', data.current_run-1, data.current_run), 'Notice');
            else
                uialert(fig, '🎉 วัดค่าครบทั้ง 3 รอบ (0-10 kg) เรียบร้อยแล้ว! สามารถกดเซฟ CSV ได้เลย', 'Completed');
            end
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
    Data_mv = data.Data_mv;
    
    Run1_mv = Data_mv(1, :);
    Run2_mv = Data_mv(2, :);
    Run3_mv = Data_mv(3, :);
    Run_mean_mv = mean(Data_mv, 1, 'omitnan');
    
    % พล้อตกราฟเทียบ Actual Weight (kg) vs Measured Signal (mV)
    plot(data.ax1, W_actual, Run1_mv, 'ro-', 'LineWidth', 2, 'MarkerFaceColor', 'r');
    style_axes_dark(data.ax1, 'Run 1 Calibration (mV vs kg)', data.ax_bg, data.txt_col, data.grid_col);
    
    plot(data.ax2, W_actual, Run2_mv, 'cyan^-', 'LineWidth', 2, 'MarkerFaceColor', 'cyan');
    style_axes_dark(data.ax2, 'Run 2 Calibration (mV vs kg)', data.ax_bg, data.txt_col, data.grid_col);
    
    plot(data.ax3, W_actual, Run3_mv, 'greens-', 'LineWidth', 2, 'MarkerFaceColor', 'green');
    style_axes_dark(data.ax3, 'Run 3 Calibration (mV vs kg)', data.ax_bg, data.txt_col, data.grid_col);
    
    plot(data.ax4, W_actual, Run1_mv, 'r:', 'LineWidth', 1.2); hold(data.ax4, 'on');
    plot(data.ax4, W_actual, Run2_mv, 'c:', 'LineWidth', 1.2);
    plot(data.ax4, W_actual, Run3_mv, 'g:', 'LineWidth', 1.2);
    plot(data.ax4, W_actual, Run_mean_mv, 'm*-', 'LineWidth', 2.5, 'MarkerSize', 8); hold(data.ax4, 'off');
    style_axes_dark(data.ax4, 'All Runs & Average mV Comparison', data.ax_bg, data.txt_col, data.grid_col);
end

function save_csv_cb(fig)
    data = fig.UserData;
    W_actual = data.W_actual;
    Data_kg = data.Data_kg;
    Data_mv = data.Data_mv;
    
    % คำนวณฝั่ง kg
    Run1_kg = Data_kg(1, :);
    Run2_kg = Data_kg(2, :);
    Run3_kg = Data_kg(3, :);
    Run_mean_kg   = mean(Data_kg, 1, 'omitnan');
    Error_mean_kg = Run_mean_kg - W_actual;
    Std_dev_kg    = std(Data_kg, 0, 1, 'omitnan');
    
    % คำนวณฝั่ง mV
    Run1_mV = Data_mv(1, :);
    Run2_mV = Data_mv(2, :);
    Run3_mV = Data_mv(3, :);
    Run_mean_mV = mean(Data_mv, 1, 'omitnan');
    Std_dev_mV  = std(Data_mv, 0, 1, 'omitnan');
    
    % รวมตาราง CSV ทั้ง kg และ mV
    T = table(W_actual', ...
        Run1_kg', Run2_kg', Run3_kg', Run_mean_kg', Error_mean_kg', Std_dev_kg', ...
        Run1_mV', Run2_mV', Run3_mV', Run_mean_mV', Std_dev_mV', ...
        'VariableNames', { ...
            'Actual_kg', ...
            'Run1_kg', 'Run2_kg', 'Run3_kg', 'Average_kg', 'Error_Mean_kg', 'StdDev_kg', ...
            'Run1_mV', 'Run2_mV', 'Run3_mV', 'Average_mV', 'StdDev_mV' ...
        });
        
    filename = 'LoadCell_3Runs_Calibration_Data.csv';
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
    ax.Color = ax_bg;
    ax.XColor = txt_col;
    ax.YColor = txt_col;
    ax.GridColor = grid_col;
    ax.GridAlpha = 0.5;
    ax.FontSize = 11;
    title(ax, title_str, 'Color', txt_col, 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(ax, 'Actual Weight (kg)'); 
    ylabel(ax, 'Measured Signal (mV)');
    xlim(ax, [-0.5 10.5]); 
    xticks(ax, 0:10);
    grid(ax, 'on');
end