% set_peep_defaults.m
% Sets default values for session and environment data structures.
% Saves to default_session.mat and default_environment.mat.

if exist('session')
    clear('session')
end
session.this_family = '0001';
session.nov_family = '0002';
session.run = '1';
session.order = '1';

save('default_session.mat', 'session');
clear('session');

% Environment
if exist('environment')
    clear('environment')
end
environment.mri_TR = 2;
environment.sound_secs = 10;
environment.silence_secs = 6;
environment.data_dir = '/mri-behavior';
environment.sound_dir = '/wav';

save('default_environment.mat', 'environment');
clear('environment');