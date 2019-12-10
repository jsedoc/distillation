function I = Ixy(pxy)
px = sum(pxy, 2);
py = sum(pxy, 1);
pxpy = px * py;
I_full = pxy .* log (pxy ./ pxpy);
I_full(pxy == 0) = 0;
I = sum(I_full, "all") / log(2);
end
