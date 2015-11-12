function peep_mri()

% Change to project working directory
cd('~/github/gilmore-lab/peep-II/peep-II-script');

% Start diary
diary(sprintf('diary/%s-diary.txt', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF')));

% Running on PTB-3? Abort otherwise.
AssertOpenGL;
clear;
clc;
KbName('UnifyKeyNames');

% Intro remarks
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('This is the PEEP-II script.\n\n');

% Load environment, session info
environment = set_peep_environment();
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Loaded environment.\n\n');

load('default_session.mat');
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('Loaded default session.\n\n');

% Get session data for this run
session = get_peep_session_data(session, environment);

% Create run-specific log file
log_fn = strcat('log/', session.this_family, '-', datestr(now, 'yyyy-mm-dd-HHMM'), '-run-', session.run, '-order-', session.order, '.log');
[log_fid, ~] = fopen(log_fn, 'w');
peep_log_msg('Opened log file: log_fn\n', GetSecs(), log_fid);
environment.log_fid = log_fid;

peep_run(session, environment);
 
% Clean-up
diary off;
fclose('all');
Screen('CloseAll');



