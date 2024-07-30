import numpy as np
import matplotlib.pyplot as plt

gis_means = np.loadtxt('data/gis_means', dtype='str', ndmin=2)
gis_st_means = np.loadtxt('data/gis_st_means', dtype='str', ndmin=2)
gis_branches_means = np.loadtxt('data/gis_branches_means', dtype='str', ndmin=2)
gis_fe_means = np.loadtxt('data/gis_fe_means', dtype='str', ndmin=2)
gis_co_means = np.loadtxt('data/gis_co_means', dtype='str', ndmin=2)
gis_files_means = np.loadtxt('data/gis_files_means', dtype='str', ndmin=2)

fig, ax = plt.subplots(figsize=(19, 10))

def plot(arr, l):
    plt.plot(
        list(map(lambda x: x[:6], arr[:, 0])),
        list(map(lambda x: int(x), arr[:, 1])),
        label = l)

if len(gis_means) > 1:
    plot(gis_means, 'gis')

if len(gis_st_means) > 1:
    plot(gis_st_means, 'gis status')

if len(gis_fe_means) > 1:
    plot(gis_fe_means, 'gis fetch')

if len(gis_files_means) > 1:
    plot(gis_files_means, 'gis files')

if len(gis_branches_means) > 1:
    plot(gis_branches_means, 'gis branches')

if len(gis_co_means) > 1:
    plot(gis_co_means, 'gis checkout')

ax.grid(axis=('x'), linestyle='--', linewidth=.25)
ax.margins(0)
plt.ylabel('Time (ms)')
plt.xlabel('Commit SHA')
plt.legend(loc='best')
plt.xticks(rotation=45)

# plt.show()
plt.savefig('data/gis_performance.svg')
