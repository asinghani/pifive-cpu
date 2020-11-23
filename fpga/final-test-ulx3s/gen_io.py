num_io = 38

include = [0, 1, 2, 3, 4, 5]

for i in range(num_io):
    if i in include:
        print("    inout wire io{},".format(i))

print("\n"*5)

for i in range(num_io):
    if i in include:
        print("wire io{0}_i, io{0}_o, io{0}_oe;".format(i))
        print("assign io{0} = io{0}_oe ? io{0}_o : 1'bZ;".format(i))
        print("assign io{0}_i = io{0};".format(i))
    else:
        print("wire io{0}_i = 1; // Placeholder".format(i))
        print("wire io{0}_o; // Placeholder".format(i))
        print("wire io{0}_oe; // Placeholder".format(i))
