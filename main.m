clear all
close all

%% Choose dataset:
dataset_name = 'analyticF';
% dataset_name = 'MNISTF';
% dataset_name = 'FashionMNISTF';
% dataset_name = 'CIFARQ';
dataset_path = strcat('data/', dataset_name, '.csv');
p_spline = csvread(dataset_path);


%% Global settings:
nbins = 8;
steps = 101;
num_times = 50;


%% Compute matrix for cubic spline fitting:
F1 = griddedInterpolant(p_spline(:,1),p_spline(:,2),"spline","spline");
F2 = griddedInterpolant(p_spline(:,1),p_spline(:,3),"spline","spline");
F = {F1,F2};


j_obj = @(X) J_Izy_spline(X,F);
gs = GlobalSearch;
ms = MultiStart;


%% Find corner points:
x_list_unc = zeros(nbins - 1, nbins);
Izy_list_unc = zeros(1, nbins);
Hz_list_unc = zeros(1, nbins);
for i = 2:nbins
    x0 = sort(rand(i - 1,1));
    problem_unc = createOptimProblem('fminunc','objective',j_obj,'x0',x0);
%     [x, fval] = run(ms,problem_unc,100);
    [x,fval] = fminunc(problem_unc);
    x
    Hz_list_unc(i) = J_Hz_spline(x,F);
    Izy_list_unc(i) = J_Izy_spline(x,F);
end


%% Main optimization:
% Maximize I(Y;Z) with constraint of H(Z) < h0:
x_list = ones(nbins - 1, (steps - 1) * (nbins - 1) * num_times);
fval_list = zeros(1, (steps - 1) * (nbins - 1) * num_times);
Hz_list = zeros(1, (steps - 1) * (nbins - 1) * num_times);
Izy_list = zeros(1, (steps - 1) * (nbins - 1) * num_times);
h0_list_all = zeros(1, (steps - 1) * (nbins - 1) * num_times);

for k = 2:nbins
h0_list = linspace(Hz_list_unc(k-1),Hz_list_unc(k),steps);

% A matrix for linear constraint A x <= b:
A = zeros(k - 1);
for i = 1:k-2
   A(i,i) = 1;
   A(i,i+1) = -1;
end
A(k-1, k - 1) = -1;

for i = 2:steps
    h0 = h0_list(i);
    for jj = 1: num_times
        strcat("k=", num2str(k), ", i=", num2str(i), ", j=", num2str(jj), ", h0=", num2str(h0))
        x0 = sort(rand(k - 1,1));
        j_cons = @(X) J_cons(X, F, h0);
        problem = createOptimProblem('fmincon',...
            'objective',j_obj,'x0',x0,...
            'Aineq',A,'bineq',zeros(k-1,1),...
            'lb', zeros(k - 1,1), 'ub', ones(k - 1,1),...
            'nonlcon',j_cons);
        [x, fval] = fmincon(problem);
    %     [x,fval] = run(gs,problem);

        Hz=J_Hz_spline(x,F);
        Izy=J_Izy_spline(x,F);
        h0_list_all(jj + (i - 1) * num_times + (k-2) * (steps - 1) * num_times) = h0;
        x_list(1:k-1,jj + (i - 1) * num_times + (k-2) * (steps - 1) * num_times)=x;
        Hz_list(jj + (i - 1) * num_times + (k-2) * (steps - 1) * num_times)=Hz;
        Izy_list(jj + (i - 1) * num_times + (k-2) * (steps - 1) * num_times)=Izy;
        fval_list(jj + (i - 1) * num_times + (k-2) * (steps - 1) * num_times) = fval;
    end
end

    
    
end

cell_cons_Pareto = {"x_list", x_list};
cell_cons_Pareto(2,:) = {"Hz_list", Hz_list};
cell_cons_Pareto(3,:) = {"Izy_list", Izy_list};
cell_cons_Pareto(4,:) = {"h0_list", h0_list_all};

%% Save data:
data = [h0_list_all; Hz_list; Izy_list;x_list]';
csvwrite(strcat("data/data_bin_", dataset_name, ".csv"), data)


%% Helper function:
function [c,ceq] = J_cons(X,F,H0)
c = J_Hz_spline(X,F) - H0;
ceq = [];
end

