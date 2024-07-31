import matplotlib.pyplot as plt
import numpy as np

gis_means = np.loadtxt('data/big/gis_means')
gis_st_means = np.loadtxt('data/big/gis_st_means')
gis_branches_means = np.loadtxt('data/big/gis_branches_means')
gis_fe_means = np.loadtxt('data/big/gis_fe_means')
gis_co_means = np.loadtxt('data/big/gis_co_means')
gis_files_means = np.loadtxt('data/big/gis_files_means')

versions = np.loadtxt('data/big/gis_versions', dtype='str', ndmin=1)

x = np.arange(len(versions))
width = 0.1
multiplier = 0

means = {
    'gis': gis_means,
    'branches': gis_branches_means,
    'checkout': gis_co_means,
    'fetch': gis_fe_means,
    'files': gis_files_means,
    'status': gis_st_means,
}

fig, ax = plt.subplots(figsize=(10, 10), layout='constrained')

for att, measure in means.items():
    offset = width * multiplier
    rects = ax.bar(x + offset, measure, width, label=att)
    ax.bar_label(rects)
    multiplier += 1

ax.set_ylabel('Time (ms)')
ax.set_xticks(x + .25, versions)
ax.legend(loc='best', ncols = 6)

# plt.show()
plt.savefig('data/big/gis_performance.svg')
