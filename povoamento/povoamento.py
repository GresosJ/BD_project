import pandas as pd
import mysql.connector

from mentor import process_mentor_data
from language import process_language_data
from belt import process_belt_data
from ninja import process_ninja_data
from session import process_session_data
from guardian import process_guardian_data

# Connect to database
cnx = mysql.connector.connect(
    host="localhost",
    user="root",
    password="safestpassword",
    database="CoderDojo",
    port=3306,
    autocommit=True
)

if cnx.is_connected():
    print("Conectado ao servidor MySQL.")
else:
    print("Falha na conexão ao servidor MySQL.")

cursor = cnx.cursor()

# Open excel
file_path = 'bd.xlsx'

language_data = pd.read_excel(file_path, sheet_name='Language')
process_language_data(language_data,cnx)

belt_data = pd.read_excel(file_path,sheet_name='Belt')
process_belt_data(belt_data,cnx)

guardian_data = pd.read_excel(file_path,sheet_name='Guardian')
process_guardian_data(guardian_data,cnx)

mentor_data = pd.read_excel(file_path, sheet_name='Mentor')
process_mentor_data(mentor_data,cnx)

ninja_data = pd.read_excel(file_path, sheet_name='Ninja')
process_ninja_data(ninja_data,guardian_data,cnx)

session_data = pd.read_excel(file_path,sheet_name='Session')
process_session_data(session_data,cnx)