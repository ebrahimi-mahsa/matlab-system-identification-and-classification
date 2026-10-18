function [theta,thetaHist,residuals] = myRLS(Phi,Y)
% myRLS estimates the model parameters recursively
% using the matrix inversion lemma.

    N = size(Phi,1);
    p = size(Phi,2);

    % Initial values
    % theta starts from zero because I have no prior parameter information.
    % A large P show high initial uncertainty.
    theta = zeros(p,1);
    P = 1e4*eye(p);

    thetaHist = zeros(p,N);
    residuals = zeros(N,1);

    for t = 1:N

        phi = Phi(t,:).';

        % prediction error
        e = Y(t) - phi.'*theta;

        % recursive gain
        K = P*phi/(1 + phi.'*P*phi);

        % update parameter estimate
        theta = theta + K*e;

        % update P using the matrix inversion lemma
        P = P - K*phi.'*P;

        thetaHist(:,t) = theta;
        residuals(t) = e;

    end

end
