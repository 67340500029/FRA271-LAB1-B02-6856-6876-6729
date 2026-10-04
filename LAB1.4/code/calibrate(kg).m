mV = [17.3, 578.4, 1420.1, 2822.5]; % ค่า mV ที่บันทึกได้
kg = [0, 2, 5, 10];                  % น้ำหนักจริง
p = polyfit(mV, kg, 1);
m = p(1)                             % ได้ค่า Slope (Gain)
c = p(2)                             % ได้ค่า Offset (Bias)


if isempty(V_zero)
    V_zero = 37.9;
    V_span = 2800.0;
    m = 0.003126;   % ใส่ค่า m ที่ Calibrate ได้
    c = -0.002448;  % ใส่ค่า c ที่ Calibrate ได้
    last_btn_zero = 0;
    last_btn_span = 0;
end