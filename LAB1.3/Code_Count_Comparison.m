clear; clc; close all;

encoderNames = ["BOURNS","AMT103"];
PPR = [24, 2048];

modes = ["X1","X2","X4"];
modeMultiplier = [1, 2, 4];

% ตัวแปรสำหรับเก็บผลลัพธ์
measuredMean = zeros(2,3);
measuredSD   = zeros(2,3);
theoretical  = zeros(2,3);
errorPercent = zeros(2,3);

% เก็บค่าของแต่ละรอบไว้ตรวจสอบ
allMeasured = zeros(2,3,3);

for e = 1:2

    theoretical(e,:) = PPR(e)*modeMultiplier;

    for m = 1:3

        finalCount = zeros(1,3);

        for r = 1:3

            filename = sprintf('%s_%s_CW_%d.xlsx',...
                encoderNames(e),modes(m),r);

            T = readtable(filename,...
                'VariableNamingRule','preserve');

            % หาจุดสุดท้ายที่กด Home
            idxHome = find(T.home_trigger == 1,1,'last');

            if isempty(idxHome)
                error('ไม่พบ home_trigger ในไฟล์ %s',filename);
            end

            % อ่านข้อมูลหลัง Homing
            count = double(T.homed_count(idxHome+1:end));

            % ทำให้ค่าเริ่มต้นเท่ากับศูนย์
            count = count-count(1);

            % ใช้ค่ามัธยฐาน 500 ตัวอย่างสุดท้าย
            % เพื่อป้องกัน Noise ของข้อมูลจุดสุดท้าย
            tailStart = max(1,length(count)-499);
            finalCount(r) = abs(median(count(tailStart:end)));

            fprintf('%s %s รอบ %d = %.0f counts\n',...
                encoderNames(e),modes(m),r,finalCount(r));
        end

        allMeasured(e,m,:) = finalCount;

        % ค่าเฉลี่ยและส่วนเบี่ยงเบนมาตรฐาน
        measuredMean(e,m) = mean(finalCount);
        measuredSD(e,m)   = std(finalCount);

        % เปอร์เซ็นต์ความคลาดเคลื่อน
        errorPercent(e,m) = ...
            abs(measuredMean(e,m)-theoretical(e,m))...
            /theoretical(e,m)*100;
    end
end

fig = figure('Color','w');
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');

for e = 1:2

    ax = nexttile;

    % คอลัมน์ที่ 1 = ค่าทฤษฎี
    % คอลัมน์ที่ 2 = ค่าเฉลี่ยจากการทดลอง
    Y = [theoretical(e,:)', measuredMean(e,:)'];

    b = bar(ax,1:3,Y,'grouped');
    hold(ax,'on');

    b(1).FaceColor = [0.25 0.45 0.85];
    b(2).FaceColor = [0.95 0.45 0.15];

    % Error bar ของค่าที่วัดได้
    drawnow;

    errorbar(ax,b(2).XEndPoints,...
        measuredMean(e,:),...
        measuredSD(e,:),...
        'k.',...
        'LineWidth',1.3,...
        'CapSize',8);

    xticks(ax,1:3);
    xticklabels(ax,modes);

    xlabel(ax,'Encoder mode','Color','k');
    ylabel(ax,'Counts per revolution','Color','k');

    ttl = title(ax,...
    sprintf('%s: Theoretical vs Measured Counts',encoderNames(e)),...
    'FontWeight','bold',...
    'Color','k');

   
    lgd = legend(ax,...
    'Theoretical',...
    'Measured mean',...
    'Standard deviation',...
    'Location','northwest');
    
    set(lgd,...
        'Color','w',...
        'TextColor','k',...
        'EdgeColor','k');

    grid(ax,'on');
    box(ax,'on');

    ax.Color = 'w';
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.GridColor = [0.75 0.75 0.75];
    ax.FontSize = 11;
end

fig.Position = [100 100 1200 520];

exportgraphics(fig,...
    'Encoder_Count_Theoretical_vs_Measured.png',...
    'Resolution',300);

Encoder = [
    "BOURNS"; "BOURNS"; "BOURNS";
    "AMT103"; "AMT103"; "AMT103"
    ];

Mode = [
    "X1"; "X2"; "X4";
    "X1"; "X2"; "X4"
    ];

Theory = [
    theoretical(1,:)';
    theoretical(2,:)'
    ];

MeasuredMean = [
    measuredMean(1,:)';
    measuredMean(2,:)'
    ];

SD = [
    measuredSD(1,:)';
    measuredSD(2,:)'
    ];

Error_percent = [
    errorPercent(1,:)';
    errorPercent(2,:)'
    ];

ResultTable = table(...
    Encoder,...
    Mode,...
    Theory,...
    MeasuredMean,...
    SD,...
    Error_percent);

disp(ResultTable);

% บันทึกตารางออกเป็น Excel
writetable(ResultTable,...
    'Encoder_Count_Summary.xlsx');