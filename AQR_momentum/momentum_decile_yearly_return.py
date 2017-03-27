import pandas as pd
import numpy as np
from os import chdir

chdir('D:/CodeHub/Python/NBA5420/data')

df = pd.read_pickle('pickle_unstacked')

'''
masks
'''
MOM = ['prev_1_1', 'prev_1_12', 'prev_1_24', 'prev_1_36', 'prev_2_12', 'prev_2_24', 'prev_2_36']
fut_ret = ['nextmonth_return', 'nextyear_return']
cap = 'market_cap'
value = 'market_book'
company = 'code'
year = 'year'
column_deciles = ['Decile ' + str(i) for i in range(1, 11)]

'''
weight matrix based on capitalization
'''
weight_cap_unscaled = df[cap]
# fill nan caps with 1
weight_cap_unscaled.fillna(0, inplace=True)

'''
construct selection criterion based on momentum and data availability
'''
mom_return_yearly_dataframe = pd.DataFrame(index=df.index, columns=column_deciles)

# fixed momentum indicator, for every decile
threshold_mom = pd.DataFrame(index=df.index, columns=column_deciles)
for i in range(0, 10):
    decile = column_deciles[i]
    threshold_mom.loc[:, decile] = np.nanpercentile(df[MOM[4]], q=10.0*i, axis=1)

exist_return = df[fut_ret[1]].notnull()
# criterion_mom = df[MOM[1]] >= threshold_mom  # cannot broadcast this way
for i in range(0, 10):
    decile = column_deciles[i]
    select_mom = df[MOM[4]].apply(lambda x: x >= threshold_mom.loc[:, decile], axis=0)

# threshold_size = np.nanpercentile(df[size], q=90, axis=1)
# select_size = df[size].apply(lambda x: x >= threshold_size, axis=0)
# print(criterion_mom.sum(axis='columns'))
# nan future return stock cannot be used for back test

    select = select_mom & exist_return

    '''
    apply selection criterion to return and weight
    '''
    return_individual = df[fut_ret[1]]
    ret = return_individual.where(select, 0.0, inplace=False)
    # scale to convex weight
    weight_unscaled = weight_cap_unscaled.where(select, 0.0, inplace=False)
    scale_factor = weight_unscaled.sum(axis='columns')
    weight_scaled = weight_unscaled.div(scale_factor, axis='index')
    # print weight_scaled.sum(axis='columns') # check convex weight
    return_yearly_matrix = ret * weight_scaled
    return_yearly_series = return_yearly_matrix.sum(axis=1)
    # gross_return_yearly_series = 1 + return_yearly_series
    # net_value_yearly_series = gross_return_yearly_series.cumprod()
    # annualized_mean_return = np.log(net_value_yearly_series.values[-1])/net_value_yearly_series.size

    mom_return_yearly_dataframe.loc[:, decile] = return_yearly_series

mom_return_yearly_dataframe.to_csv('output/mom_return_yearly_dataframe')

print('-----------')
print('Hello World')
