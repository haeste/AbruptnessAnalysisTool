function fx = logistic(x,L,k,x0)

fx = L ./ (1 + exp(-k*(x-x0)));
