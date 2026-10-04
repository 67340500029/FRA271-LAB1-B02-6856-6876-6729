function continuous_count = WrapAround(raw_count)

PERIOD = 65536; 
HALF_PERIOD = PERIOD / 2; % 32768

persistent last_raw;
persistent total_pos;

if isempty(last_raw)
    last_raw = double(raw_count);
    total_pos = double(raw_count);
end

current_raw = double(raw_count);
delta = current_raw - last_raw;

% ดักจับ Overflow
if delta < -HALF_PERIOD
    delta = delta + PERIOD;
    % ดักจับ Underflow
elseif delta > HALF_PERIOD
    delta = delta - PERIOD;
end

total_pos = total_pos + delta;
last_raw = current_raw;

continuous_count = total_pos;
end