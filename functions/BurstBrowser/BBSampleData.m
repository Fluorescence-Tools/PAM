%%% Function that generates random data when there is nothing to show
function BBSampleData
% global BurstMeta UserValues
h = guidata(findobj('Tag','BurstBrowser'));
% x = linspace(0,1)*4.8;
% y = linspace(0,1)*4.8;
% [X,Y] = meshgrid(x,y);
% Z = sin(X-0.83) + cos(Y-2.4);
% Z = Z-min(Z(:));
% Z = Z/max(Z(:))*1.2-0.1;
% x = x/max(x)*1.2-0.1;
% y = y/max(y)*1.2-0.1;
% X = X/max(X(:))*1.2-0.1;
% Y = Y/max(Y(:))*1.2-0.1;
% x = linspace(0,1)*11;
% y = linspace(0,1)*11;
% [X,Y] = meshgrid(x,y);
% Z = sin(X-0.78) + cos(Y-2.36);
% Z = Z-min(Z(:));
% %Z = Z/max(Z(:))*1.2-0.1;
% x = x/max(x)*1.2-0.1;
% y = y/max(y)*1.2-0.1;
% X = X/max(X(:))*1.2-0.1;
% Y = Y/max(Y(:))*1.2-0.1;

%% dog

x = [1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,4,4,4,4,5,5,5,6,6,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,33,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,40,40,40,40,40,40,40,40,40,40,40,40,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,43,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,45,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,47,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,49,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,57,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,58,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,59,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,61,62,62,62,62,62,62,62,62,62,62,62,62,62,62,62,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,64,64,64,64,64,64,64,64,64,64,65,65,65,65,65,65,65,65,65,65,65,65,66,66,66,66,66,66,66,66,66,66,66,66,66,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,67,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,69,69,69,69,69,69,69,69,69,69,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,71,71,71,71,71,71,71,71,71,71,71,71,71,71,71,71,71,71,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,73,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,74,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,75,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,77,78,78,78,78,78,78,78,78,78,78,78,79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,82,82,82,82,82,82,82,82,82,82,82,82,83,83,83,83,83,83,83,83,83,84,84,84,84,84,84,84,85,85,85,85,85,85,85,85,85,85,86,86,86,86,86,87,87,87,87,87,87,87,87,87,87,87,87,87,87,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,88,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91];
y = [56,57,59,60,61,62,66,67,55,56,57,64,54,55,56,57,67,54,55,56,57,53,54,56,52,53,40,46,51,52,115,116,117,39,40,41,42,43,44,45,46,47,48,50,51,114,115,118,119,28,31,32,33,34,35,36,37,38,39,40,48,49,113,114,119,120,121,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,114,122,123,20,21,22,23,24,25,26,27,28,29,30,31,32,114,115,123,18,19,20,21,22,23,27,47,115,116,117,15,16,17,18,19,20,116,117,119,13,14,15,16,17,117,119,12,13,14,15,117,118,119,120,121,122,10,11,12,13,23,24,25,26,27,28,29,30,31,32,33,117,118,119,120,121,122,123,124,125,126,130,9,10,11,19,20,21,22,34,35,36,37,38,39,40,117,118,119,120,121,122,123,124,125,126,127,130,7,8,9,17,18,19,31,32,33,34,35,36,39,40,41,42,49,117,118,119,120,121,122,123,124,125,126,127,128,6,7,8,15,16,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,48,49,117,118,119,120,121,122,123,124,125,126,127,128,129,130,132,4,5,6,14,15,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,48,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,3,4,5,13,14,33,34,35,36,37,38,39,40,41,42,43,48,117,118,119,120,121,122,123,124,125,126,127,128,129,130,3,4,11,12,32,33,34,35,36,37,38,39,40,41,42,43,44,119,120,121,122,123,124,125,126,127,128,129,130,131,3,7,33,34,38,39,40,41,42,44,119,120,121,122,123,124,125,126,127,128,129,130,131,132,3,7,8,37,38,39,40,42,44,120,121,122,123,124,125,126,127,128,129,130,131,132,3,8,9,28,29,30,31,32,33,38,39,40,41,42,121,122,123,124,125,126,127,128,129,130,131,132,133,134,3,4,9,10,11,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,123,124,125,126,127,128,129,130,131,132,133,134,135,136,4,5,11,12,13,14,28,29,30,31,32,34,35,36,37,38,39,40,124,125,126,127,128,129,130,131,132,133,134,135,5,6,7,9,10,14,15,16,26,27,28,32,33,36,37,38,101,126,127,128,129,130,131,132,133,134,135,6,7,8,9,11,12,16,17,18,19,36,37,65,67,68,69,126,127,128,129,130,131,132,133,134,135,8,9,10,11,13,14,19,20,21,22,23,24,35,36,66,67,68,69,70,128,129,130,131,132,133,134,135,10,11,12,13,24,25,34,35,63,64,66,68,69,70,71,106,128,129,130,131,132,133,134,135,13,14,15,16,23,24,26,27,33,34,63,66,67,68,69,70,71,128,130,131,132,133,134,135,15,16,17,18,28,29,30,31,32,33,63,66,67,68,70,71,72,130,131,132,133,134,135,16,17,18,19,20,21,63,64,66,68,70,71,72,130,131,132,133,134,135,18,20,21,22,23,24,25,26,63,66,68,70,71,72,132,133,134,135,22,23,24,25,26,27,64,65,66,70,71,72,111,132,133,134,135,25,26,27,28,66,67,68,69,70,71,72,111,132,133,134,135,26,27,28,66,67,68,69,70,71,72,111,112,132,133,134,135,136,26,27,28,68,69,70,71,73,112,113,132,133,134,135,136,26,27,28,68,69,70,71,113,133,134,135,136,26,27,28,29,69,70,71,72,73,97,98,99,100,113,114,132,134,135,136,27,28,29,96,97,98,99,100,101,102,103,104,114,115,134,135,136,27,28,29,67,95,96,97,98,99,100,101,102,103,104,105,110,114,115,134,135,136,27,28,29,95,96,97,98,99,100,101,102,103,104,105,106,110,112,114,115,134,135,136,27,28,29,94,95,96,97,98,99,100,101,102,103,104,105,106,107,111,112,115,116,133,134,135,136,27,28,29,94,95,96,97,98,99,100,101,102,103,104,105,106,107,111,112,113,116,133,134,135,136,27,28,29,94,95,96,97,98,99,100,101,102,103,104,105,106,107,111,112,113,116,117,131,132,133,134,135,136,27,28,29,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,111,112,113,117,131,132,133,134,135,136,27,28,29,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,117,131,132,133,134,135,136,26,27,28,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,117,133,134,135,26,27,28,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,116,117,131,132,133,134,135,136,26,27,28,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,116,117,131,132,133,134,135,136,26,27,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,116,117,133,134,135,136,26,27,28,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,116,134,136,25,26,27,28,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,115,133,134,135,136,22,23,24,25,26,27,94,96,97,98,99,100,101,102,103,104,105,106,110,111,112,113,115,133,134,135,136,16,17,18,19,20,21,22,23,24,25,26,30,68,70,71,72,94,95,96,97,98,99,100,101,102,103,104,105,110,111,112,115,133,134,135,136,14,15,16,17,18,19,20,21,31,67,68,95,96,97,98,99,100,101,102,103,104,109,111,112,114,134,135,136,11,12,13,14,15,16,31,65,66,67,68,71,97,98,99,100,101,109,112,113,114,134,135,136,9,10,11,12,13,31,32,64,65,67,68,69,70,109,112,113,134,6,7,8,9,10,11,32,63,66,67,68,69,70,112,133,136,5,6,7,8,32,33,62,63,65,69,70,71,111,112,133,2,3,4,5,6,33,62,64,65,67,69,70,71,111,133,2,3,33,34,62,65,67,70,111,132,1,2,34,35,62,64,65,66,67,69,70,132,1,2,35,36,62,69,70,99,100,101,102,131,132,1,2,6,7,36,37,64,66,67,68,69,130,131,132,133,134,1,2,3,4,7,30,31,37,38,39,64,65,66,67,68,129,130,2,3,8,36,37,38,39,66,128,129,3,4,7,8,9,10,12,36,37,38,39,40,127,128,130,131,133,134,135,3,4,5,10,11,36,37,38,39,40,41,126,127,129,130,131,132,133,4,5,6,8,10,11,12,30,31,33,34,35,36,37,38,41,42,125,126,6,7,11,12,13,14,28,29,30,31,32,33,34,35,36,37,38,42,43,124,125,7,8,9,14,15,28,29,30,31,32,33,34,35,36,37,39,40,43,44,123,124,8,9,10,15,16,17,29,30,31,32,33,34,35,36,37,38,39,40,44,45,121,122,123,9,10,11,17,18,19,20,33,34,35,36,37,38,39,40,45,117,120,121,11,12,13,15,16,20,21,22,23,24,25,26,27,29,30,31,32,35,45,46,118,119,120,12,13,14,15,17,18,27,28,29,30,47,14,15,16,17,18,19,20,21,22,27,28,29,30,32,33,34,35,16,17,18,19,20,21,22,25,32,33,34,35,36,37,38,39,40,19,20,21,22,23,24,25,26,27,28,35,36,37,38,44,24,25,26,27,28,29,30,31,32,33,43,45,30,31,32,33,34,35,36,37,38,35,36,37,38,39,44,51,38,39,40,41,42,43,44,46,47,49,40,47,112,116,117,48,49,52,53,54,99,111,112,113,114,115,116,117,118,49,51,54,55,56,108,110,111,112,113,114,115,116,117,118,119,121,131,132,133,49,51,56,57,61,62,63,85,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,125,126,127,128,129,130,131,133,134,135,50,51,52,53,54,57,58,59,60,61,66,67,68,69,70,71,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,124,125,126,127,128,133,54,55,56,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,115,118,119,120,121,122,123,124,125,126,127,128,133];
c = linspace(1,10,length(x));

% x = x/max(x);
% y = y/max(y);

scatter(h.axes_general,x,y,100,c,'filled');
set(h.axes_general,'YDir','reverse');
set(h.axes_general,'XLim',[-40 130]);
%colormap(jet)
% set(h.axes_general,'YTick',[]);
% set(h.axes_general,'XTick',[]);

% add text
% generate text
xrange = h.axes_general.XLim + [0.1,-1]*diff(h.axes_general.XLim)/5;
yrange = h.axes_general.YLim + [0.1,-0.25]*diff(h.axes_general.YLim)/5;
txt = {'Wow','Such data','Much science','Many statistics','Very FRET','So dynamic'};
xval = xrange(1) + diff(xrange)*rand(numel(txt),1);
yval = yrange(1) + diff(yrange)*rand(numel(txt),1);
t = text(h.axes_general,xval,yval,txt,'FontSize',48);

for i = 1:numel(t)
    t(i).Rotation = normrnd(0,15);
end
%% Lorentz Attractor

% sigma = 10;
% beta = 8/3;
% rho = 28;
% f = @(t,a) [-sigma*a(1) + sigma*a(2); rho*a(1) - a(2) - a(1)*a(3); -beta*a(3) + a(1)*a(2)];
% [~,a] = ode45(f,[0 100],[1 1 1]);     % Runge-Kutta 4th/5th order ODE solver
% %c = linspace(1,10,length(a));
% plot(h.axes_general,a(:,1),a(:,2),'k','LineWidth',1)

%imagesc(h.axes_general,x,y,Z);
%contourf(h.axes_general,X,Y,Z,'EdgeColor','none','levels',0.01);

% BurstMeta.Plots.Main_Plot(1).XData = x;
% BurstMeta.Plots.Main_Plot(1).YData = y;
% BurstMeta.Plots.Main_Plot(1).CData = Z;
% if ~UserValues.BurstBrowser.Display.KDE
%     BurstMeta.Plots.Main_Plot(1).AlphaData = Z./max(max(Z)) > UserValues.BurstBrowser.Display.ImageOffset/100;
% elseif UserValues.BurstBrowser.Display.KDE
%     BurstMeta.Plots.Main_Plot(1).AlphaData = Z./max(max(Z)) > UserValues.BurstBrowser.Display.ImageOffset/100;%(HH./max(max(HH)) > 0.01);
% end
% 
% BurstMeta.Plots.Main_Plot(2).XData = [x(1)-min(diff(x)),x,x(end)+min(diff(x))];
% BurstMeta.Plots.Main_Plot(2).YData = [y(1)-min(diff(y)),y,y(end)+min(diff(y))];
% 
% HHcontour =zeros(size(Z)+2); HHcontour(2:end-1,2:end-1) = Z; 
% % replicate to fix edges
% HHcontour(2:end-1,1) = Z(:,1);HHcontour(2:end-1,end) = Z(:,end);HHcontour(1,2:end-1) = Z(1,:);HHcontour(end,2:end-1) = Z(end,:);
% HHcontour(1,1) = Z(1,1);HHcontour(end,1) = Z(end,1);HHcontour(1,end) = Z(1,end);HHcontour(end,end) = Z(end,end);
% BurstMeta.Plots.Main_Plot(2).ZData = HHcontour;
% 
% BurstMeta.Plots.Main_Plot(2).LevelList = max(Z(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
% h.axes_general.CLim(2) = max(Z(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;


%plot 1D hists
%h.axes_1d_x.XTickLabelMode = 'auto';
% BurstMeta.Plots.Main_histX(1).XData = x;
% BurstMeta.Plots.Main_histX(1).YData = sum(Z,1);
% BurstMeta.Plots.Main_histX(1).YData = y;
% BurstMeta.Plots.Main_histX(2).XData = [x,x(end)+min(diff(x))]-min(diff(x))/2;
% BurstMeta.Plots.Main_histX(2).YData = [BurstMeta.Plots.Main_histX(1).YData, BurstMeta.Plots.Main_histX(1).YData(end)];
% %h.axes_1d_x.YTickMode = 'auto';
% %yticks= get(h.axes_1d_x,'YTick');
% %set(h.axes_1d_x,'YTick',yticks(2:end));
% 
% BurstMeta.Plots.Main_histY(1).XData = y;
% BurstMeta.Plots.Main_histY(1).YData = sum(Z,2);
% BurstMeta.Plots.Main_histY(2).XData = [y,y(end)+min(diff(y))]-min(diff(y))/2;
% BurstMeta.Plots.Main_histY(2).YData = [BurstMeta.Plots.Main_histY(1).YData, BurstMeta.Plots.Main_histY(1).YData(end)];
%h.axes_1d_y.YTickMode = 'auto';
%yticks = get(h.axes_1d_y,'YTick');
%set(h.axes_1d_y,'YTick',yticks(2:end));

% if (h.axes_1d_x.XLim(2) - h.axes_1d_x.XTick(end))/(h.axes_1d_x.XLim(2)-h.axes_1d_x.XLim(1)) < 0.02
%     %%% Last XTick Label is at the end of the axis and thus overlaps with colorbar
%     h.axes_1d_x.XTickLabel{end} = '';
% else
%     h.axes_1d_x.XTickLabel = h.axes_general.XTickLabel;
% end
%,...
    %'EdgeColor','none');
%shading(h.axes_general,'interp')
%BurstMeta.Plots.Main_Plot(3) = scatter(h.axes_general,BurstData{1,1}.DataArray(:,1),BurstData{1,1}.DataArray(:,2),'.','CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
end