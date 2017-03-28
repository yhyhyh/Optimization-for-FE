"""
with the best momentum indicator
compare net return from having boundary stock handling and from no boundary stock handling
"""

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
raw_return = df[future_return[1]]

'''
weight matrix based on capitalization
'''
weight_cap_unscaled = df[cap]
# fill nan caps with 1
weight_cap_unscaled.fillna(0, inplace=True)

'''
GOAL: compare net return series having boundary stock handling and from no boundary stock handling
OUTPUT: two net_return series, # year * # 1
'''

mom_raw_return_comparison = pd.DataFrame(index=df.index, columns=MOM)
mom_net_return_comparison = pd.DataFrame(index=df.index, columns=MOM)

'''
construct selection criterion based on momentum and data availability
CAUTION:    exclude stocks that have missing future returns may induce future information,
            because missing future return can be a sign of bad stock
'''

select_exist_future = df[future_return[1]].notnull()

threshold_mom = np.nanpercentile(df[MOM[4]], q=90, axis=1)
select_mom = df[MOM[4]].apply(lambda x: x >= threshold_mom, axis=0)

select = select_mom & select_exist_future

raw_return_select = raw_return.where(select, 0.0, inplace=False)

'''
START: how to add boundary handling
'''
# select_mom i + select_new i -1    -> score i
# score i                           -> select_new i

score = pd.DataFrame(0.0, index=select_mom.index, columns=select_mom.columns)
select_new = pd.DataFrame(index=select_mom.index, columns=select_mom.columns)
select_new.loc[1965, :] = select.loc[1965, :]


for i in range(1, select_mom.shape[0]):
    score.loc[1965 + i, :] = 0.9 * select_mom.loc[1965+i, :] + 0.1 * select_new.loc[1964+i, :]
    threshold_score = score.loc[1965 + i, :].quantile(q=.85)
    select_new.loc[1965+i, :] = score.loc[1965 + i, :]
    print(str(1965 + i))

'''
END: how to add boundary handling
'''

position_unscaled = weight_cap_unscaled.where(select_new, 0.0, inplace=False)
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



# compute the transaction by curr_position_scaled - prev_position_scaled, relative to current year return

raw_return_yearly_matrix = raw_return_select * position_scaled
raw_return_yearly_series = raw_return_yearly_matrix.sum(axis=1)

change_in_position = (position_scaled - prev_position_scaled).abs()
cost_matrix = transaction_cost * change_in_position

net_return_yearly_matrix = raw_return_yearly_matrix - cost_matrix
net_return_yearly_series = net_return_yearly_matrix.sum(axis=1)

net_return_yearly_series.to_csv('output/momentum_net_return_with_boundary.csv')

print('-----------')
print('Hello World')
