import pandas as pd
import numpy as np
import streamlit as sl
import os
import plotly.figure_factory as ff
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure

os.environ["MKL_NUM_THREADS"] = "1"
os.environ["OPENBLAS_NUM_THREADS"] = "1"
sl.set_option('deprecation.showPyplotGlobalUse', False)

article_coding = pd.read_csv("./streamlit/article_coding.csv")
article_info = pd.read_csv("./streamlit/main_article_info.csv")

merged = pd.merge(article_info, article_coding, on="Title", how="outer")
merged = merged[merged['Meets inclusion criteria (contains methods/study/model, is not a survey, implements empathetic AI)'] == "1"]

sl.write("""
# 📜 Empathetic AI Paper Explorer
🧠🤖 By [Esben Kran](https://kran.ai) with [Daina Crafa](https://dainacrafa.com) and [Nicolas Navarro-Guerrero](https://nicolas-navarro-guerrero.github.io/).
""")

sl.write("""
TODO:

1. Run it on the server in the subdirectory
2. Make horizontal bar chart with top 10 frequent values for each (button 1)
3. Make semantic co-occurrence analysis and split all column values by a non-space non-letter non-numerical character before frequentizing --> **pretty important to get proper representation of each column**
4. Perform simple NLP (tokenizing --> freq or TF-IDF) to show diff. properties of each column
""")

col1, col2 = sl.beta_columns(2)
option_1 = col1.selectbox(
    "Column one (splits by ; and ,)", list(merged)[::-1])
option_2 = col2.selectbox("Column two", list(merged)[::-1])


if sl.button("Show top 10 frequent values for each column"):
    if merged[option_1].dtype != np.number:
        col1.table(merged.drop(option_1, axis=1).join(merged[option_1].str.lower().str.replace(";", "#").str.replace(",", "#").str.replace("/", "#").str.split(
            "#", expand=True).stack().str.strip().reset_index(level=1, drop=True).rename(option_1))[option_1].value_counts()[:10])
    else:
        col1.table(merged[option_1].value_counts()[:10])
    if merged[option_2].dtype != np.number:
        col2.table(merged.drop(option_2, axis=1).join(merged[option_2].str.lower().str.replace(";", "#").str.replace(",", "#").str.replace("/", "#").str.split(
            "#", expand=True).stack().str.strip().reset_index(level=1, drop=True).rename(option_2))[option_2].value_counts()[:10])
    else:
        col2.table(merged[option_2].value_counts()[:10])
if sl.button("Show column 1 as bar chart"):
    if merged[option_1].dtype != np.number:
        merged.drop(option_1, axis=1).join(merged[option_1].str.lower().str.replace(";", "#").str.replace(",", "#").str.replace(
            "/", "#").str.split("#", expand=True).stack().str.strip().reset_index(level=1, drop=True).rename(option_1))[option_1].value_counts()[:10].iloc[::-1].plot.barh(color="black")
    else:
        merged[option_1].value_counts()[:10].iloc[::-
                                                  1].plot.barh(color="black")
    plt.title("Most frequent values for " + option_1)
    plt.show()
    sl.pyplot()
if sl.button("Test button 3"):
    sl.table(merged[[option_1, option_2]])
