import pandas as pd
from os import chdir
import numpy as np

chdir('D:/CodeHub/Python/NBA5420/data')

# build dictionary for (company name, code) pairs from old data
# df_old = pd.read_csv('AQR_data_v0.csv', header=0, usecols=[0, 2])
# company_code_dic = dict(zip(df_old['comnam'], df_old['code']))
#
# np.save('company_code_dic.npy', company_code_dic)
# print len(company_code_dic)
#
# company_code_dic2 = np.load('company_code_dic.npy').item()
# print len(company_code_dic2)

# replace company name with code in new data

# replace_dic = {'comnam': company_code_dic}
# df_new = pd.read_csv('AQR_data_v1.csv', header=0, nrows=1000, sep=',')
# df_new.replace(to_replace=replace_dic, inplace=True)

# read new data
df = pd.read_csv('AQR_data_v2.csv', header=0, sep=',', engine='c')
df.columns.names = ['vars']
print df.columns
df.drop('comnam', axis=1, inplace=True)
print df.shape
# print df.loc[2008]['Market Cap']
# print df['Market Cap'].loc[2008]
# print df.loc[2008, ['Market Cap']]

# drop duplicates where year and company name pairs are identical
df.drop_duplicates(['year', 'code'], inplace=True)
# drop rows where either year or company is nan
df.dropna(axis='index', subset=['year', 'code'], how='any', inplace=True)
print df.shape

df.set_index(['year', 'code'], drop=True, inplace=True)


# output original data
df.to_pickle('pickle_original')
df.to_csv('data_original.csv')

# output unstacked data
df2 = df.unstack()
# drop all nan rows/years
df2.dropna(axis='index', how='all', inplace=True)
print df2.shape

df2.to_pickle('pickle_unstacked')
df2.to_csv('data_unstacked.csv')

print '-----------'
print 'Hello World'
