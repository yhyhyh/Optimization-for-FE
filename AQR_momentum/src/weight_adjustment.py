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

# mom_raw_return_comparison = pd.DataFrame(index=df.index, columns=MOM)
# mom_net_return_comparison = pd.DataFrame(index=df.index, columns=MOM)

'''
construct selection criterion based on momentum and data availability
CAUTION:    exclude stocks that have missing future returns may induce future information,
            because missing future return can be a sign of bad stock
'''

select_exist_future = df[future_return[1]].notnull()

threshold_mom = np.nanpercentile(df[MOM[4]], q=80, axis=1)
select_mom = df[MOM[4]].apply(lambda x: x >= threshold_mom, axis=0)

select = select_mom  # & select_exist_future

raw_return_select = raw_return.where(select, 0.0, inplace=False)

'''
START: how to add weight adjustment
'''

# select i   + score i      -> select_new i
# select i+1 - select_new i -> score i + 1

score = pd.DataFrame(1.0, index=select.index, columns=select.columns)
select_new = pd.DataFrame(index=select.index, columns=select.columns)
select_new.loc[1965, :] = select.loc[1965, :]


for i in range(1, select.shape[0]):
    temp = select.loc[1965+i, :] - select_new.loc[1964+i, :]
    score.loc[1965 + i, :].where(temp > 0, 5.0 / 3.0, inplace=True)
    score.loc[1965 + i, :].where(temp < 0, 3.0 / 5.0, inplace=True)
    select_new.loc[1965+i, :] = select.loc[1965+i, :] * score.loc[1965 + i, :]

weight_adjustment = score.cumprod(axis=0)
position_unscaled = (weight_cap_unscaled * weight_adjustment).where(select, 0.0, inplace=False)
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

'''
END: how to add weight adjustment
'''

# compute the transaction by curr_position_scaled - prev_position_scaled, relative to current year return

raw_return_yearly_matrix = raw_return_select * position_scaled
raw_return_yearly_series = raw_return_yearly_matrix.sum(axis=1)

change_in_position = (position_scaled - prev_position_scaled).abs()
cost_matrix = transaction_cost * change_in_position

net_return_yearly_matrix = raw_return_yearly_matrix - cost_matrix
net_return_yearly_series = net_return_yearly_matrix.sum(axis=1)

net_return_yearly_series.to_csv('output/momentum_net_return_with_weight adjustment.csv')

print('-----------')
print('Hello World')
