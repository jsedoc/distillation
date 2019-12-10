# distillation

Code for the paper "Pareto-optimal data compression for binary classification tasks" by Max Tegmark & Tailin Wu, 2019, [https://arxiv.org/abs/1908.08961](https://arxiv.org/abs/1908.08961).

## Data files

All our results can be computed starting with the parameters listed in Figure II, but to save time, you can instead start with the four files below, which each contain 
two columns (w,F1), where F_1 = P(W<w|Y=1):
 - AnalyticF.csv
 - CIFARF.csv
 - FashionMNISTF.csv
 - MNISTF.csv

After interpolating these curves, eq. (29) gives 
    F_2(w) = P(W<w|Y=2) = 1/2 - F_1(1-w), 
after which the joint probability distribution P(Z,Y) can be rapidly 
computed for any binning with boundaries {b_0,b_1,...} using
 P_ij = F_j(b_i) - F_j(b_{i-1}).
 
For CIFAR, the conditional probability isn't quite monotonic, 
so as described in the paper, it's instead optimal to bin "vertically":
load the file CIFARQ.csv {f,F1,F2}, 
interpolate to obtain the two functions F_1(f) and F_ss2(f), 
simply load and again compute
 P_ij = F_j(b_i) - F_j(b_{i-1}).

## Code

The Matlab code probvided solves the constrained optimization problem of maximizing I(Z,W) subject to the constraint that H<H*, scanning H* over a rather dense grid of values. To compute the Pareto frontier I(H*) from data files such as those above, simply open main.min matlab and click "run".

This obtimization sometimes gets stuck in suboptimal local maxima. The grid points H* for which this happens can be automatically dropped by exploiting the fact that both H and I should be a monotonically increasing functions of H*. For example, here's Mathematica code function doing this:

```
dropBadLocalMinima2[results_] := Module[{res = {}, lastH = -666}, Do[ If[lastH != results[[i, 2]], lastH = results[[i, 2]]; PrependTo[res, results[[i]]]], {i, Length[results], 1, -1}]; res];

(* When you end up in a bad local minimum, I(X,Z) drops: *)

dropBadLocalMinima1[results_, initialI_Real] := Module[{res = {}, lastI = initialI}, Do[ If[lastI < results[[i, 3]], lastI = results[[i, 3]]; AppendTo[res, results[[i]]]], {i, Length[results]}]; dropBadLocalMinima2[res]];
```

If you have any questions about this, please email tegmark@mit.edu or tailin@mit.edu.
:-)

## Citation
If you compare with, build on, or use aspects of the distillation work, please cite the following:
```
@article{tegmark2019pareto,
  title={Pareto-optimal data compression for binary classification tasks},
  author={Tegmark, Max and Wu, Tailin},
  journal={arXiv preprint arXiv:1908.08961},
  year={2019}
}
```
