function map
load('plain_result.mat')

img = imread('painting.JPG');


H1 =calculateH(img,canvas.plainpoint_uv(1:4,:),canvas.plainpoint_xy(1:4,[1 2 4]),'1.jpg',90,0);
H2 = calculateH(img,canvas.plainpoint_uv(5:8,:),canvas.plainpoint_xy(5:8,[1 3 4]),'2.jpg',90,0);
H3 =calculateH(img,canvas.plainpoint_uv(9:12,:),canvas.plainpoint_xy(9:12,[2 3 4]),'3.jpg',90,1);
%imshow(img);
%hold on;

%while(1)
    %testH(img,H1)
%end



end

%%
function testH(img,H)
point_xy = inputdlg('Input 3D point (x, y):','Input', [1 70]);
point_xy = str2num(point_xy{:})
point_uv = H * [point_xy(1) point_xy(2) 1]';
point_uv = point_uv / point_uv(3)

scatter(point_uv(1), point_uv(2),20,'blue','fill');
end



%%  from 3D to 2D H
function H = calculateH(img, point_uv, point_xy, name,rotate,m)
A = zeros (8, 9);
for i = 1:4
    x  = point_xy(i, 1);
    y  = point_xy(i, 2);
    rx = point_uv(i, 1);
    ry = point_uv(i, 2);
    A(2*i-1, :)   = [x, y, 1, 0, 0, 0, -rx*x, -rx*y, -rx];
    A(2*i, :) = [0, 0, 0, x, y, 1, -ry*x, -ry*y, -ry];
end
A = A' * A;
[~, ~, d]=svd(A);
H = reshape(d(:,9), 3, 3)';

point_xy = round(point_xy);
minpos = min(point_xy);
min_x = minpos(1);
min_y = minpos(2);
maxpos = max(point_xy);
max_x = maxpos(1);
max_y = maxpos(2);
texture = zeros(max_x-min_x+1, max_y-min_y+1, 3);

for i = min_x:max_x
   for j = min_y:max_y
       uv = H * [i, j, 1]';
       uv = uv / uv(3);
       uv_round = floor(uv);
       x = uv_round(1);
       y = uv_round(2);
       a = uv(1) - x;
       b = uv(2) - y;
       
        texture(i-min_x+1, j-min_y+1, :) =  (1-a) * (1-b) * img(y, x, :)...
                                   + a * (1-b) * img(y, x+1, :)...
                                   + a* b * img(y+1, x+1, :)...
                                   + b * (1-a) * img(y+1, x, :);
   end
end

figure();
textureout = imrotate(uint8(texture),rotate);
if(m==1)
    textureout = flipdim(textureout,2);
end
imwrite(textureout, name);
imshow(textureout);


end