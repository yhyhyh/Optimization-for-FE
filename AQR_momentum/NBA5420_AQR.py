import pandas as pd
import numpy as np
from os import chdir
chdir('D:/CodeHub/Python/NBA5420/data')
df = pd.read_pickle('pickle_unstacked')
chdir('D:/CodeHub/Python/NBA5420')

'''
masks
'''
MOM = ['prev_1_1', 'prev_1_12', 'prev_1_24', 'prev_1_36', 'prev_2_12', 'prev_2_24', 'prev_2_36']
fut_ret = ['nextmonth_return', 'nextyear_return']
size = 'market_cap'
value = 'market_book'
company = 'code'
year = 'year'

'''
construct selection criterion based on momentum and data availability
'''
threshold_mom = np.nanpercentile(df[MOM[2]], q=90, axis=1)
# criterion_mom = df[MOM[1]] >= threshold_mom  # cannot broadcast this way
criterion_mom = df[MOM[1]].apply(lambda x: x >= threshold_mom, axis=0)
# nan future return stock cannot be used for back test
exist_return = df[fut_ret[1]].notnull()
select = criterion_mom & exist_return

'''
weight matrix based on capitalization
'''
tertile_hi = np.nanpercentile(df[size], q=66.7, axis=1)
tertile_lo = np.nanpercentile(df[size], q=33.3, axis=1)
# threshold_large = df[size].quantile(.67, axis='index')  # does not work correctly with nans
# threshold_medium = df[size].quantile(.33, axis='index')

cond_large = df[size].apply(lambda x: x >= tertile_hi, axis=0)
cond_small = df[size].apply(lambda x: x <= tertile_lo, axis=0)

cond_medium1 = df[size].apply(lambda x: x < tertile_hi, axis=0)
cond_medium2 = df[size].apply(lambda x: x > tertile_lo, axis=0)
cond_medium = cond_medium1 & cond_medium2

cap_large = pd.DataFrame(3.0, columns=df[size].columns, index=df[size].index)
cap_medium = pd.DataFrame(2.0, columns=df[size].columns, index=df[size].index)
cap_small = pd.DataFrame(1.0, columns=df[size].columns, index=df[size].index)

# for each category, entries belong to other categories will be filled with 0
# nan caps will be filled with 0
cap_large.where(cond_large, 0.0, inplace=True)
cap_medium.where(cond_medium, 0.0, inplace=True)
cap_small.where(cond_small, 0.0, inplace=True)
# only nan caps are represented by 0
weight_size_unscaled = cap_large + cap_medium + cap_small
# fill nan caps with 1
weight_size_unscaled.replace(to_replace=[0], value=1, inplace=True)

'''
apply selection criterion to return and weight
'''
return_individual = df[fut_ret[1]]
ret = return_individual.where(select, 0.0, inplace=False)
# scale to convex weight
weight_unscaled = weight_size_unscaled.where(select, 0.0, inplace=False)
scale_factor = weight_unscaled.sum(axis='columns')
weight_scaled = weight_unscaled.div(scale_factor, axis='index')
# print weight_scaled.sum(axis='columns') # check convex weight
pnl_matrix = ret * weight_scaled
pnl = 1 + pnl_matrix.sum(axis=1)
print pnl.cumprod()

print '-----------'
print 'Hello World'
