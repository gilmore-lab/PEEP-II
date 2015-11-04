function this_run_data = create_run_file_list(environment, session)
% create_run_file_list(environment, session)
%   Opens run order given current session, environment
%   and creates a table with the correct file names.
%
% 2015-09-10 rogilmore wrote

if (nargin < 2)
    load('default_session.mat');
    load('default_environment.mat');
end

this_family = session.this_family;
nov_family = session.nov_family;
run = session.run;
order = session.order;

% Load run order
run_orders = readtable(strcat(environment.run_orders_dir,'/', 'run_orders.csv'));

% Create filename based on run_orders
% Subset based on order, run

this_run_order = (run_orders.Run == str2num(run)) & (run_orders.Order == str2num(order));

% Relevant data in cols 1:3, 6 and 7
this_run_data = run_orders(this_run_order, [1 2 3 6 7]);

fam = strcmp(this_run_data.Speaker, 'fam');
this_run_data(fam,1) = {this_family};
this_run_data(~fam,1) = {nov_family};
this_run_data.File = strcat('wav/', this_run_data.Speaker, '/norm/', this_run_data.Speaker, '-', this_run_data.Emotion, '-', this_run_data.Script, '-', this_run_data.Version, '.wav');

% Convert to struct for more transparent access
%this_run_data = table2str(this_run_data);
return



