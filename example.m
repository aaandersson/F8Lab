%% Searching for ports

disp(["Ports:" serialportlist()])

%% Open connection to motor

% Where is the USB plugged in to the computer?
port = "COM6";

% Where is the motor plugged in to the TMCL box?
axis = 1;

% Create StepperMotor object
sm = StepperMotor(port,axis);

%% Set and get position

disp 'Moving...'
sm.SetPosition(51200)

disp 'Arrived at:'
disp(sm.GetPosition())

disp 'Moving...'
sm.SetPosition(0)

disp 'Arrived at:'
disp(sm.GetPosition())

%% Close connection to motor

clear sm