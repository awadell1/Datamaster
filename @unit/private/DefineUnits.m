function unitDef = DefineUnits()
%Define Units for use by Datamaster

%% Velocity
%m/s
unitDef(end+1) = unit('m/s');
unitDef(end).scale = 1;
unitDef(end).m = 1;
unitDef(end).s = -1;

unitDef(end).Shift = 0;

%Miles Per Hour
unitDef(end+1) = unit('mph');
unitDef(end).scale = 1609.34/3600;
unitDef(end).m = 1;
unitDef(end).s = -1;

%kph
unitDef(end+1) = unit('kph');
unitDef(end).scale = 1e3/3600;
unitDef(end).m = 1;
unitDef(end).s = -1;

%% Angular Velocity
%rad/s
unitDef(end+1) = 'rad/s';
unitDef(end).m = [1 1];
unitDef(end).s = 1;

%rpm
unitDef(end+1) = 'rpm';
unitDef(end).m = [1 1];
unitDef(end).s = 1;
unitDef(end).scale = 2*pi/60;

%% Acceleration
%m/s2
unitDef(end+1) = unit('m/s^2');
unitDef(end).m = 1;
unitDef(end).s = -2;

%G Force
unitDef(end+1) = unit('G');
unitDef(end).scale = 9.80665;
unitDef(end).m = 1;
unitDef(end).s = -2;

%% Pressure
unitDef(end+1).name = 'Pa';
unitDef(end).kg = 1;
unitDef(end).m = 1;
unitDef(end).s = -2;

%bar
unitDef(end+1).name = 'bar';
unitDef(end).scale = 1e5;
unitDef(end).kg = 1;
unitDef(end).m = 1;
unitDef(end).s = -2;

%kPa
unitDef(end+1).name = 'kPa';
unitDef(end).UnitMulti = 1e3;
unitDef(end).kg = 1;
unitDef(end).m = 1;
unitDef(end).s = -2;

%psi
unitDef(end+1).name = 'psi';
unitDef(end).scale = 6895;
unitDef(end).kg = 1;
unitDef(end).m = 1;
unitDef(end).s = -2;

%atm
unitDef(end+1).name = 'atm';
unitDef(end).scale = 101325;
unitDef(end).kg = 1;
unitDef(end).m = 1;
unitDef(end).s = -2;

%% Temperature
unitDef(end+1).name = 'K';
unitDef(end).K = 1;

unitDef(end+1).name = 'F';
unitDef(end).K = 1;
unitDef(end).scale = 5/9;
unitDef(end).shift = 459.67 * 5/9;

unitDef(end+1).name = 'C';
unitDef(end).K = 1;
unitDef(end).Shift = 273.15;