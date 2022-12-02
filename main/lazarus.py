"""
Main code for lazarus.

"""

import pandas as pd
from io import StringIO

def main():
    # input table
    tablecalc = TableCalc(S)
    print(tablecalc.question + '\n')
    print(tablecalc.answers)
    print('\n')
    print('Correct answer: ' + tablecalc.correct_answer)

    print('Stop')
    return


class TableCalc:

    def __init__(self, input):
        self.input = input
        method = 'pandas'
        if type(self.input) == str:
            self.str_process(method)

        else:
            raise TypeError('Cannot handle table input type {}.', format(type(self.input)))

    def str_process(self, method):
        if method == 'pandas':
            self.str_to_pandas()
            self.pandas_calc()

        else:
            raise Exception('No valid calculation method chosen to process string.')

    def str_to_pandas(self):
        self.input_io = StringIO(self.input)
        # self.df = pd.read_csv(self.input_io, sep=",", header=None, names=['col1', 'col2'])
        self.df = pd.read_csv(self.input_io, sep=",", header=0)
        self.df_col_names = list(self.df)

    def pandas_calc(self):
        rows = len(self.df.index)
        self.df_count = self.df.groupby([self.df_col_names[1]], sort=False)[self.df_col_names[1]].count().reset_index(name='count')
        self.df_count = self.df_count.sort_values(by=['count'])
        unique = len(pd.unique(self.df[self.df_col_names[1]]))

        if unique == rows:
            # diff col2 for every col 1:
            # choose matching format
            pass

        elif unique == 2 and self.df_count.iloc[0,1] == 1:
            # only two different values, and only one row has one of the values
            # only one different col2 value:
            # choose MC1 format with row that has the one value
            self.question = 'What {} is {}?'.format(self.df_col_names[1], self.df_count.iloc[0,0])
            self.answers = self.df[self.df_col_names[0]].to_string(index=False)
            self.correct_answer = self.df.loc[self.df[self.df_col_names[1]] == self.df_count.iloc[0,0]]
            self.correct_answer = self.correct_answer[self.df_col_names[0]].to_string(index=False)

        else:
            # more than one col2 value, and multiple rows have the same value:
            # choose MCM format using most common col2 value
            pass


S = '''
Sorting Algorithm,Space Complexity
Selection Sort,O(1)
Bubble Sort,O(1)
Insertion Sort,O(1)
Merge Sort,O(n)
Quick Sort,O(1)
Heap Sort,O(1)
'''

if __name__ == '__main__':
    main()
