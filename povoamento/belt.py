import mysql.connector

def process_belt_data(data, connection):

    for index, row in data.iterrows():
        
        color = row['Color']

        query = "CALL insert_Belt(%s);"
        
        cursor = connection.cursor()
        try:
            cursor.execute(query, (color,))
            connection.commit()
        except mysql.connector.Error as error:
            print("(Belt) Erro durante a execução do comando SQL:", error)
        
        cursor.close()
