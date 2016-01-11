function env = load_rating_faces( env )
% env = load_rating_faces( env )
%   Loads jpg images of sample faces into environment data structure.
%   Assumes images are in img/ relative to script home directory.
%   Creates array of images so that env.face(1).intensity(1) is the lowest
%   intensity angry face, env.face(1).intensity(4) is the highest intensity
%   angry face. *.face(2) are the happy faces, *.face(3) are the sad faces,
%   and *.face(4) are an array of neutral, mid-happy, mid-angry, mid-sad
%   faces.

% 2015-12-xx Rick Gilmore, rick.o.gilmore@gmail.com

% Dependencies
%
% Called by:
%   collect_ratings.m

% 2015-12-29 rog added face(4) to fix bug.
%--------------------------------------------------------------------------

% Load img files
ang1 = imread('img/ang-1.jpg');
ang2 = imread('img/ang-2.jpg');
ang3 = imread('img/ang-3.jpg');
ang4 = imread('img/ang-4.jpg');
hap1 = imread('img/hap-1.jpg');
hap2 = imread('img/hap-2.jpg');
hap3 = imread('img/hap-3.jpg');
hap4 = imread('img/hap-4.jpg');
sad1 = imread('img/sad-1.jpg');
sad2 = imread('img/sad-2.jpg');
sad3 = imread('img/sad-3.jpg');
sad4 = imread('img/sad-4.jpg');
neu1 = imread('img/ang-1.jpg');
yesImg = imread('img/yes-crop.jpg');
noImg = imread('img/no-crop.jpg');

% Make textures
angTex1 = Screen('MakeTexture', env.win_ptr, ang1);
angTex2 = Screen('MakeTexture', env.win_ptr, ang2);
angTex3 = Screen('MakeTexture', env.win_ptr, ang3);
angTex4 = Screen('MakeTexture', env.win_ptr, ang4);
hapTex1 = Screen('MakeTexture', env.win_ptr, hap1);
hapTex2 = Screen('MakeTexture', env.win_ptr, hap2);
hapTex3 = Screen('MakeTexture', env.win_ptr, hap3);
hapTex4 = Screen('MakeTexture', env.win_ptr, hap4);
sadTex1 = Screen('MakeTexture', env.win_ptr, sad1);
sadTex2 = Screen('MakeTexture', env.win_ptr, sad2);
sadTex3 = Screen('MakeTexture', env.win_ptr, sad3);
sadTex4 = Screen('MakeTexture', env.win_ptr, sad4);
feelTex1 = Screen('MakeTexture', env.win_ptr, hap1); % neutral
feelTex2 = Screen('MakeTexture', env.win_ptr, hap3); % mid happy
feelTex3 = Screen('MakeTexture', env.win_ptr, ang3); % mid angry
feelTex4 = Screen('MakeTexture', env.win_ptr, sad3); % mid sad

yesTex = Screen('MakeTexture', env.win_ptr, yesImg);
noTex = Screen('MakeTexture', env.win_ptr, noImg);

% Copy to data structure
env.face(1).intensity(1) = hapTex1;
env.face(1).intensity(2) = hapTex2;
env.face(1).intensity(3) = hapTex3;
env.face(1).intensity(4) = hapTex4;

env.face(2).intensity(1) = angTex1;
env.face(2).intensity(2) = angTex2;
env.face(2).intensity(3) = angTex3;
env.face(2).intensity(4) = angTex4;

env.face(3).intensity(1) = sadTex1;
env.face(3).intensity(2) = sadTex2;
env.face(3).intensity(3) = sadTex3;
env.face(3).intensity(4) = sadTex4;

env.face(4).intensity(1) = feelTex1;
env.face(4).intensity(2) = feelTex2;
env.face(4).intensity(3) = feelTex3;
env.face(4).intensity(4) = feelTex4;
env.yesImg = yesTex;
env.noImg = noTex;

return

