
function  main( )
clear;clc;
image = imread('lab.jpg');
canvas.figure = figure;
imshow(image);
hold on;
canvas.numPt = 0;
canvas.H_point_uv = [];
canvas.H_point_xy = [];
canvas.V_point_uv = [];
mode = 'vp';

set(canvas.figure, 'WindowButtonDownFcn', @click);
disp('choose three lines paralle x');

    function click(varargin)
        if strcmp(mode,'vp') == 1
            canvas = drawLine(canvas);
            if canvas.numPt == 6
                disp('choose three lines paralle y');
            end
            if canvas.numPt == 12
                disp('choose three lines paralle z');
            end
            if canvas.numPt == 18
                canvas = calculateVP(canvas);
                mode = 'hp';
                disp('choose four points in the same plane and input 3D positions');
                %mode = 'sr1';
                %disp('set reference, choose one reference point on the plane');
            end
            
            
        elseif strcmp(mode,'hp') == 1
             disp('input 3D position');
            canvas = getH_Point(canvas);
            size(canvas.H_point_uv)
            if(size(canvas.H_point_uv,1)==4)
                canvas.H = calculateH(canvas.H_point_uv, canvas.H_point_xy);
                mode = 'sr1';
                disp('set reference, choose one reference point on the plane');
                canvas.reference_uv = [];
                canvas.reference_xy = [];
            end
        elseif strcmp(mode,'sr1') == 1
            canvas = setReference(canvas,1);
            disp('choose another reference point and input the real height');
            mode = 'sr2';
        elseif strcmp(mode,'sr2') ==1
            canvas = setReference(canvas,2);
            disp('calculate vanish points set reference successfully!')
            save reference canvas;
           
        elseif strcmp(mode,'th') == 1
            disp('test H');
            testH(canvas.H);
        end
        
        
    end
end

%%
function canvas = getH_Point(canvas)
pt = get(gca, 'CurrentPoint');
u = round(pt(1,1));
v = round(pt(1,2));
scatter(u, v,20,'blue','fill');
realPos = inputdlg('Input real world coordinate(x, y):','Input', [1 70]);
realPos = str2num(realPos{:})
x = realPos(1,1)
y = realPos(1,2)
canvas.H_point_uv = [canvas.H_point_uv ; [u, v, 1]];
canvas.H_point_xy = [canvas.H_point_xy ; [x, y, 0, 1]];
end
%%
function H = calculateH(point_uv, point_xy)
A = zeros (8, 9);
for i = 1:4
    x  = point_uv(i, 1);
    y  = point_uv(i, 2);
    rx = point_xy(i, 1);
    ry = point_xy(i, 2);
    A(2*i-1, :)   = [x, y, 1, 0, 0, 0, -rx*x, -rx*y, -rx];
    A(2*i, :) = [0, 0, 0, x, y, 1, -ry*x, -ry*y, -ry];
end
A = A' * A;
[~, ~, d]=svd(A);
H = reshape(d(:,9), 3, 3)'
end
%%
function  testH(H)
disp('click H point');
pt = get(gca, 'CurrentPoint');
u = round(pt(1,1));
v = round(pt(1,2));
scatter(u, v,20,'red','fill');
p = H * [u v 1]';
p = p ./ p(3)
end
%%
function canvas = drawLine(canvas)
pt = get(gca, 'CurrentPoint');
u =  round(pt(1,1));
v =  round(pt(1,2));
scatter(u, v,20,'yellow','fill');
canvas.V_point_uv = [canvas.V_point_uv ;[u v 1]];
canvas.numPt = canvas.numPt + 1;
if (mod(canvas.numPt,2)) == 0
    line([canvas.V_point_uv(end - 1,1),canvas.V_point_uv(end,1)],[canvas.V_point_uv(end-1,2),canvas.V_point_uv(end,2)],'linewidth',2,'color','r')
end
end
%%
function canvas = calculateVP(canvas)
disp('calculate VP');
P = canvas.V_point_uv;
l1 = cross(P(1,:), P(2, :));
l2 = cross(P(3,:), P(4, :));
l3 = cross(P(5,:), P(6, :));
m1 = l1'*l1;
m2 = l2'*l2;
m3 = l3'*l3;

m = m1 + m2 + m3;
[~, ~, v] = svd(m);
canvas.vx = v(:, 3)'/v(3,3)

l1 = cross(P(7,:), P(8, :));
l2 = cross(P(9,:), P(10, :));
l3 = cross(P(11,:), P(12, :));
m1 = l1'*l1;
m2 = l2'*l2;
m3 = l3'*l3;

m = m1 + m2 + m3;
[~, ~, v] = svd(m);
canvas.vy = v(:, 3)'/v(3,3)

l1 = cross(P(13,:), P(14, :));
l2 = cross(P(15,:), P(16, :));
l3 = cross(P(17,:), P(18, :));
m1 = l1'*l1;
m2 = l2'*l2;
m3 = l3'*l3;

m = m1 + m2 + m3;
[~, ~, v] = svd(m);
canvas.vz = v(:, 3)'/v(3,3)
end
%%
function canvas = setReference(canvas ,n)
pt = get(gca, 'CurrentPoint');
u =  round(pt(1,1));
v =  round(pt(1,2));
scatter(u, v,20,'white','fill');
p = canvas.H * [u v 1]';
p = p ./ p(3)
if (n==1)
    canvas.reference_uv = [canvas.reference_uv;[u v 1]];
    canvas.reference_xy = [canvas.reference_xy;[p(1) p(2) 0 1]];
else
    height = inputdlg('reference height:','Input', [1 70]);
    rheight = str2num(height{:})
    canvas.reference_uv = [canvas.reference_uv;[u v 1]];
    t = canvas.reference_xy;
    t(3) = rheight;
    canvas.reference_xy = [canvas.reference_xy;t];
end
end


