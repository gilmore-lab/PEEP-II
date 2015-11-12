function [mins, secs] = secs2mins(total_secs)
% Converts seconds into minutes and seconds
secs = round(mod(total_secs, 60), 3);
mins = floor(total_secs/60);
return