function collect_ratings(session, environment)
% peep_ratings(session, environment)
%   Controls a particular run of the PEEP-II ratings cexperiment.

% Rick Gilmore, 2015-11-17

% Dependencies
%
% Called by:
%   peep_ratings.m
%
% Calls:
%   peep_log_msg.m
%   load_rating_faces
%   create_run_file_list.m
%   load_peep_sound.m
%   txt_2_screen.m
%   handle_keypress.m
%   update_screen.m

% 2015-11-17 rog wrote
% 2015-12-29 rog debugged handle_keypress, update_screen.
%--------------------------------------------------------------------------

if (nargin < 2)
    load('default_session.mat');
    load('default_environment.mat');
end

if isempty(session)
    peep_log_msg(sprintf('Session is blank; loading default_session.mat.'), GetSecs, environment.log_fid);
    session = load('default_session.mat');
else
    run = session.run;
    order = session.order;
    fam = session.this_family;
    nov = session.nov_family;
end

% Open window for participant
try
    Screen('Preference', 'SkipSyncTests', 1);
    environment.win_ptr = Screen('OpenWindow', max(environment.screenNumbers));
    txt_2_screen('Welcome to PEEP ratings', environment.win_ptr, environment);
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

% Load faces
environment = load_rating_faces(environment);

% Load run and order data from file into cell array of filenames
peep_log_msg(sprintf('Initializing run %s, order %s for participant %s. Unfamiliar family is %s.\n', run, order, fam, nov), GetSecs(), environment.log_fid);
session.this_run_data = create_run_file_list(environment, session);
session.n_snds = height(session.this_run_data);

session.ratings = zeros(session.n_snds,6); % initialize rating matrix

% Load first sound file since there is no silent period to start
status.snd_index = 1;
peep_log_msg(sprintf('Loading sound %i of %i sounds: %s.\n\n', status.snd_index, session.n_snds, char(session.this_run_data.File(status.snd_index))), GetSecs(), environment.log_fid);
[this_snd, snd_freq, nrchannels] = load_peep_sound(session.this_run_data.File(status.snd_index));

% Perform basic initialization of the sound driver:
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
try
    % Try with the frequency we want
    session.pahandle = PsychPortAudio('Open', [], [], 0, snd_freq, nrchannels);
    PsychPortAudio('FillBuffer', session.pahandle, this_snd);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', snd_freq);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    session.pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
end

% Show ready to start run screen
KbReleaseWait;
txt_2_screen('Press any key to start ratings.\n', environment.win_ptr, environment);
KbStrokeWait;

% % Create and start Kb queues
% KbQueueCreate(environment.internal_kbd_index, environment.keysOfInterest);
% KbQueueStart(environment.internal_kbd_index);        

% Initialize status
status.continue = 1;
status.play = 0;
status.highlighted_index = 1;
status.rating_index = 0; % At start of rating
status.ratings_finished = 0;

% Then loop for other sounds
while status.continue
    [ status, session ] = handle_keypress(session, environment, status);
    update_screen(session, environment, status);
    WaitSecs(environment.interkey_secs); % space between keypress detections.
end % while

% All done screen
try
    txt_2_screen('All Finished!', environment.win_ptr, environment);
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    diary off;
    fclose('all');
    Screen('CloseAll');t
end % try

end
