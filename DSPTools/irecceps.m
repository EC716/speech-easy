function [sys] = irecceps(data,nout)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

num_input = length(data);

sys = zeros(nout,1);
sys(1) = exp(data(1));
for ii = 2:nout
    for kk = 1:ii
        if ii-kk >=1 && kk+1  <=num_input
        sys(ii) = sys(ii) + kk*data(kk+1)*sys(ii-kk);
        end
    end
    sys(ii) = sys(ii)/((ii -1)*(1 -data(1)));
end