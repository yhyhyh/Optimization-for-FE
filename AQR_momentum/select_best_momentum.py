import pandas as pd
import numpy as np

from os import chdir

chdir('D:/CodeHub/Python/NBA5420/data')

df = pd.read_pickle('pickle_unstacked')
transaction_cost = pd.read_pickle('transaction_cost')

'''
masks
'''
MOM = ['prev_1_1', 'prev_1_12', 'prev_1_24', 'prev_1_36', 'prev_2_12', 'prev_2_24', 'prev_2_36']
future_return = ['nextmonth_return', 'nextyear_return']
cap = 'market_cap'
value = 'value'
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
GOAL: comparison between effectiveness momentum indicators
OUTPUT: dataframe # year * # momentum indicators
'''

mom_raw_return_comparison = pd.DataFrame(index=df.index, columns=MOM)
mom_net_return_comparison = pd.DataFrame(index=df.index, columns=MOM)

'''
construct selection criterion based on momentum and data availability
CAUTION:    exclude stocks that have missing future returns may induce future information,
            because missing future return can be a sign of bad stock
'''
select_exist_future = df[future_return[1]].notnull()
# fixed decile, for every momentum indicator
threshold_mom = pd.DataFrame(index=df.index, columns=MOM)
for i in range(0, len(MOM)):
    threshold_mom.loc[:, MOM[i]] = np.nanpercentile(df[MOM[1]], q=90, axis=1)

raw_return = df[future_return[1]]

for i in range(0, len(MOM)):
    decile = column_deciles[i]
    select_mom = df[MOM[i]].apply(lambda x: x >= threshold_mom.loc[:, MOM[i]], axis=0)
    select = select_mom & select_exist_future

    raw_return_select = raw_return.where(select, 0.0, inplace=False)
    # scale to convex weight
    position_unscaled = weight_cap_unscaled.where(select, 0.0, inplace=False)
    scale_factor = position_unscaled.sum(axis='columns')
    position_scaled = position_unscaled.div(scale_factor, axis='index')

    # calculate the position at the end of last year
    prev_position_unscaled = (1 + raw_return_select) * position_scaled
    prev_position_unscaled = prev_position_unscaled.drop(prev_position_unscaled.index[-1])
    prev_position_unscaled.index = prev_position_unscaled.index + 1

    scale_factor = prev_position_unscaled.sum(axis='columns')
    prev_position_scaled = prev_position_unscaled.div(scale_factor, axis='index')

    prev_position_scaled.loc[1965] = 0
    prev_position_scaled.sort_index(inplace=True)

    # compute the transaction by current_position_scaled - prev_position_scaled, relative to current year return

    raw_return_yearly_matrix = raw_return_select * position_scaled
    raw_return_yearly_series = raw_return_yearly_matrix.sum(axis=1)

    change_in_position = (position_scaled - prev_position_scaled).abs()
    cost_matrix = transaction_cost * change_in_position
    net_return_yearly_matrix = raw_return_yearly_matrix - cost_matrix
    net_return_yearly_series = net_return_yearly_matrix.sum(axis=1)

    mom_raw_return_comparison.loc[:, MOM[i]] = raw_return_yearly_series
    mom_net_return_comparison.loc[:, MOM[i]] = net_return_yearly_series

mom_raw_return_comparison.to_csv('output/momentum_raw_return_comparison.csv')
mom_net_return_comparison.to_csv('output/momentum_net_return_comparison.csv')

print('-----------')
print('Hello World')
