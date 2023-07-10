-- -----------------------------------------------------
-- Schema CoderDojo
-- -----------------------------------------------------

CREATE DATABASE IF NOT EXISTS `CoderDojoBraga`;
USE `CoderDojoBraga`;
CREATE SCHEMA IF NOT EXISTS `CoderDojo` DEFAULT CHARACTER SET utf8;
USE `CoderDojo`;

-- Drop tables if they exist
DROP TABLE IF EXISTS `CoderDojo`.`MentorLanguage`;
DROP TABLE IF EXISTS `CoderDojo`.`Lecture`;
DROP TABLE IF EXISTS `CoderDojo`.`Ninja`;
DROP TABLE IF EXISTS `CoderDojo`.`Belt`;
DROP TABLE IF EXISTS `CoderDojo`.`Language`;
DROP TABLE IF EXISTS `CoderDojo`.`Session`;
DROP TABLE IF EXISTS `CoderDojo`.`Mentor`;
DROP TABLE IF EXISTS `CoderDojo`.`Guardian`;
DROP TABLE IF EXISTS `CoderDojo`.`User`;
DROP TABLE IF EXISTS `CoderDojo`.`database_size`;


-- -----------------------------------------------------
-- Table `CoderDojo`.`User`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`User` (
  `ID_User` INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT UNIQUE,
  `Name` VARCHAR(255) NOT NULL,
  `Email` VARCHAR(255) NOT NULL UNIQUE,
  `Telephone` VARCHAR(15) NOT NULL UNIQUE,
  PRIMARY KEY (`ID_User`)
)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `CoderDojo`.`Language`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`Language` (
  `ID_Language` INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT UNIQUE,
  `Name` VARCHAR(50) NOT NULL UNIQUE,
  PRIMARY KEY (`ID_Language`)
)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `CoderDojo`.`Belt`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`Belt` (
	`ID_Belt` INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT UNIQUE,
    `Color` ENUM('Branco', 'Amarelo', 'Azul', 'Verde', 'Laranja', 'Vermelho', 'Roxo', 'Preto'),
    CONSTRAINT chk_Color
		CHECK(Color IN ('Branco', 'Amarelo', 'Azul', 'Verde', 'Laranja', 'Vermelho', 'Roxo', 'Preto')),
    PRIMARY KEY(`ID_Belt`)
)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `CoderDojo`.`Guardian`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`Guardian` (
  `ID_Guardian` INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT UNIQUE,
  `User_ID_User` INT UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`ID_Guardian`),
  FOREIGN KEY (`User_ID_User`) REFERENCES `User` (`ID_User`)
)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `CoderDojo`.`Mentor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`Mentor` (
  `ID_Mentor` INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT UNIQUE,
  `Degree` VARCHAR(50) NOT NULL,
  `Recruitment` TINYINT NOT NULL,
  `Registration_Date` DATETIME NOT NULL,
  `User_ID_User` INT UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`ID_Mentor`),
  FOREIGN KEY (`User_ID_User`) REFERENCES `User` (`ID_User`)
  )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `CoderDojo`.`Session`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`Session` (
  `ID_Session` INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT UNIQUE,
  `Name` VARCHAR(255) NOT NULL,
  `Begin_Date` DATETIME NOT NULL,
  `End_Date` DATETIME NOT NULL,
  `Places` INT NOT NULL,
  `Local` VARCHAR(50) NOT NULL,
  `Obs` VARCHAR(255) NULL,
  PRIMARY KEY (`ID_Session`)
  )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `CoderDojo`.`Ninja`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`Ninja` (
  `ID_Ninja` INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT UNIQUE,
  `Name` VARCHAR(255) NOT NULL,
  `Birthday` DATETIME NOT NULL,
  `Registration_Date` DATETIME NOT NULL,
  `Guardian_ID_Guardian` INT UNSIGNED ZEROFILL NOT NULL,
  `Language_ID_Language` INT UNSIGNED ZEROFILL NOT NULL,
  `Belt_ID_Belt` INT UNSIGNED ZEROFILL NOT NULL,	
  PRIMARY KEY (`ID_Ninja`),
  FOREIGN KEY (`Guardian_ID_Guardian`) REFERENCES `Guardian` (`ID_Guardian`),
  FOREIGN KEY (`Language_ID_Language`) REFERENCES `Language` (`ID_Language`),
  FOREIGN KEY (`Belt_ID_Belt`) REFERENCES `Belt` (`ID_Belt`)
)
ENGINE = InnoDB;


-- ----------------------------------------------------
-- Table `CoderDojo`.`Lecture`
-- ----------------------------------------------------
CREATE TABLE Lecture (
	`ID_Pairing` INT UNSIGNED ZEROFILL AUTO_INCREMENT NOT NULL UNIQUE,
    `Mentor_ID_Mentor` INT UNSIGNED ZEROFILL NOT NULL,
    `Session_ID_Session` INT UNSIGNED ZEROFILL NOT NULL,
    `Ninja_ID_Ninja` INT UNSIGNED ZEROFILL NOT NULL,
    PRIMARY KEY (`ID_Pairing`,`Mentor_ID_Mentor`, `Session_ID_Session`, `Ninja_ID_Ninja`),
    FOREIGN KEY (`Mentor_ID_Mentor`) REFERENCES `Mentor` (`ID_Mentor`),
    FOREIGN KEY (`Session_ID_Session`) REFERENCES `Session` (`ID_Session`),
    FOREIGN KEY (`Ninja_ID_Ninja`) REFERENCES `Ninja` (`ID_Ninja`)
);


-- ----------------------------------------------------
-- Table `CoderDojo`.`MentorLanguage`
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`MentorLanguage`(
	`Mentor_ID_Mentor` INT UNSIGNED ZEROFILL NOT NULL,
    `Language_ID_Language` INT UNSIGNED ZEROFILL NOT NULL,
    PRIMARY KEY (`Mentor_ID_Mentor`,`Language_ID_Language`),
    FOREIGN KEY (`Mentor_ID_Mentor`) REFERENCES `Mentor` (`ID_Mentor`),
    FOREIGN KEY (`Language_ID_Language`) REFERENCES `Language` (`ID_Language`),
    INDEX idx_MentorLanguages_Mentor_ID_Mentor (`Mentor_ID_Mentor`)
)
ENGINE = InnoDB;

-- ----------------------------------------------------
-- Get initial DataBase size
-- ----------------------------------------------------
SET @actual_size_MB := (
    SELECT ROUND(SUM(data_length + index_length) / (1024 * 1024), 2)
    FROM information_schema.TABLES
    WHERE table_schema = 'CoderDojo'
);
-- ----------------------------------------------------
-- Table `database_size`
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CoderDojo`.`database_size` (
  `Year` INT NOT NULL UNIQUE,
  `size_MB` DECIMAL(10, 2) NOT NULL,
  `Growth_Rate` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`Year`)
)
ENGINE = InnoDB;

-- Save initial Size
INSERT INTO `CoderDojo`.`database_size` (`Year`, `size_MB`,`Growth_Rate`) VALUES (YEAR(CURRENT_DATE), @actual_size_MB,0);

-- ----------------------------------------------------
-- Event `Growth_Rate
-- ----------------------------------------------------
DELIMITER // -- Delimitar um bloco de codigo

CREATE EVENT Growth_Rate
ON SCHEDULE EVERY 1 YEAR
DO
BEGIN
  DECLARE Previous_Year INT;
  DECLARE Previous_Size DECIMAL(10, 2);
  DECLARE Current_Size DECIMAL(10, 2);
  DECLARE Growth_Rate DECIMAL(10, 2);

  -- Get the previou year
  SET Previous_Year = YEAR(CURRENT_DATE) - 1;

  -- Get the previous year`s size
  SELECT size_MB INTO Previous_Size FROM `CoderDojo`.`database_size`
	WHERE `Year` = previous_year;

  -- Get the current year's size
  SELECT ROUND(SUM(data_length + index_length) / (1024 * 1024), 2) INTO current_size FROM information_schema.TABLES
	WHERE table_schema = 'CoderDojo';

  -- Calculate the growth rate
  SET growth_rate = (current_size - previous_size) / previous_size * 100;

  -- Insert the current year, size and growth rate into the database_size table
  INSERT INTO `CoderDojo`.`database_size` (`Year`, `size_MB`, `Growth_Rate`) VALUES (YEAR(CURRENT_DATE), current_size, growth_rate);

END;

DELIMITER ;