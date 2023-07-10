USE `CoderDojoBraga`;
USE `CoderDojo`;

DROP PROCEDURE IF EXISTS insert_user;
DROP PROCEDURE IF EXISTS insert_Guardian;
DROP PROCEDURE IF EXISTS insert_Mentor;
DROP PROCEDURE IF EXISTS insert_Session;
DROP PROCEDURE IF EXISTS insert_Ninja;
DROP PROCEDURE IF EXISTS insert_Belt;
DROP PROCEDURE IF EXISTS insert_Language;
DROP PROCEDURE IF EXISTS insert_Lecture;
DROP PROCEDURE IF EXISTS make_Lecture_For_Session;
DROP PROCEDURE IF EXISTS make_Lecture;
DROP PROCEDURE IF EXISTS update_Ninja_Belt;

-- -----------------------------------------------------
-- Stored Procedure "Insert User"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_user (
  IN user_Name VARCHAR(255),
  IN user_Email VARCHAR(255),
  IN user_Telephone VARCHAR(15),
  OUT user_ID INT
)
BEGIN
  INSERT INTO `CoderDojo`.`User` (`Name`, `Email`, `Telephone`) VALUES (user_Name, user_Email, user_Telephone);
  
  -- Return user_ID
  SET user_ID = LAST_INSERT_ID();
END //
DELIMITER ;


-- -----------------------------------------------------
-- Stored Procedure "Insert Guardian"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_Guardian(
  IN user_Name VARCHAR(255),
  IN user_Email VARCHAR(255),
  IN user_Telephone VARCHAR(15)
)
BEGIN
	DECLARE user_ID INT;
    
    CALL insert_user(user_Name, user_Email, user_Telephone, user_ID);

    INSERT INTO `CoderDojo`.`Guardian` (`User_ID_User`) VALUES (user_ID);
END //

DELIMITER ;


-- -----------------------------------------------------
-- Stored Procedure "Insert Mentor"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_Mentor(
  IN user_Name VARCHAR(255),
  IN user_Email VARCHAR(255),
  IN user_Telephone VARCHAR(15),
  IN mentor_Degree VARCHAR(50),
  IN mentor_Recruitment TINYINT,
  IN mentor_Reg_Date DATETIME,
  IN mentor_languages VARCHAR(255)
)
BEGIN
    DECLARE user_ID INT;
    DECLARE language_ID INT;
    DECLARE language_Name VARCHAR(50);
    DECLARE marker INT;
    DECLARE language VARCHAR(255);
    DECLARE mentor_ID INT;

    CALL insert_user(user_Name, user_Email, user_Telephone, user_ID);
    
    INSERT INTO `CoderDojo`.`Mentor` (`Degree`, `Recruitment`, `Registration_Date`, `User_ID_User`) 
        VALUES (mentor_Degree, mentor_Recruitment, IFNULL(mentor_Reg_Date, NOW()), user_ID);

    SET mentor_ID = LAST_INSERT_ID();

    -- Parsing languages
    SET marker = 1;
    SET language = TRIM(SUBSTRING_INDEX(mentor_languages, ',', marker));

    WHILE language != '' DO
        -- Get Language ID 
        SET language_Name = TRIM(language);

        SELECT ID_Language INTO language_ID FROM Language
            WHERE Name = language_Name;

        -- Check if MentorLanguage pair already exists
        IF NOT EXISTS (SELECT 1 FROM MentorLanguage WHERE Mentor_ID_Mentor = mentor_ID AND Language_ID_Language = language_ID) 
        THEN
            INSERT INTO MentorLanguage (Mentor_ID_Mentor, Language_ID_Language) VALUES (mentor_ID, language_ID);
        END IF;

        -- Move to the next language
        SET marker = marker + 1;
        SET language = IF(
			marker > (LENGTH(mentor_languages) - LENGTH(REPLACE(mentor_languages, ',', '')) + 1), -- marker > number of languages
			'', 
			TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(mentor_languages, ',', marker), ',', -1))
		);

    END WHILE;
    
END //



DELIMITER ;

-- -----------------------------------------------------
-- Stored Procedure "Insert Session"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_Session(
	IN session_Name VARCHAR(255),
    IN session_Begin_Date DATETIME,
	IN session_End_Date DATETIME,
    IN session_Places INT,
	IN session_Local VARCHAR(50),
	IN session_Obs VARCHAR(255)
)
BEGIN
	
    INSERT INTO `CoderDojo`.`Session` (`Name`, `Begin_Date`, `End_Date`, `Places`, `Local`, `Obs`) 
    VALUES (
		session_Name, 
        session_Begin_Date, 
        session_End_Date, 
        session_Places, 
        session_Local, 
        IF(session_Obs = '', NULL, session_Obs)
    );
    
END //

DELIMITER ;


-- -----------------------------------------------------
-- Stored Procedure "Insert Ninja"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_Ninja(
	IN ninja_Name VARCHAR(255),
    IN ninja_Birthday DATETIME,
    IN ninja_User_ID_User INT,
    IN ninja_Reg_Date DATETIME,
    IN ninja_Language_Name VARCHAR(45)
)
BEGIN
	INSERT INTO `CoderDojo`.`Ninja` (`Name`, `Birthday`, `Registration_Date`, `Guardian_ID_Guardian`, `Language_ID_Language`, `Belt_ID_Belt`) 
    VALUES (
		ninja_Name,
        ninja_Birthday,
        IFNULL(ninja_Reg_Date, NOW()),
        (SELECT `ID_Guardian` FROM `Guardian` WHERE `User_ID_User` = ninja_User_ID_User),
        (SELECT `ID_Language` FROM `Language` WHERE `Name` = ninja_Language_Name),
        (SELECT `ID_Belt` FROM `Belt` WHERE `Color` = "Branco")
	
    );

END//

DELIMITER ;

-- -----------------------------------------------------
-- Stored Procedure "Insert Belt"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_Belt(
	IN belt_Color VARCHAR(50)
)
BEGIN
	INSERT INTO `CoderDojo`.`Belt` (`Color`) VALUES (belt_Color);
END//

DELIMITER ;

-- -----------------------------------------------------
-- Stored Procedure "Insert Language"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_Language(
	IN language_Name VARCHAR(50)
)
BEGIN
	INSERT INTO `CoderDojo`.`Language` (`Name`) VALUES (language_Name);
END//

DELIMITER ;


-- -----------------------------------------------------
-- Stored Procedure "Insert Lecture"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE insert_Lecture(
	IN l_mentor_ID INT,
    IN l_ninja_ID INT,
    IN l_session_ID INT
)
BEGIN
	INSERT INTO `CoderDojo`.`Lecture` (`Mentor_ID_Mentor`,`Session_ID_Session`,`Ninja_ID_Ninja`) VALUES (l_mentor_ID, l_session_ID, l_ninja_ID);
END//

DELIMITER ;


-- -----------------------------------------------------
-- Stored Procedure Make lecture for a session
-- -----------------------------------------------------
DELIMITER //

CREATE PROCEDURE make_Lecture_For_Session(
	IN session_ID INT
)
BEGIN
    DECLARE mentor_ID INT;
    DECLARE ninja_ID INT;
    DECLARE last_mentor_ID INT;
    
    -- Get last mentor added to the table Lacture
    SELECT Mentor_ID_Mentor INTO last_mentor_ID FROM Lecture 
		WHERE Session_ID_Session = session_ID 
			ORDER BY ID_Pairing DESC LIMIT 1;
    
    -- Get first mentor if there is any on the current session
    IF last_mentor_ID IS NULL THEN
        SET mentor_ID = (SELECT MIN(ID_Mentor) FROM Mentor);
    ELSE
        -- Otherwise get the next mentor
        SET mentor_ID = (SELECT MIN(ID_Mentor) FROM Mentor WHERE ID_Mentor > last_mentor_ID);
    END IF;
    
    WHILE mentor_ID IS NOT NULL DO
        -- Get Ninja with the same language as mentor
        SET ninja_ID = ( 
        SELECT ID_Ninja FROM Ninja
            WHERE Language_ID_Language IN (
                SELECT Language_ID_Language FROM MentorLanguage
					WHERE Mentor_ID_Mentor = mentor_ID
            )
            AND ID_Ninja NOT IN (					-- Check if this ninja is already on this session
                SELECT Ninja_ID_Ninja FROM Lecture
					WHERE Session_ID_Session = session_ID
            )
            LIMIT 1									-- Get 1 Ninja ONLY
        );
        
         -- If a ninja was found, then we add to the lecture table
        IF ninja_ID IS NOT NULL THEN
            CALL insert_Lecture(mentor_ID, ninja_ID, session_ID);
        END IF;
        
        -- Get next mentor
        IF last_mentor_ID IS NULL THEN
            SET mentor_ID = (SELECT MIN(ID_Mentor) FROM Mentor 
				WHERE ID_Mentor > mentor_ID);
        ELSE
            SET mentor_ID = (SELECT MIN(ID_Mentor) FROM Mentor 
				WHERE ID_Mentor > last_mentor_ID AND ID_Mentor > mentor_ID);
        END IF;
        
        -- Update last_mentor variable
        SET last_mentor_ID = mentor_ID;
    END WHILE;
    
END //

DELIMITER ;



-- -----------------------------------------------------
-- Stored Procedure "Make Lecture"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE make_Lecture()
BEGIN
    DECLARE session_ID INT;
    
    -- Get first session
    SET session_ID = (SELECT MIN(ID_Session) FROM Session);
    
    WHILE session_ID IS NOT NULL DO
        -- create a lecture for this session
        CALL make_Lecture_For_Session(session_ID);
        
        -- Get next session
        SET session_ID = (SELECT MIN(ID_Session) FROM Session WHERE ID_Session > session_ID);
    END WHILE;
    
END //

DELIMITER ;



-- -----------------------------------------------------
-- Stored Procedure "Update Belt"
-- -----------------------------------------------------
DELIMITER //
CREATE PROCEDURE update_Ninja_Belt(
    IN ninja_ID INT,
    IN belt_Color VARCHAR(50)
)
BEGIN
	DECLARE belt_ID INT;
	
    SELECT ID_Belt INTO belt_ID FROM Belt
		WHERE Color = belt_Color;
    
    UPDATE NinjaBelt
    SET Belt_ID_Belt = belt_ID
    WHERE Ninja_ID_Ninja = ninja_ID;
END//
DELIMITER ;


