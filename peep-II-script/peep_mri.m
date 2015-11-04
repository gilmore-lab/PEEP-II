function peep_mri()

% Change to project working directory
cd('~/github/gilmore-lab/peep-II/peep-II-script');

% Running on PTB-3? Abort otherwise.
AssertOpenGL;
clear;
clc;

% Intor messages
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('This is the PEEP-II script.\n\n');

% Load environment, session info
environment = set_peep_environment();
load('default_session.mat');

% Run
session = get_peep_session_data(session, environment);
peep_run(session, environment);
 
% Clean-up



