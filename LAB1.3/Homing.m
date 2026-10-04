function pos_homed = Homing(pos_in, trigger_home)
persistent home_offset;

if isempty(home_offset)
    home_offset = 0;
end

if trigger_home > 0
    home_offset = pos_in;
end

pos_homed = pos_in - home_offset;
end