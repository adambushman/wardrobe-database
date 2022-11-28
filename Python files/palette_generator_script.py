import pandas as pd
import numpy as np
import mysql.connector


# Get the data
def execute(query):
    cnx = mysql.connector.connect(
        host = 'localhost',
        user = 'AdamB',
        passwd = 'clt@42jSKNdXKzoHsV3Y',
        database = 'wardrobedb'
    )

    cursor = cnx.cursor()
    cursor.execute(query)

    real_cols = dict(map(lambda i,j : (i,j) , list(range(0, len(cursor.column_names))), cursor.column_names))
    data = pd.DataFrame(cursor).rename(real_cols, axis = 1)

    cursor.close()
    cnx.close()

    return(data)



# Transformation script
# ---------------------
cdf = (
    execute("SELECT * FROM vAllItemColors")
    .groupby(['hexCode', 'commonName'])
    .agg({'totalShare': 'sum'})
    .assign(type = "What I Own")
    .reset_index()
    .loc[:, ['type', 'hexCode', 'commonName', 'totalShare']]
    .append(
        (execute(
            "SELECT * FROM vAllFitColors \
            WHERE fitDate BETWEEN DATE(NOW() - INTERVAL 3 MONTH) AND NOW()"
         )
            .groupby(['hexCode', 'commonName'])
            .agg({'totalShare': 'sum'})
            .assign(type = "What I Wear")
            .reset_index()
            .loc[:, ['type', 'hexCode', 'commonName', 'totalShare']]
        ), 
        ignore_index = True
    )
    .assign(totalShare = lambda a_df: a_df['totalShare'].astype(float))
    .sort_values(['type', 'commonName', 'totalShare'], ascending = [True, True, False])
)

(pd.merge(
        (cdf
            .groupby(['type', 'commonName', 'hexCode'])
            .agg({'totalShare':'sum'})
            .assign(
                ymax = lambda a_cdf: a_cdf.groupby(['type', 'commonName']).cumsum(), 
                ymin = lambda b_cdf: b_cdf['ymax'] - b_cdf['totalShare']
            )
            .reset_index()
        ), 
        (cdf_i
            .groupby(['type', 'commonName'])
            .agg({'totalShare':'sum'})
            .assign(
                xmax = lambda a_cdf: a_cdf.groupby(['type']).cumsum(), 
                xmin = lambda b_cdf: b_cdf['xmax'] - b_cdf['totalShare']
            )
            .reset_index()
        ),
        how = 'inner', 
        on = ['type', 'commonName']
    )
    .assign(
        xmax_s  = lambda a_df: (a_df['xmax'] / a_df.groupby(['type'])['xmax', 'xmin'].transform(np.max).max(axis=1)), 
        xmin_s  = lambda b_df: (b_df['xmin'] / b_df.groupby(['type'])[['xmax', 'xmin']].transform(np.max).max(axis=1))
    )
    .assign(
        ymax_s  = lambda a_df: (a_df['ymax'] / a_df.groupby(['type', 'commonName'])['ymax', 'ymin'].transform(np.max).max(axis=1)), 
        ymin_s  = lambda b_df: (b_df['ymin'] / b_df.groupby(['type', 'commonName'])['ymax', 'ymin'].transform(np.max).max(axis=1))
    )
    .loc[:, ['type', 'commonName', 'hexCode', 'xmax_s', 'xmin_s', 'ymax_s', 'ymin_s']]
    .to_csv('C:/Users/Adam Bushman/Documents/colors_trans.csv')
)