import pandas as pd
from os import chdir
import numpy as np

chdir('D:/CodeHub/Python/NBA5420/data')

# read new data
df = pd.read_csv('AQR_data_v2.csv', header=0, sep=',', engine='c')
df.columns.names = ['vars']
print(df.columns)
df.drop('comnam', axis=1, inplace=True)
print(df.shape)
# print df.loc[2008]['Market Cap']
# print df['Market Cap'].loc[2008]
# print df.loc[2008, ['Market Cap']]

# drop duplicates where year and company name pairs are identical
df.drop_duplicates(['year', 'code'], inplace=True)
# drop rows where either year or company is nan
df.dropna(axis='index', subset=['year', 'code'], how='any', inplace=True)
print(df.shape)

df.set_index(['year', 'code'], drop=True, inplace=True)

df.loc[:, 'value'] = df['market_book'] / df['market_cap']
df.drop(['market_book'], axis=1, inplace=True)

# output original data
df.to_pickle('pickle_original')
df.to_csv('data_original.csv')

# output unstacked data
df2 = df.unstack()
# drop all nan rows/years
df2.dropna(axis='index', how='all', inplace=True)
print(df2.shape)

df2.to_pickle('pickle_unstacked')
df2.to_csv('data_unstacked.csv')

print('-----------')
print('Hello World')
