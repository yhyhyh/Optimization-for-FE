import numpy as np
import pandas as pd

# # Save
# dictionary = {'hello':'world'}
# np.save('my_file.npy', dictionary)
#
# # Load
# read_dictionary = np.load('my_file.npy').item()
# print(read_dictionary['hello'])

# build dictionary for (company name, code) pairs from old data
df_old = pd.read_csv('AQR_data_v0.csv', header=0, usecols=[0, 2])
company_code_dic = dict(zip(df_old['comnam'], df_old['code']))

np.save('company_code_dic.npy', company_code_dic)
print len(company_code_dic)

company_code_dic2 = np.load('company_code_dic.npy').item()
print len(company_code_dic2)

# replace company name with code in new data

replace_dic = {'comnam': company_code_dic}
df_new = pd.read_csv('AQR_data_v1.csv', header=0, nrows=1000, sep=',')
df_new.replace(to_replace=replace_dic, inplace=True)

print '-----------'
print 'Hello World'