function h = Hx(px)
h = -px .* log(px);
h(px == 0) = 0;
h = sum(h, "all") / log(2);
end