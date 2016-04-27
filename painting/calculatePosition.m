function calculatePosition(  )
clear;
load('reference.mat')
canvas.plainpoint_uv = canvas.H_point_uv;
canvas.plainpoint_xy = canvas.H_point_xy;
set(canvas.figure, 'WindowButtonDownFcn', @click);
disp('click the points projection on the reference plain');
mode = 'p1';
    function click(varargin)
        if strcmp(mode,'p1') == 1
            canvas = calculateP1(canvas);
            disp('click the points ');
            mode = 'p2';
        elseif strcmp(mode,'p2') == 1
            canvas = calculateP2(canvas);
            mode = 'p1';
            save plain_result canvas;
        end
    end
end
%%
function  canvas = calculateP1(canvas)
pt = get(gca, 'CurrentPoint');
u = round(pt(1,1));
v = round(pt(1,2));
scatter(u, v,20,'black','fill');
p = canvas.H * [u v 1]';
p = p ./ p(3)
canvas.p1_uv = [u v 1];
canvas.p1_xy = [p(1) p(2) 0 1];
end
%%
function  canvas = calculateP2(canvas)
pt = get(gca, 'CurrentPoint');
u = round(pt(1,1));
v = round(pt(1,2));
scatter(u, v,20,'black','fill');
canvas.p2_uv = [u v 1];
b = canvas.reference_uv(1,:);
b0 = canvas.p1_uv;
t0 = canvas.p2_uv;
r = canvas.reference_uv(2,:);
v = cross(cross(b,b0),cross(canvas.vx,canvas.vy));
v = v ./v(3);
t = cross(cross(v,t0),cross(r,b));
t = t ./t(3);
h = canvas.reference_xy(2,3) * norm(t - b) * norm(canvas.vz - r) / (norm(r - b) * norm(canvas.vz - t))
canvas.p2_xy = canvas.p1_xy;
canvas.p2_xy(3) = h;
canvas.plainpoint_uv = [canvas.plainpoint_uv; canvas.reference_uv(1,:);canvas.reference_uv(2,:);canvas.p1_uv;canvas.p2_uv];
canvas.plainpoint_xy = [canvas.plainpoint_xy; canvas.reference_xy(1,:);canvas.reference_xy(2,:);canvas.p1_xy;canvas.p2_xy];

end