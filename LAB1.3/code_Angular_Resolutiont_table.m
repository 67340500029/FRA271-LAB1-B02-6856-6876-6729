clear; clc;

Encoder = [
    "BOURNS"
    "BOURNS"
    "BOURNS"
    "AMT103"
    "AMT103"
    "AMT103"
    ];

Mode = [
    "X1"
    "X2"
    "X4"
    "X1"
    "X2"
    "X4"
    ];

PPR = [
    24
    24
    24
    2048
    2048
    2048
    ];

ModeMultiplier = [
    1
    2
    4
    1
    2
    4
    ];

% จำนวน Count ต่อหนึ่งรอบ
CPR = PPR.*ModeMultiplier;

% ความละเอียดเชิงมุม
Resolution_deg_per_count = 360./CPR;
Resolution_rad_per_count = (2*pi)./CPR;

AngularResolutionTable = table(...
    Encoder,...
    Mode,...
    PPR,...
    ModeMultiplier,...
    CPR,...
    Resolution_deg_per_count,...
    Resolution_rad_per_count);

disp(AngularResolutionTable);

% บันทึกเป็น Excel
writetable(AngularResolutionTable,...
    'Angular_Resolution_Table.xlsx');