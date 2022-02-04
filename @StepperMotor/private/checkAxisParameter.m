function paramCode = checkAxisParameter(param,value)
S = split(strip(provideS));
paramCode = int32(str2double(S(:,1)));
paramName = S(:,2);
minValue = int32(str2double(S(:,3)));
maxValue = int32(str2double(S(:,4)));
flagR = contains(S(:,5),"R");
flagW = contains(S(:,5),"W");
%flagE = contains(S(:,5),"E");

% Check that param is in the list
assert(isscalar(param))
if isstring(param)
    index = find(param==paramName);
    if isempty(index), error("Parameter '%s' is not supported!",param), end
elseif isnumeric(param)
    index = find(param==paramCode);
    if isempty(index), error("Parameter %d is not supported!",param), end
end
paramCode = paramCode(index); paramName = paramName(index);
minValue = minValue(index); maxValue = maxValue(index);
flagR = flagR(index); flagW = flagW(index);

errpre = sprintf("Parameter '%s' (%d)",paramName,paramCode);
if nargin<2 % Check Get
    assert(flagR,errpre+" is not readable!",param)
else % check Set
    assert(flagW,errpre+" is not writable!",param)
    assert(value>=minValue && value<=maxValue,...
        errpre+" exceeds the range %d...%d!",minValue,maxValue);
end

end


function S = provideS()
S = [% N  Parameter                min          max         flags
    "  0  TargetPosition           -2147483648  2147483647  RW "
    "  1  ActualPosition           -2147483648  2147483647  RW "
    "  2  TargetSpeed                    -2047        2047  RW "
    "  3  ActualSpeed                    -2047        2047  R  "
    "  4  MaximumPositioningSpeed            1        2047  RWE"
    "  5  MaximumAcceleration                1        2047  RWE"

    "  6  MaximumCurrent                     0         255  RW "
    "  7  StandbyCurrent                     0         255  RW "
    "  8  PostionReachedFlag                 0           1  R  "
    "  9  HomeSwitchState                    0           1  R  "
    " 10  RightLimitSwitchState              0           1  R  "
    " 11  LeftLimitSwitchState               0           1  R  "
    " 12  RightLimitSwitchDisable            0           1  RWE"
    " 13  LeftLimitSwitchDisable             0           1  RWE"
    "130  MinimumSpeed                       0        2047  RWE"
    "135  ActualAcceleration                 0        2047  R  "

    "138  RampMode                           0           2  RW "
    "140  MicroStepResulution                0           8  RW "
    "149  SoftStopFlag                       0           1  RWE"
    "150  EndSwitchPowerDownMode             0           1  RW "
    "153  RampDivisor                        0          13  RWE"

    "154  PulseDivisor                       0          13  RWE"
    "160  StepInterolationEnable             0           1  RW "
    "161  DoubleStepEnable                   0           1  RW "
    "162  ChopperBlankTime                   0           3  RW "
    "163  ConstantTOffMode                   0           1  RW "
    "164  DisableFastDecayCompensator        0           1  RW "
    "165  ChopperHysteresisEnd               0          15  RW "
    "166  ChopperHysteresisStart             0           8  RW "

    "193  ReferenceSearchMode                0         136  RW "
    % TBC
    ];
end
