
w = Screen('OpenWindow', 1);

ang1 = imread('img/ang-1.jpg');
ang2 = imread('img/ang-2.jpg');

angTex1 = Screen('MakeTexture', w, ang1);
angTex2 = Screen('MakeTexture', w, ang2);

Screen('DrawTexture', w, angTex1, [], [0 0 115 160]);
Screen('Flip', w);


