function Hz=J_Hz_spline(X,F)
F1 = F{1,1};
F2 = F{1,2};
partition = [0; X; 1];
bins = length(partition) - 1;
pzy_matrix = zeros(bins,2);

for i = 1:bins
    pzy_matrix(i,1) = F1(partition(i+1)) - F1(partition(i));
    pzy_matrix(i,2) = F2(partition(i+1)) - F2(partition(i));
end

pz_matrix = sum(pzy_matrix, 2);
pz_matrix(pz_matrix<0)=0;
Hz = Hx(pz_matrix);
end