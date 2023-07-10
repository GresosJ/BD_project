import datetime
import mysql.connector


def process_mentor_data(data, connection):

    for index, row in data.iterrows():
        
        name = row['Name']
        email = row['Email']
        phone = str(row['Phone'])
        recruitment = int(row['Recrutamento'])
        degree = row['Curso']
        regDate = row['Registration Date'].timestamp()
        languages = row['Languages']

        query = "CALL insert_Mentor(%s,%s,%s,%s,%s,%s,%s);"
        
        cursor = connection.cursor()
        try:
            cursor.execute(query, (name,email,phone,degree,recruitment, datetime.datetime.fromtimestamp(regDate).strftime('%Y-%m-%d %H:%M:%S'),languages,))
            connection.commit()
        except mysql.connector.Error as error:
            print("(Mentor) Erro durante a execução do comando SQL:", error)
        
        cursor.close()
