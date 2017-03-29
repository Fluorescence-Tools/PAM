function iconbutton(hBut,imgFile)
%%% plots scaled image on button
[a,~]=imread(imgFile);
dim = size(a); img_hei = dim(1); img_wid = dim(2);
hBut.Units = 'pixels'; drawnow;
wid = floor(hBut.Position(3))-2;
hei = floor(hBut.Position(4))-2;
%%% get maximum if image and resize to respective button dimension while
%%% keeping aspect ratio
if img_wid > img_hei
    a = imresize(a, [min([hei, wid*img_hei/img_wid]) wid]);
else
    a = imresize(a, [hei min([wid, hei*img_wid/img_hei]) ]);
end
%%% add black border
img = uint8(ones(hei+2,wid+2,3));
idx_wid = floor((wid+2-size(a,2))/2)+(1:size(a,2));
idx_hei = floor((hei+2-size(a,1))/2)+(1:size(a,1));
img(idx_hei,idx_wid,:) = a;
set(hBut,'CData',img);
hBut.Units = 'normalized';