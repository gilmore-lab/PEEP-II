function session = get_peep_session_data(session, ~)
% get_peep_session_data(environment, session) 

% Load default environment info if not passed.
if not(exist('environment', 'var'))
    load('default_environment.mat');
end 
   
% Prompt user for session info
prompt = {'This family ID (0nnn):', 'Novel family ID (0nnn):', 'Order:', 'Run:', 'RA1:', 'RA2:'};
title = 'Session Information';

defaults = {session.this_family, session.nov_family, char(session.order), char(session.run), 'RW', 'MM'};
answers = inputdlg(prompt, title, 1, defaults);
this_family = answers{1};
nov_family = answers{2};
order = answers{3};
run = answers{4};
ra1 = answers{5};
ra2 = answers{6};

% create session data structure
session = [];

session.timestamp = datestr(now, 'yyyy-mm-dd-HHMMSS');
session.this_family = this_family;
session.nov_family = nov_family;
session.run = run;
session.order = order;
session.ra1 = ra1;
session.ra2 = ra2;

return