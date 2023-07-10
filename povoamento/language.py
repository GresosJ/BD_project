import mysql.connector

def process_language_data(data, connection):

    for index, row in data.iterrows():
        
        name = row['Name']

        query = "CALL insert_Language(%s);"
        
        cursor = connection.cursor()
        try:
            cursor.execute(query, (name,))
            connection.commit()
        except mysql.connector.Error as error:
            print("(Lang) Erro durante a execução do comando SQL:", error)
        
        cursor.close()
