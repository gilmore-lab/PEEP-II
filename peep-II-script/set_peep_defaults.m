function set_peep_defaults
% Sets default values for session and environment data structures.
% Saves to default_session.mat and default_environment.mat.

% 2015-11-05 rogilmore modified

if exist('session')
    clear('session')
end

cd('~/github/gilmore-lab/peep-II/peep-II-script');

% Session
session.this_family = '9999';
session.nov_family = '9998';
session.run = '1';
session.order = '1';

save('default_session.mat', 'session');
fprintf('default_session.mat saved\n');
clear('session');

% Environment
if exist('environment')
    clear('environment')
end

% Scan parameters
environment.scanner = 'Siemens Prisma 3T';
environment.center = 'PSU SLEIC, University Park, PA';
environment.mri_TR = 2;
environment.sound_secs = 10;
environment.silence_secs = 6;

% Directories
environment.root_dir = 'peep-II-script';
environment.beh_dir = 'beh';
environment.sound_dir = 'wav/norm';
environment.run_orders_dir = 'run-orders';

% Keys
environment.tKey = KbName('t');
environment.escapeKey = KbName('ESCAPE');
environment.aKey = KbName('a');
environment.bKey = KbName('b');
environment.cKey = KbName('c');
environment.dKey = KbName('d');

% Screen parameters
screenNumbers = Screen('Screens');
for s=1:length(screenNumbers)
    environment.scrns(s).scrNum = screenNumbers(s);
    environment.scrns(s).hz = Screen('FrameRate', screenNumbers(s));
    environment.scrns(s).rect = Screen('Rect', screenNumbers(s));
end

% Timing constants
environment.sound_secs = 10;
environment.sil_secs = 6;
environment.circle_chg_min_secs = 1.5; % 1.5 s from start of sound or silence
environment.circle_chg_max_secs = 8.5; % 1.5 s from end of sound or silence
environment.circle_chg_dur_secs = 1;   % 1 s duration

save('default_environment.mat', 'environment');
fprintf('default_environment.mat saved\n');
clear('environment');

return