function [mins, secs] = secs2mins(total_secs)
% Converts seconds into minutes and seconds
secs = sprintf('%5.3f', round(mod(total_secs, 60), 3));
mins = sprintf('%i', floor(total_secs/60));
return