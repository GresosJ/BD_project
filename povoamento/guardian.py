import mysql.connector

def process_guardian_data(data, connection):

    for index, row in data.iterrows():
        
        name = row['Name']
        email = row['Email']
        phone = str(row['Phone'])

        query = "CALL insert_Guardian(%s,%s,%s);"
        
        cursor = connection.cursor()
        try:
            cursor.execute(query, (name,email,phone,))
            connection.commit()
        except mysql.connector.Error as error:
            print("(Guardian) Erro durante a execução do comando SQL:", error)
        
        cursor.close()
