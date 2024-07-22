import matplotlib.pyplot as plt

fig, axs = plt.subplots(figsize=(12, 8))

def plot(arr, l):
    plt.plot(
        list(map(lambda x: x[:6], arr[:, 0])),
        list(map(lambda x: int(x), arr[:, 1])),
        label = l)

def plotFigure(gis_means, gis_st_means, gis_branches_means, gis_branches_nn_means, gis_fe_means, gis_co_means, gis_files_means, svg_name):
    if len(gis_means) > 1:
        plot(gis_means, 'gis')

    if len(gis_st_means) > 1:
        plot(gis_st_means, 'gis status')

    if len(gis_branches_nn_means) > 1:
        plot(gis_branches_nn_means, 'gis branches --no-module-name')

    if len(gis_fe_means) > 1:
        plot(gis_fe_means, 'gis fetch')

    if len(gis_files_means) > 1:
        plot(gis_files_means, 'gis files')

    if len(gis_branches_means) > 1:
        plot(gis_branches_means, 'gis branches')

    if len(gis_co_means) > 1:
        plot(gis_co_means, 'gis checkout')

    plt.ylabel('time (ms)')
    plt.xlabel('commit SHA')
    plt.legend(loc='upper right')
    plt.xticks(rotation=45)

    plt.savefig(svg_name)
    # plt.show()
