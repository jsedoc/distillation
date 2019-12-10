function Izy_m=J_Izy_spline(X,F)
F1 = F{1,1};
F2 = F{1,2};
partition = [0; X; 1];
bins = length(partition) - 1;
pzy_matrix = zeros(bins,2);

for i = 1:bins
    pzy_matrix(i,1) = F1(partition(i+1)) - F1(partition(i));
    pzy_matrix(i,2) = F2(partition(i+1)) - F2(partition(i));
end

Izy_m = -Ixy(pzy_matrix);  % minus
end