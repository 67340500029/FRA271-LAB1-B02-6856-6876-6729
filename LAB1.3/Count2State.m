function [theta_rad, theta_deg, omega_rad_s] = Count2State(pos_count, ppr, mode_mult, ts)
counts_per_rev = double(ppr) * double(mode_mult);

% คำนวณตำแหน่งเชิงมุม
theta_rad = (double(pos_count) / counts_per_rev) * (2 * pi);
theta_deg = (double(pos_count) / counts_per_rev) * 360.0;

% คำนวณความเร็วเชิงมุม
persistent last_theta;
if isempty(last_theta)
    last_theta = theta_rad;
end

delta_theta = theta_rad - last_theta;
omega_rad_s = delta_theta / ts;
last_theta = theta_rad;
end