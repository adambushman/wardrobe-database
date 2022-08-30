import mysql.connector
from mysql.connector import Error
import pandas as pd


# Function to connect to database
def create_db_connection(host_name, user_name, user_password, db_name):
    connection = None
    try:
        connection = mysql.connector.connect(
            host =host_name,
            user = user_name,
            passwd = user_password,
            database = db_name
        )
        print("Connection successful")
    except Error as err:
        print(f"Error: '{err}'")

    return connection

# Function to execute a non-display queries
def execute_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        print("Query successful")
    except Error as err:
        print(f"Error: '{err}'")

# Function to execute a query and return the display
def read_query(connection, query):
    cursor = connection.cursor()
    result = None
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        columns = cursor
        return zip(columns, result)
    except Error as err:
        print(f"Error: '{err}'")


# Connection to WardrobeDB
wd_connection = create_db_connection("localhost", "AdamB", "clt@42jSKNdXKzoHsV3Y", "wardrobedb")

# Test query
tq = "SELECT * FROM wItem;"

test = read_query(wd_connection, tq)

itemTable = pd.DataFrame(test, columns = ["itemID"])