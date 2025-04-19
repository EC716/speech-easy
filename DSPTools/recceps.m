function [syshat] = recceps(data,nout)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

num_input = length(data);

syshat = zeros(nout,1);
syshat(1) = log(data(1));
for ii = 2:nout
    if ii <= num_input
    syshat(ii) = data(ii)/data(1);
    end
      
    for kk = 1:ii-1
        if (ii-kk+1) <= num_input
        syshat(ii) = syshat(ii) - ((kk-1)/(ii-1))*syshat(kk)*data(ii-kk+1)/data(1);
        end
    end
end
end