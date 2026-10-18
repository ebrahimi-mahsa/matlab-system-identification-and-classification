function [Phi,Y] = myRegressor(u,y,n,modelType)
% myRegressor builds the regression matrix for an AR or ARX model.
%
% AR: phi(t) = [-y(t-1) ... -y(t-n)]

% ARX: phi(t) = [-y(t-1) ... -y(t-n) u(t-1) ... u(t-n)]

    u = u(:);
    y = y(:);

    N = length(y);

    if strcmpi(modelType,'AR')

        Phi = zeros(N-n,n);

        for t = n+1:N

            Phi(t-n,:) = -y(t-1:-1:t-n).';

        end

    elseif strcmpi(modelType,'ARX')

        Phi = zeros(N-n,2*n);

        for t = n+1:N

            Phi(t-n,:) = ...
                [-y(t-1:-1:t-n).'  u(t-1:-1:t-n).'];

        end

    else

        error('modelType must be AR or ARX.');

    end

    Y = y(n+1:N);

end