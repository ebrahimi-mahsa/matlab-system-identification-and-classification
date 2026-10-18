function [results] = myValidation(y,u,theta,modelType,doPlot)

% The function myValidation checks these two conditions:   
% % First, test the whiteness of the residuals using their autocorrelation. 
% % Second, since my selected model is ARX, I also test the cross-correlation 
% % between the residuals and the input.
% The tests are based on chi-square criteria.

    if nargin<5 || isempty(doPlot)
        doPlot = false;
    end

    if strcmpi(modelType,'AR')
        n = length(theta);
    else
        n = length(theta)/2;
    end

    % Compute residuals
    [Phi,Y] = myRegressor(u,y,n,modelType);
    res = Y - Phi*theta;

    N = length(res);
    % where m can be chosen from 5 up to N/4
    M = min(20,floor(N/4)); 


    %% Residual whiteness test

    rFull = xcorr(res-mean(res),M,'coeff');
    acf   = rFull(M+2:end);        % lags 1,...,M

    % 95% confidence limit
    conf = 1.96/sqrt(N);

    % chi-square statistic
    S = N*sum(acf.^2);

    if exist('chi2inv','file')==2
        threshold = chi2inv(0.95,M);
    else
        threshold = M + 1.645*sqrt(2*M);
    end

    isWhite = S < threshold;


    %% Residual-input cross-correlation test

    isUncorrelated = NaN;
    Scross = NaN;
    thresholdCross = NaN;
    crossCorr = [];
    crossLags = [];

    if strcmpi(modelType,'ARX')

        uRes = u(n+1:end);
        e  = res - mean(res);
        u0 = uRes - mean(uRes);
        tau0 = n;
        maxLag = tau0 + M;


        % Residual-input cross-correlation
        [rEU,lagsEU] = xcorr(e,u0,maxLag,'biased');

       
        idx = lagsEU >= tau0+1 & ...
              lagsEU <= tau0+M;

        rCross = rEU(idx);
        crossLags = lagsEU(idx);


        %% Input autocorrelation matrix

        [rUU,lagsUU] = xcorr(u0,M-1,'biased');

        ru = zeros(M,1);

        for k = 0:M-1
            ru(k+1) = rUU(lagsUU == k);
        end

        % Autocorrelation matrix of the input
        SigmaU = toeplitz(ru);


        %% chi-square test
        re0 = mean(e.^2);

        % Chi-square statistic 
        Scross = N * ...
            (rCross' * (SigmaU\rCross)) / re0;

        if exist('chi2inv','file')==2
            thresholdCross = chi2inv(0.95,M);
        else
            thresholdCross = M + 1.645*sqrt(2*M);
        end

        isUncorrelated = Scross < thresholdCross;


        %% Normalized correlation for the plot

        crossCorr = rCross / sqrt(re0*ru(1));

    end


    %% Store results

    results = struct( ...
        'residualVar',var(res), ...
        'acf',acf, ...
        'conf',conf, ...
        'S',S, ...
        'threshold',threshold, ...
        'isWhite',isWhite, ...
        'M',M, ...
        'residuals',res, ...
        'crossCorr',crossCorr, ...
        'crossLags',crossLags, ...
        'Scross',Scross, ...
        'thresholdCross',thresholdCross, ...
        'isUncorrelated',isUncorrelated);


    %% Plots

    if doPlot

        figure;
        stem(1:M,acf,'filled','LineWidth',1.1);
        hold on;
        yline(conf,'--r');
        yline(-conf,'--r');
        yline(0,'k');
        hold off;

        grid on;
        xlabel('delay k');
        ylabel('r_e(k)');
        title('Residual autocorrelation (whiteness test)');


        if strcmpi(modelType,'ARX')

            figure;
            stem(crossLags,crossCorr,'filled','LineWidth',1.1);
            hold on;
            yline(conf,'--r');
            yline(-conf,'--r');
            yline(0,'k');
            hold off;

            grid on;
            xlabel('delay k');
            ylabel('r_{eu}(k)');
            title('Residual-input cross-correlation test');

        end

    end

end