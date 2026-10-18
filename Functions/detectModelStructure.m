function [modelType, info] = detectModelStructure(u,y)

% Goal of function is detect structure between AR and ARX with u and y

%    in AR, y(t) depends only on previous output samples. while  in ARX ,y(t) depends on previous output samples and previous values
%       of an external input u(t).
%
% First, I check if the input changes. If the input is almost constant,
% I select AR. Otherwise, I check the cross-correlation between u and y.
% If the maximum correlation is above the 99% confidence limit,
% I select ARX.

    u = u(:);
    y = y(:);

    if length(u) ~= length(y)
        error('u and y must have the same number of samples.');
    end

    N = length(y);

    info.N = N;
    info.meanU = mean(u);
    info.stdU  = std(u);
    info.meanY = mean(y);
    info.stdY  = std(y);

    % Step 1: check whether the input changes
    inputIsConstant = isempty(u) || std(u) < 1e-10;
    info.inputIsConstant = inputIsConstant;

    if inputIsConstant
        modelType = 'AR';
        info.maxCrossCorrelation = 0;
        info.significanceLimit = NaN;
        info.modelType = modelType;
        return
    end

  %Step 2: Check the input-output cross-correlation

    % I use up to 50 lags because the system delay is not known
    maxLag = min(50,N-1);

    [rUY,lags] = xcorr(u-mean(u),y-mean(y),maxLag,'coeff');

    info.crossCorrelation = rUY;
    info.lags = lags;

    info.maxCrossCorrelation = max(abs(rUY));

    % Approximate 99% confidence limit
    info.significanceLimit = 2.58/sqrt(N);

    if info.maxCrossCorrelation > info.significanceLimit
        modelType = 'ARX';
    else
        modelType = 'AR';
    end

    info.modelType = modelType;
end