import numpy as np
from shared import plotFigure

gis_means = np.loadtxt('data/big/gis_means', dtype='str', ndmin=2)
gis_st_means = np.loadtxt('data/big/gis_st_means', dtype='str', ndmin=2)
gis_branches_means = np.loadtxt('data/big/gis_branches_means', dtype='str', ndmin=2)
gis_branches_nn_means = np.loadtxt('data/big/gis_branches_nn_means', dtype='str', ndmin=2)
gis_fe_means = np.loadtxt('data/big/gis_fe_means', dtype='str', ndmin=2)
gis_co_means = np.loadtxt('data/big/gis_co_means', dtype='str', ndmin=2)
gis_files_means = np.loadtxt('data/big/gis_files_means', dtype='str', ndmin=2)

plotFigure(gis_means, gis_st_means, gis_branches_means, gis_branches_nn_means, gis_fe_means, gis_co_means, gis_files_means, 'data/big/gis_performance.svg')
