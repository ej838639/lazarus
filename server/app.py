"""
Main code for lazarus project.
https://github.com/ej838639/lazarus

Development:
Open terminal and run:
export FLASK_APP=app.py
export FLASK_ENV=development
cd server
flask run --host=localhost --port=3000

Open browser and enter:
http://localhost:3000

Production:
Open terminal and run:
waitress-serve --port=80 app:app

Open browser and enter:
http://localhost

Test Case string input:
Sorting Algorithm,Space Complexity
Selection Sort,O(1)
Bubble Sort,O(1)
Insertion Sort,O(1)
Merge Sort,O(n)
Quick Sort,O(1)
Heap Sort,O(1)

"""

import pandas as pd
from io import StringIO
from flask import Flask, render_template, request, url_for, redirect
from waitress import serve
# from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# db = SQLAlchemy(app)
#
#
# class Item(db.Model):
#     id = db.Column(db.Integer, primary_key=True)
#     list_name = db.Column(db.String(64), index=True)
#     list_items = db.Column(db.String(256), index=True)
#     list_category = db.Column(db.String(256), index=True)

# db.create_all()


@app.route('/')
def main():

    return render_template('main.html')


@app.route('/submit', methods=('GET', 'POST'))
def submit():
    if request.method == 'POST':
        input1 = request.form['input1']

        return redirect(url_for('result_get', input1=input1))

    return render_template('submit.html')


@app.route('/result')
def result_get():
    # input1 = request.args['input1']

    input1 = '''
    Sorting Algorithm,Space Complexity
    Selection Sort,O(1)
    Bubble Sort,O(1)
    Insertion Sort,O(1)
    Merge Sort,O(n)
    Quick Sort,O(1)
    Heap Sort,O(1)
    '''

    tablecalc = TableCalc(input1)

    question_arr = list()
    answers_arr = list()
    correct_answer_arr = list()

    question_arr.append(tablecalc.question)
    answers_arr.append(tablecalc.answers)
    correct_answer_arr.append(tablecalc.correct_answer)

    # question_arr.append(test1)
    # answers_arr.append(input2)
    # correct_answer_arr.append("something3")

    return render_template('result.html',
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

if __name__ == "__main__":
    # app.run('0.0.0.0', port=3000)
    serve(app, port=80)
