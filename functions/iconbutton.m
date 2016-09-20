function iconbutton(hBut,imgFile)
%%% plots scaled image on button
[a,~]=imread(imgFile);
hBut.Units = 'pixels'; drawnow;
wid = floor(hBut.Position(3));
hei = floor(hBut.Position(4));
a = imresize(a, [hei wid]);
set(hBut,'CData',a);
hBut.Units = 'normalized';