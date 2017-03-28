import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from os import chdir

chdir('D:/var/Google Drive/output/pics')

# net_return_prev_2_12_deciles = pd.read_csv('1. net_return_prev_2_12_deciles.csv')
# net_return_prev_2_12_deciles.set_index(['year'], drop=True, inplace=True)
# cumulative_profit = (1.0 + net_return_prev_2_12_deciles).cumprod(axis=0)
# cumulative_profit.plot()

# net_return_different_mom = pd.read_csv('2.1 net_return_different_mom_10.csv')
# net_return_different_mom.set_index(['year'], drop=True, inplace=True)
# cumulative_profit = (1.0 + net_return_different_mom).cumprod(axis=0)
# cumulative_profit.plot()

# net_return_different_mom = pd.read_csv('2.2 net_return_different_mom_20.csv')
# net_return_different_mom.set_index(['year'], drop=True, inplace=True)
# cumulative_profit = (1.0 + net_return_different_mom).cumprod(axis=0)
# cumulative_profit.plot()

# transaction_cost_handling = pd.read_csv('3. transaction_cost_handling_20.csv')
# transaction_cost_handling.set_index(['year'], drop=True, inplace=True)
# transaction_cost_handling.drop('MOM+boundary', axis=1, inplace=True)
# cumulative_profit = (1.0 + transaction_cost_handling).cumprod(axis=0)
# cumulative_profit.plot()

# net_return_mom_value_size_overlay = pd.read_csv('4. net_return_mom_value_size_overlay.csv')
# net_return_mom_value_size_overlay.set_index(['year'], drop=True, inplace=True)
# cumulative_profit = (1.0 + net_return_mom_value_size_overlay).cumprod(axis=0)
# cumulative_profit.plot()

# number_of_stock_mom_value_size_overlay = pd.read_csv('4.1 number_of_stock_mom_value_size_overlay.csv')
# number_of_stock_mom_value_size_overlay.set_index(['year'], drop=True, inplace=True)
# number_of_stock_mom_value_size_overlay.plot(kind='bar')

net_return_mom_value_size_overlay = pd.read_csv('4. net_return_mom_value_size_overlay.csv')
net_return_mom_value_size_overlay.set_index(['year'], drop=True, inplace=True)
net_return_mom_value_size_overlay.drop(['MOM+large', 'MOM+value+size'], axis=1, inplace=True)
cumulative_profit = (1.0 + net_return_mom_value_size_overlay).cumprod(axis=0)
cumulative_profit.plot()



plt.show()

print('-----------')
print('Hello World')