for i in range(1, 101):
    with open("%d.in" % i, "w") as inp:
        inp.write("%d %d\n" % (i, i))
    s = i + i
    with open("%d.out" % i, "w") as out:
        out.write("%d\n" % s)
