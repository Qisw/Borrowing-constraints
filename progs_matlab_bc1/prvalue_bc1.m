function pv = prvalue_bc1(xV, R)
% Compute the present value of xV

pv = ((1/R) .^ (0 : (length(xV)-1))) * xV(:);

end