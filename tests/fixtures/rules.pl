parent(john, bob).
parent(mary, bob).
grandparent(X, Z) :- parent(X, Y), parent(Y, Z).
