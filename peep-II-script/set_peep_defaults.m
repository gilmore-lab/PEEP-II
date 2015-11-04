function set_peep_defaults
% Sets default values for session and environment data structures.
% Saves to default_session.mat and default_environment.mat.

if exist('session')
    clear('session')
end
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
environment.mri_TR = 2;
environment.sound_secs = 10;
environment.silence_secs = 6;
environment.root_dir = 'peep-II-script';
environment.beh_dir = 'beh';
environment.sound_dir = 'wav/norm';
environment.run_orders_dir = 'run-orders';
environment.tKey = KbName('t');
environment.escapeKey = KbName('ESCAPE');

save('default_environment.mat', 'environment');
fprintf('default_environment.mat saved\n');
clear('environment');