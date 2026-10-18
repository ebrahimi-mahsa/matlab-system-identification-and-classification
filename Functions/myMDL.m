function MDL = myMDL(J,N,p)
% myMDL calculates the Minimum Description Length criterion.

MDL = N*log(J) + p*log(N);

end