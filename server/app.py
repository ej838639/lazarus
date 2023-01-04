"""
Main code for lazarus project.
https://github.com/ej838639/lazarus

Open terminal and run:
export FLASK_APP=app.py
export FLASK_ENV=development
cd server
flask run --host=localhost --port=3000

Open browser and enter:
http://localhost:3000/quiz_create/result

"""

import pandas as pd
from io import StringIO
from flask import Flask, render_template, request, url_for, redirect

app = Flask(__name__)


@app.route('/quiz_create/result')
def result_get():
    S = '''
    Sorting Algorithm,Space Complexity
    Selection Sort,O(1)
    Bubble Sort,O(1)
    Insertion Sort,O(1)
    Merge Sort,O(n)
    Quick Sort,O(1)
    Heap Sort,O(1)
    '''

    tablecalc = TableCalc(S)

    question_arr = list()
    answers_arr = list()
    correct_answer_arr = list()

    question_arr.append(tablecalc.question)
    answers_arr.append(tablecalc.answers)
    correct_answer_arr.append(tablecalc.correct_answer)

    return render_template('index.html',
                           question=question_arr,
                           answers=answers_arr,
                           correct_answer=correct_answer_arr)


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
        self.df = pd.read_csv(self.input_io, sep=",", header=0)
        self.df_col_names = list(self.df)

    def pandas_calc(self):
        rows = len(self.df.index)
        self.df_count = self.df.groupby([self.df_col_names[1]], sort=False)[self.df_col_names[1]].count().reset_index(name='count')
        self.df_count = self.df_count.sort_values(by=['count'])
        unique = len(self.df_count)

        if unique == rows:
            # diff col2 for every col 1:
            # choose matching format
            pass

        else:
            if unique == 2 and self.df_count.iloc[0,1] == 1:
                # only two different values, and only one row has one of the values
                # only one different col2 value:
                # choose MC1 format with row that has the one value
                self.question = 'What {} is {}?'.format(self.df_col_names[1], self.df_count.iloc[0,0])
                # self.answers = self.df[self.df_col_names[0]].to_string(index=False)
                self.answers = self.df[self.df_col_names[0]].tolist()

                # keep list and append 'X' to correct answers. Later: use format to import to quiz tool
                self.correct_answer = self.df.loc[self.df[self.df_col_names[1]] == self.df_count.iloc[0,0]]
                self.correct_answer = self.correct_answer[self.df_col_names[0]].to_string(index=False)

            # more than one col2 value, and multiple rows have the same value:
            # choose MCM format using most common col2 value. If multiple are most common, choose any.
