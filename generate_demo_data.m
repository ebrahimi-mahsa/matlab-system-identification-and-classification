function [u,y,Utrain,Ytrain,Utest,Ytest,truth] = generate_demo_data()
% Synthetic demonstration data, NOT the original examination datasets.
% Preserve the caller's random-number state.
oldState = rng;
cleanup = onCleanup(@() rng(oldState)); %#ok<NASGU>
rng(42,'twister');
N = 2300; burn = 300;
uFull = randn(N,1);
e = 0.2*randn(N,1);
yFull = zeros(N,1);
% y(t)=0.7*y(t-1)-0.2*y(t-2)+0.8*u(t-1)+0.3*u(t-2)+e(t)
for t=3:N
    yFull(t)=0.7*yFull(t-1)-0.2*yFull(t-2) ...
        +0.8*uFull(t-1)+0.3*uFull(t-2)+e(t);
end
u = uFull(burn+1:end); y = yFull(burn+1:end);
% Independent train/test samples; nonlinear circular class boundary.
Utrain = 4*rand(1000,2)-2;
Utest = 4*rand(600,2)-2;
% Noise in the latent decision score gives a nontrivial classification task.
Ytrain = 2*double(sum(Utrain.^2,2)+0.15*randn(1000,1)>1.5)-1;
Ytest = 2*double(sum(Utest.^2,2)+0.15*randn(600,1)>1.5)-1;
truth = struct('source','synthetic demonstration', ...
    'seed',42,'theta',[-0.7;0.2;0.8;0.3], ...
    'ARXOrder',2,'innovationStd',0.2, ...
    'classificationBoundary','u1^2 + u2^2 = 1.5 (noisy labels)');
end
