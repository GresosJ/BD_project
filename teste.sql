SELECT * FROM Ninja;
SELECT * FROM User;
SELECT * FROM Guardian;
SELECT * FROM Belt;
SELECT * FROM Language;
SELECT * FROM Session;
SELECT * FROM MentorLanguage ORDER BY Mentor_ID_Mentor ASC;

CALL make_Lecture();
SELECT * FROM Lecture;

CALL insert_Mentor("Nome","email@","129189238","LEI",1,null,"C,Python");

SELECT ID_User, Name FROM User;