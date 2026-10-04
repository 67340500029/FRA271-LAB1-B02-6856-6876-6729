T = readtable('LoadCell_Realtime_UI_Data.csv');
figure('Color', 'w');
plot(T.Actual_kg, T.Actual_kg, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal'); hold on;
plot(T.Actual_kg, T.Run1_kg, 'ro-', 'LineWidth', 1.5, 'DisplayName', 'Run 1');
plot(T.Actual_kg, T.Run2_kg, 'c^-', 'LineWidth', 1.5, 'DisplayName', 'Run 2');
plot(T.Actual_kg, T.Run3_kg, 'gs-', 'LineWidth', 1.5, 'DisplayName', 'Run 3');
plot(T.Actual_kg, T.Average_kg, 'm*-', 'LineWidth', 2.5, 'DisplayName', 'Average');
grid on; xlabel('Actual (kg)'); ylabel('Measured (kg)');
title('Load Cell Calibration Curve'); legend('Location', 'northwest');