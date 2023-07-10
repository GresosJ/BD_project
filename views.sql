USE `CoderDojoBraga`;
USE `CoderDojo`;

DROP PROCEDURE IF EXISTS View_Ninja_By_Belt;
DROP PROCEDURE IF EXISTS View_Ninja_By_Age;
DROP PROCEDURE IF EXISTS View_Ninja_Language;
DROP PROCEDURE IF EXISTS View_Ninja_In_Session;
DROP PROCEDURE IF EXISTS View_Mentor_By_Degree;
DROP VIEW IF EXISTS View_Mentor_In_Recruitment; 
DROP PROCEDURE IF EXISTS View_Mentors_By_Language;
DROP PROCEDURE IF EXISTS View_Mentors_In_Session;
DROP PROCEDURE IF EXISTS View_Ninjas_Mentors;

-- ---------------------------------------------------
-- --------------------- VIEWS ----------------------- 
-- ---------------------------------------------------

-- ---------------------------------------------------
-- "View" " View Ninjas by colored Belt"
-- ---------------------------------------------------      

DELIMITER //
CREATE PROCEDURE View_Ninja_By_Belt(
	IN color VARCHAR(255)
)
BEGIN
    SELECT Ninja.ID_Ninja, Ninja.Name FROM Ninja
		JOIN NinjaBelt ON NinjaBelt.Ninja_ID_Ninja = Ninja.ID_Ninja
		JOIN Belt ON Belt.ID_Belt = NinjaBelt.Belt_ID_Belt
			WHERE Belt.Color = color;
END //
DELIMITER ;

-- ---------------------------------------------------
-- "View" " View Ninjas by specipic Age"
-- ---------------------------------------------------
DELIMITER //
CREATE PROCEDURE View_Ninja_By_Age(
	IN Age INT
)
BEGIN
    SELECT Ninja.ID_Ninja, Ninja.Name FROM Ninja
		WHERE TIMESTAMPDIFF(YEAR, Ninja.Birthday, CURDATE()) = Age;
END//
DELIMITER ;


-- ---------------------------------------------------
-- "View" " View Ninjas by languages being learned"
-- ---------------------------------------------------     
DELIMITER //
CREATE PROCEDURE View_Ninja_Language(
    IN language_Name VARCHAR(50)
)
BEGIN
    SELECT Ninja.ID_Ninja, Ninja.Name FROM Ninja
			WHERE Ninja.Language_ID_Language = (SELECT L.ID_Language FROM Language L WHERE L.Name = language_Name);
END//
DELIMITER ;

-- ---------------------------------------------------
-- "View" " View Ninjas in Session" XXXX
-- ---------------------------------------------------    

DELIMITER //
CREATE PROCEDURE View_Ninja_In_Session(
	IN session_ID INT
)
BEGIN
	SELECT Ninja.ID_Ninja, Ninja.Name FROM Ninja
		JOIN SessionNinja ON SessionNinja.Ninja_ID_Ninja = Ninja.ID_Ninja
			WHERE SessionNinja.Session_ID_Session = session_ID;
END //
DELIMITER ;

-- ---------------------------------------------------
-- "View" " View Mentor by degree"
-- ---------------------------------------------------   
DELIMITER //
CREATE PROCEDURE View_Mentor_By_Degree(
	IN mentor_Degree VARCHAR(50)
)
BEGIN
	SELECT Mentor.ID_Mentor, User.Name FROM Mentor
		JOIN User ON User.ID_User = Mentor.User_ID_User
			WHERE Mentor.Degree = mentor_Degree;
END //
DELIMITER ;

-- ---------------------------------------------------
-- "View" " View Mentor in Recruitment"
-- ---------------------------------------------------   
CREATE VIEW View_Mentor_In_Recruitment AS
	SELECT Mentor.ID_Mentor, User.Name FROM Mentor
		JOIN User ON User.ID_User = Mentor.User_ID_User
			WHERE Mentor.Recruitment = true;

-- ---------------------------------------------------
-- "View" "View Mentor by Language"
-- ---------------------------------------------------   
DELIMITER //
CREATE PROCEDURE View_Mentors_By_Language(
    IN language_Name VARCHAR(50)
)
BEGIN
    SELECT Mentor.ID_Mentor, User.Name FROM Mentor
		JOIN User ON User.ID_User = Mentor.User_ID_User
		JOIN MentorLanguage ON MentorLanguage.Mentor_ID_Mentor = Mentor.ID_Mentor
		JOIN Language ON Language.ID_Language = MentorLanguage.Language_ID_Language
			WHERE Language.Name = language_Name;
END //
DELIMITER ;


-- ---------------------------------------------------
-- "View" "View Mentor in Session" XXXX
-- ---------------------------------------------------   
DELIMITER //
CREATE PROCEDURE View_Mentors_In_Session(
    IN session_ID INT
)
BEGIN
    SELECT Mentor.ID_Mentor, User.Name FROM Mentor
		JOIN User ON User.ID_User = Mentor.User_ID_User
		JOIN SessionMentor ON SessionMentor.Mentor_ID_Mentor = Mentor.ID_Mentor
			WHERE SessionMentor.Session_ID_Session = session_ID;
END //
DELIMITER ;

