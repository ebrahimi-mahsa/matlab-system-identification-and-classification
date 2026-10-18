function [nBest,orderTable] = myOrder(y,u,modelType,maxOrder)

%The function myOrder tests different model orders 
% from 1 to maxOrder. For each order, 
% I build the corresponding regression matrix 
% and estimate the parameters using my RLS function.
%  Then, I calculate the residual cost (J) 
% and the FPE, AIC and MDL criteria. 
% These criteria compare the model fit with its complexity.


orderTable = zeros(maxOrder,5);
% maxOrder=10
for n = 1:maxOrder

    [Phi,Y] = myRegressor(u,y,n,modelType);

    [theta,~,~] = myRLS(Phi,Y);
    e = Y - Phi*theta;
    J = mean(e.^2);

    if strcmpi(modelType,'AR')
        p = n;
    else
        p = 2*n;
    end

    
    N = length(y);

    FPE = myFPE(J,N,p);
    AIC = myAIC(J,N,p);
    MDL = myMDL(J,N,p);

    orderTable(n,:) = [n J FPE AIC MDL];

end

% choose the order with minimum MDL
[~,index] = min(orderTable(:,5));

nBest = orderTable(index,1);

end