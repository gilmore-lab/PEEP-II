function [ rating ] = get_rating( rating_type, snd, session, environment )

% Create display
%   1. Instructions
%   2. Face icons

% Load sound
[this_snd, snd_freq, nrchannels] = load_peep_sound(snd);

% Gather rating input or handle other keyboard/mouse events

% Write rating input to file

