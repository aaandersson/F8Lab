%% Searching for ports

disp(["Ports:" serialportlist()])

%% Open connection to motor

% Where is the USB plugged in to the computer?
port = "COM5";

% Where is the motor plugged in to the TMCL box?
axis = 2;

% Create StepperMotor object
sm = StepperMotor(port,axis);

%% Calibrate position to left switch

% Move to the left switch
disp 'Moving...'
sm.SeekLeftSwitch()

% Define as position=0
sm.DefPosition(0)

%% Set and get position

disp 'Moving...'
sm.SetPosition(112000)

disp 'Arrived at:'
disp(sm.GetPosition())

disp 'Moving...'
sm.ModPosition(100)

disp 'Arrived at:'
disp(sm.GetPosition())

%% Close connection to motor

clear sm StepperMotor