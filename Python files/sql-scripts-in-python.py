import pandas as pd
import mysql.connector

# Function to execute a query and return a Pandas Data Frame
def execute(query):
    # Establish a connection
    cnx = mysql.connector.connect(
        host = 'localhost',
        user = 'AdamB',
        passwd = 'clt@42jSKNdXKzoHsV3Y',
        database = 'wardrobedb'
    )

    # Execute
    cursor = cnx.cursor()
    cursor.execute(query)

    # Create Pandas Data Frame with correct column names
    real_cols = dict(map(lambda i,j : (i,j) , list(range(0, len(cursor.column_names))), cursor.column_names))
    data = pd.DataFrame(cursor).rename(real_cols, axis = 1)

    # Close connection
    cursor.close()
    cnx.close()

    return(data)



test = execute("SELECT * FROM vAllFitColors;")