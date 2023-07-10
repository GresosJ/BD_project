import datetime
import mysql.connector
import pandas as pd

def process_ninja_data(ninja_data, guardian_data, connection):

    for index, ninja_row in ninja_data.iterrows():

        name = ninja_row['Name']
        birthday = ninja_row['BD Date'].timestamp()
        regDate = ninja_row['Registration Date'].timestamp()
        language = ninja_row['Languages']

        guardian_row = guardian_data.loc[index]
        guardianPhone = str(guardian_row['Phone'])
        
        query_insert_ninja = "CALL insert_Ninja(%s, %s, (SELECT ID_User FROM User WHERE Telephone = %s), %s, %s);"

        cursor = connection.cursor()
        try:
            cursor.execute(query_insert_ninja, (
                name,
                datetime.datetime.fromtimestamp(birthday).strftime('%Y-%m-%d %H:%M:%S'),
                guardianPhone,
                datetime.datetime.fromtimestamp(regDate).strftime('%Y-%m-%d %H:%M:%S'),
                language
            ))
            connection.commit()
        except mysql.connector.Error as error:
            print("(Ninja) Erro durante a execução do comando SQL:", error)
        
        cursor.close()
