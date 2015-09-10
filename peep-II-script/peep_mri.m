function peep_mri()

% Running on PTB-3? Abort otherwise.
AssertOpenGL;

% Intor messages
fprintf('%s : ', datestr(now, 'yyyy-mm-dd-HH:MM:SS.FFF'));
fprintf('This is the PEEP-II script.\n\n');

% Load environment, session info
environment = set_peep_environment();

% Run
session = get_peep_session_data(environment);
peep_run(session, environment);

% Clean-up





