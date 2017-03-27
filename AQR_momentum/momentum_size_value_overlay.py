"""
with the best momentum indicator
combine it with value indicator / size indicator
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
size = 'market_cap'
value = 'value'
company = 'code'
year = 'year'
column_deciles = ['Decile ' + str(i) for i in range(1, 11)]
raw_return = df[future_return[1]]

'''
GOAL: compare net return series having boundary stock handling and from no boundary stock handling
OUTPUT: four net_return series, mom, mom+value, mom+size, mom+value+size, # year * # 1
'''
column_overlay = ['MOM+large', 'MOM+value', 'MOM+size', 'MOM+value+size']
mom_value_size_overlay = pd.DataFrame(index=df.index, columns=column_overlay)
overlay_number_of_stock = pd.DataFrame(index=df.index, columns=column_overlay)
'''
construct selection criterion based on momentum and data availability
CAUTION:    exclude stocks that have missing future returns may induce future information,
            because missing future return can be a sign of bad stock
'''

select_exist_future = df[future_return[1]].notnull()

threshold_mom_0 = np.nanpercentile(df[MOM[4]], q=60, axis=1)
select_mom_0 = df[MOM[4]].apply(lambda x: x >= threshold_mom_0, axis=0)
threshold_large_0 = np.nanpercentile(df[size], q=90, axis=1)
select_large_0 = df[size].apply(lambda x: x > threshold_large_0, axis=0)

threshold_mom_1 = np.nanpercentile(df[MOM[4]], q=70, axis=1)
select_mom_1 = df[MOM[4]].apply(lambda x: x >= threshold_mom_1, axis=0)
threshold_value_1 = np.nanpercentile(df[value], q=70, axis=1)
select_value_1 = df[value].apply(lambda x: x > threshold_value_1, axis=0)

threshold_mom_2 = np.nanpercentile(df[MOM[4]], q=70, axis=1)
select_mom_2 = df[MOM[4]].apply(lambda x: x >= threshold_mom_2, axis=0)
threshold_size_2 = np.nanpercentile(df[size], q=30, axis=1)
select_size_2 = df[size].apply(lambda x: x < threshold_size_2, axis=0)


threshold_mom_3 = np.nanpercentile(df[MOM[4]], q=60, axis=1)
select_mom_3 = df[MOM[4]].apply(lambda x: x >= threshold_mom_3, axis=0)
threshold_value_3 = np.nanpercentile(df[value], q=60, axis=1)
select_value_3 = df[value].apply(lambda x: x > threshold_value_3, axis=0)
threshold_size_3 = np.nanpercentile(df[size], q=40, axis=1)
select_size_3 = df[size].apply(lambda x: x < threshold_size_3, axis=0)

select_mom_large = select_mom_0 & select_large_0 & select_exist_future
select_mom_value = select_mom_1 & select_value_1 & select_exist_future
select_mom_size = select_mom_2 & select_size_2 & select_exist_future
select_mom_value_size = select_mom_3 & select_value_3 & select_size_3 & select_exist_future

select_pool = [select_mom_large, select_mom_value, select_mom_size, select_mom_value_size]

'''
weight matrix based on capitalization
'''
weight_cap_unscaled = df[size]
# fill nan caps with 1
weight_cap_unscaled.fillna(0, inplace=True)

'''
FOR
'''
for i in range(0, len(column_overlay)):
    select = select_pool[i]
    overlay_number_of_stock.loc[:, column_overlay[i]] = select.sum(axis=1)
    raw_return_select = raw_return.where(select, 0.0, inplace=False)

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

    # compute the transaction by curr_position_scaled - prev_position_scaled, relative to current year return

    raw_return_yearly_matrix = raw_return_select * position_scaled
    raw_return_yearly_series = raw_return_yearly_matrix.sum(axis=1)

    change_in_position = (position_scaled - prev_position_scaled).abs()
    cost_matrix = transaction_cost * change_in_position

    net_return_yearly_matrix = raw_return_yearly_matrix - cost_matrix
    net_return_yearly_series = net_return_yearly_matrix.sum(axis=1)

    mom_value_size_overlay.loc[:, column_overlay[i]] = net_return_yearly_series


mom_value_size_overlay.to_csv('output/mom_value_size_overlay.csv')
overlay_number_of_stock.to_csv('output/overlay_number_of_stock.csv')

print('-----------')
print('Hello World')
