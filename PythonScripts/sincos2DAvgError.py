import netCDF4 as nc
import numpy as np
import matplotlib.pyplot as plt

orig = nc.Dataset("E:\GT_chpl\Tests\Data\\true.nc",
                  "r").variables["data"][:]
calc = nc.Dataset("E:\GT_chpl\Tests\Data\\result.nc",
                  "r").variables["data"][:]
diff = nc.Dataset("E:\GT_chpl\Tests\Data\\diff.nc",
                  "r").variables["data"][:]

savedFile = open("Tests\Data\sincos2DAvgError.txt", "r")
li = []
for line in savedFile:
    li.append(list(map(float, line.split(" "))))


h_values, error_values = tuple(li)

fig = plt.figure(figsize=(10, 7))
fig.add_subplot(2, 2, 1)
c = plt.imshow(calc)
plt.colorbar(c)
plt.title("Calculated Value")

fig.add_subplot(2, 2, 2)
k = plt.imshow(orig)
plt.colorbar(k)
plt.title("True Value")

fig.add_subplot(2, 2, 3)
l = plt.imshow(diff)
plt.colorbar(l)
plt.title("Difference (Calc - True)")

fig.add_subplot(2, 2, 4)
plt.yscale('log')
plt.xscale('log')
plt.plot(h_values, error_values, '-o', label="error vs H")
plt.plot(h_values, np.power(h_values, 2), '-x', label="h*h vs h")
plt.xlabel('h Values')
plt.ylabel('Avg Error')
plt.title('Sin(X)Cos(Y) Derivative test')
plt.legend()
plt.savefig(fname="PythonScripts\sincos2DAvgErr_LogScale", dpi=1000)
plt.show()
