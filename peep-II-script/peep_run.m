function peep_run(session, environment)

if isempty(session)
    fprintf('Session is blank; loading default_session.mat.\n');
    session = load('default_session.mat');
    session.timestamp = datestr(now, 'yyyy-mm-dd-HHMMSS');
else
    run = session.run;
    order = session.order;
    fam = session.this_family;
    nov = session.nov_family;
    timestamp = session.timestamp;
end

% Load run and order data from file into cell array of filenames
% Load first sound file since there is no silent period to start

% Show ready to start run screen

% Wait for scanner trigger

% for stim = 1:n_stims, loop 
% play_stim(stim)
% write data about stim to file
% show_circle
% write data about circle to file
% wait for user response
% write data about user response
% play environment.silence_secs of silence
% load next sound during silence
% show_circle
% write data about circle to file
% wait for user response
% write data about user response
% endloop




