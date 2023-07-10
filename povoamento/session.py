import datetime
import mysql.connector


def process_session_data(data, connection):

    for index, row in data.iterrows():
        
        name = row['Name']
        begDate = row['Begin_Date'].timestamp()
        endDate = row['End_Date'].timestamp()
        places = row['Places']
        local = row['Local']
        obs = row['Observations']

        query = "CALL insert_Session(%s,%s,%s,%s,%s,%s);"
        
        cursor = connection.cursor()
        try:
            cursor.execute(query, (
                name,
                datetime.datetime.fromtimestamp(begDate).strftime('%Y-%m-%d %H:%M:%S'),
                datetime.datetime.fromtimestamp(endDate).strftime('%Y-%m-%d %H:%M:%S'),
                places,
                local,
                obs
                ))
            connection.commit()
        except mysql.connector.Error as error:
            print("(Session) Erro durante a execução do comando SQL:", error)
        
        cursor.close()
