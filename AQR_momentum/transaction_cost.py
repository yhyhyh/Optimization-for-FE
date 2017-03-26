import pandas as pd
import numpy as np

from os import chdir
chdir('D:/CodeHub/Python/NBA5420/data')

df = pd.read_pickle('pickle_unstacked')

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

'''
distinguish large cap, mid cap and small cap, build transaction cost
'''
boundary_hi = np.nanpercentile(df[size], q=90.0, axis=1)
boundary_lo = np.nanpercentile(df[size], q=70.0, axis=1)
# threshold_large = df[size].quantile(.67, axis='index')  # does not work correctly with nans

cond_large = df[size].apply(lambda x: x >= boundary_hi, axis=0)
cond_small = df[size].apply(lambda x: x <= boundary_lo, axis=0)

cond_mid1 = df[size].apply(lambda x: x < boundary_hi, axis=0)
cond_mid2 = df[size].apply(lambda x: x > boundary_lo, axis=0)
cond_mid = cond_mid1 & cond_mid2

transaction_cost_large_cap = pd.DataFrame(0.001, columns=df[size].columns, index=df[size].index)
transaction_cost_mid_cap = pd.DataFrame(0.002, columns=df[size].columns, index=df[size].index)
transaction_cost_small_cap = pd.DataFrame(0.003, columns=df[size].columns, index=df[size].index)

# for each category, entries belong to other categories will be filled with 0
# nan caps will be filled with 0
transaction_cost_large_cap.where(cond_large, 0.0, inplace=True)
transaction_cost_mid_cap.where(cond_mid, 0.0, inplace=True)
transaction_cost_small_cap.where(cond_small, 0.0, inplace=True)

# print(cond_large.sum(axis='columns'))
# print(cond_medium.sum(axis='columns'))
# print(cond_small.sum(axis='columns'))
# print(cap_large.sum(axis='columns')/3)
# print(cap_medium.sum(axis='columns')/2)
# print(cap_small.sum(axis='columns'))

transaction_cost = transaction_cost_large_cap + transaction_cost_mid_cap + transaction_cost_small_cap
# regard nan caps as small caps
transaction_cost.replace(to_replace=[0], value=0.003, inplace=True)

transaction_cost.to_pickle('transaction_cost')

print('-----------')
print('Hello World')