import numpy as np
import matplotlib.pyplot as plt

savedFile = open("Tests\Data\sinWaveTime.txt", "r")
li = []
for line in savedFile:
    li.append(list(map(float, line.split(" "))))

plt.plot(li[0], [0]*1000)
plt.plot(li[0], li[1])
plt.plot(li[0], li[2])
plt.plot(li[0], li[3])
plt.plot(li[0], li[4])

plt.show()
