/******************/
/*  WardrobeDB    */
/*  Adam Bushman  */
/*  2021-12-15    */
/******************/


DROP DATABASE IF EXISTS WardrobeDB;

CREATE DATABASE WardrobeDB;

USE WardrobeDB;



/*********************/
/*  CREATING TABLES  */
/*********************/

DROP TABLE IF EXISTS wFitOccasion;

CREATE TABLE wFitOccasion (
	occasionID						TINYINT NOT NULL AUTO_INCREMENT,
    occasionName					VARCHAR(30) NOT NULL,
    
    CONSTRAINT PK_FitOccasion_OccasionId PRIMARY KEY (occasionID),
    CONSTRAINT AK_FitOccasion_OccasionName UNIQUE (occasionName)
);

DROP TABLE IF EXISTS wFit;

CREATE TABLE wFit (
	fitID							INT NOT NULL AUTO_INCREMENT,
    fitDateTime						DATETIME NOT NULL,
    occasionID						TINYINT NOT NULL,
    satisfactionRating				TINYINT DEFAULT NULL,
    
    CONSTRAINT PK_Fit_FitId PRIMARY KEY (fitID),
    CONSTRAINT FK_Fit_OccasionId FOREIGN KEY (occasionID) REFERENCES wFitOccasion (occasionID),
    CONSTRAINT AK_Fit_FitDateTime_OccasionId UNIQUE (fitDateTime, occasionID)
);

DROP TABLE IF EXISTS wItemOwner;

CREATE TABLE wItemOwner (
	ownerID							TINYINT NOT NULL AUTO_INCREMENT,
    emailAddress					VARCHAR(255) NOT NULL,
    firstName						VARCHAR(30) NOT NULL,
    lastName						VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_ItemOwner_OwnerId PRIMARY KEY (ownerID),
    CONSTRAINT AK_ItemOwner_EmailAddress UNIQUE (emailAddress)
);

DROP TABLE IF EXISTS wStatus;

CREATE TABLE wStatus (
	statusID						TINYINT NOT NULL AUTO_INCREMENT,
    statusName						VARCHAR(30) NOT NULL,
    
    CONSTRAINT PK_Status_StatusId PRIMARY KEY (statusID),
    CONSTRAINT AK_Status_StatusName UNIQUE (statusName)
);

DROP TABLE IF EXISTS wItemBrand;

CREATE TABLE wItemBrand (
	brandID							SMALLINT NOT NULL AUTO_INCREMENT,
    brandName						VARCHAR(30) NOT NULL,
    
    CONSTRAINT PK_ItemBrand_BrandId PRIMARY KEY (brandID),
    CONSTRAINT AK_ItemBrand_BrandName UNIQUE (brandName)
);

DROP TABLE IF EXISTS wItemType;

CREATE TABLE wItemType (
	typeID							TINYINT NOT NULL AUTO_INCREMENT,
    typeName						VARCHAR(30) NOT NULL,
    
    CONSTRAINT PK_ItemType_TypeId PRIMARY KEY (typeID),
    CONSTRAINT AK_ItemType_TypeName UNIQUE (typeName)
);

DROP TABLE IF EXISTS wKeyWord;

CREATE TABLE wKeyWord (
	wordID							SMALLINT NOT NULL AUTO_INCREMENT,
    word							VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_KeyWord_WordId PRIMARY KEY (wordID),
    CONSTRAINT AK_KeyWord_Word UNIQUE (word)
);

DROP TABLE IF EXISTS wMaterial;

CREATE TABLE wMaterial (
	materialID						TINYINT NOT NULL AUTO_INCREMENT,
    materialName					VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Material_MaterialId PRIMARY KEY (materialID),
    CONSTRAINT AK_Material_MaterialName UNIQUE (materialName)
);

DROP TABLE IF EXISTS wColor;

CREATE TABLE wColor (
	hexCode							CHAR(7) NOT NULL,
    commonName						VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Color_HexCode PRIMARY KEY (hexCode)
);

DROP TABLE IF EXISTS wPattern;

CREATE TABLE wPattern (
	patternID						TINYINT NOT NULL AUTO_INCREMENT,
    patternName						VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Pattern_PatternId PRIMARY KEY (patternID),
    CONSTRAINT AK_Pattern_PatternName UNIQUE (patternName)
);

DROP TABLE IF EXISTS wItem;

CREATE TABLE wItem (
	itemID							MEDIUMINT NOT NULL AUTO_INCREMENT,
    active							BOOLEAN NOT NULL DEFAULT TRUE,
    description						VARCHAR(100) NOT NULL,
    ownerID							TINYINT NOT NULL,
    brandID							SMALLINT NOT NULL,
    size							JSON DEFAULT NULL,
    itemTypeID						TINYINT NOT NULL,
    qtyOwned						TINYINT NOT NULL DEFAULT 1,
    purchaseDate					DATE DEFAULT NULL,
    cost							DECIMAL(6,2) DEFAULT NULL,
    photoFileSubPath				VARCHAR(50) DEFAULT NULL,
    
    CONSTRAINT PK_Item_ItemId PRIMARY KEY (itemID),
    CONSTRAINT FK_Item_ItemOwnerId FOREIGN KEY (ownerID) REFERENCES wItemOwner (ownerID),
    CONSTRAINT FK_Item_BrandId FOREIGN KEY (brandID) REFERENCES wItemBrand (brandID),
    CONSTRAINT FK_Item_ItemTypeId FOREIGN KEY (itemTypeID) REFERENCES wItemType (typeID)
) AUTO_INCREMENT = 101;

DROP TABLE IF EXISTS wFitItems;

CREATE TABLE wFitItems (
	itemID							MEDIUMINT NOT NULL,
    fitID							INT NOT NULL,
    
    CONSTRAINT PK_FitItems_ItemId_FitId PRIMARY KEY (itemID, fitID),
    CONSTRAINT FK_FitItems_ItemId FOREIGN KEY (itemID) REFERENCES wItem (itemID),
    CONSTRAINT FK_FitItems_FitId FOREIGN KEY (fitID) REFERENCES wFit (fitID)
);

DROP TABLE IF EXISTS wItemStatus;

CREATE TABLE wItemStatus (
    itemID							MEDIUMINT NOT NULL,
    statusID						TINYINT NOT NULL,
    
    CONSTRAINT PK_ItemStatus_ItemId_StatusId PRIMARY KEY (itemID, statusID),
    CONSTRAINT FK_ItemStatus_ItemId FOREIGN KEY (itemID) REFERENCES wItem (itemID),
    CONSTRAINT FK_ItemStatus_StatusId FOREIGN KEY (statusID) REFERENCES wStatus (statusID)
);


DROP TABLE IF EXISTS wItemKeyWords;

CREATE TABLE wItemKeyWords (
	itemID							MEDIUMINT NOT NULL,
    wordID							SMALLINT NOT NULL, 
    
    CONSTRAINT PK_ItemKeyWords_ItemId_WordId PRIMARY KEY (itemID, wordID),
    CONSTRAINT FK_ItemKeyWords_ItemId FOREIGN KEY (itemID) REFERENCES wItem (itemID),
    CONSTRAINT FK_ItemKeyWords_WordId FOREIGN KEY (wordID) REFERENCES wKeyWord (wordID)
);

DROP TABLE IF EXISTS wItemMaterials;

CREATE TABLE wItemMaterials (
	itemID							MEDIUMINT NOT NULL,
    materialID						TINYINT NOT NULL,
    materialShare					DECIMAL(3,2) NOT NULL,
    
    CONSTRAINT PK_ItemMaterials_ItemId_MaterialId PRIMARY KEY (itemID, materialID),
    CONSTRAINT FK_ItemMaterials_ItemId FOREIGN KEY (itemID) REFERENCES wItem (itemID),
    CONSTRAINT FK_ItemMaterials_MaterialId FOREIGN KEY (materialID) REFERENCES wMaterial (materialID)
    
    /* Need a constraint for the materialShare */
);

DROP TABLE IF EXISTS wItemColors;

CREATE TABLE wItemColors (
	itemID							MEDIUMINT NOT NULL,
    hexCode							CHAR(7) NOT NULL,
    colorShare						DECIMAL(3,2) NOT NULL,
    
    CONSTRAINT PK_ItemColors_ItemId_HexCode PRIMARY KEY (itemID, hexCode),
    CONSTRAINT FK_ItemColors_ItemId FOREIGN KEY (itemID) REFERENCES wItem (itemID),
    CONSTRAINT FK_ItemColors_HexCode FOREIGN KEY (hexCode) REFERENCES wColor (hexCode)
);

DROP TABLE IF EXISTS wItemPatterns;

CREATE TABLE wItemPatterns (
	itemID							MEDIUMINT NOT NULL,
    patternID						TINYINT NOT NULL,
    patternShare					DECIMAL(3,2) NOT NULL,
    
    CONSTRAINT PK_ItemPatterns_ItemId_PatternId PRIMARY KEY (itemID, patternID),
    CONSTRAINT FK_ItemPatterns_ItemId FOREIGN KEY (itemID) REFERENCES wItem (itemID),
    CONSTRAINT FK_ItemPatterns_PatternId FOREIGN KEY (patternID) REFERENCES wPattern (patternID)
);



/***************************************/
/*  CREATING DATA CONSTRAINT TRIGGERS  */
/***************************************/

DROP TRIGGER IF EXISTS DC_Color_ValidHex_Insert;

DELIMITER //
CREATE TRIGGER DC_Color_ValidHex_Insert BEFORE INSERT ON wColor
FOR EACH ROW
BEGIN
	IF (LENGTH(NEW.hexCode) != 7 OR SUBSTRING(NEW.hexCode, 1, 1) != '#') THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The hex value you are trying to add is not valid. Must contain "#" and be 7 characters long.';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS DC_Color_ValidHex_Update;

DELIMITER //
CREATE TRIGGER DC_Color_ValidHex_Update BEFORE UPDATE ON wColor
FOR EACH ROW
BEGIN
	IF (LENGTH(NEW.hexCode) != 7 OR SUBSTRING(NEW.hexCode, 1, 1) != '#') THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The hex value you are trying to update is not valid. Must contain "#" and be 7 characters long.';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS DC_Fit_SatisfactionRange_Insert;

DELIMITER //
CREATE TRIGGER DC_Fit_SatisfactionRange_Insert BEFORE INSERT ON wFit
FOR EACH ROW
BEGIN
	IF (NEW.satisfactionRating NOT IN (1,2,3,4)) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The satisfaction rating value you are trying to add is not valid. Must be a value between 1 and 4.';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS DC_Fit_SatisfactionRange_Update;

DELIMITER //
CREATE TRIGGER DC_Fit_SatisfactionRange_Update BEFORE UPDATE ON wFit
FOR EACH ROW
BEGIN
	IF (NEW.satisfactionRating NOT IN (1,2,3,4)) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The satisfaction rating value you are trying to update is not valid. Must be a value between 1 and 4.';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS DC_Owner_ValidEmail_Insert;

DELIMITER //
CREATE TRIGGER DC_Owner_ValidEmail_Insert BEFORE INSERT ON wItemOwner
FOR EACH ROW
BEGIN
	IF (NEW.emailAddress NOT REGEXP '^[^@]+@[^@]+\.[^@]{2,}$') THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The email address value you are trying to add is not valid. Must contain "@" and "." symbols.';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS DC_Owner_ValidEmail_Update;

DELIMITER //
CREATE TRIGGER DC_Owner_ValidEmail_Update BEFORE UPDATE ON wItemOwner
FOR EACH ROW
BEGIN
	IF (NEW.emailAddress NOT REGEXP '^[^@]+@[^@]+\.[^@]{2,}$') THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The email address value you are trying to update is not valid. Must contain "@" and "." symbols.';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS DC_ItemPatterns_ShareTotal_Insert;

DELIMITER //
CREATE TRIGGER DC_ItemPatterns_ShareTotal_Insert BEFORE INSERT ON wItemPatterns
FOR EACH ROW
BEGIN
	IF ((NEW.patternShare + (SELECT SUM(patternShare) FROM wItemPatterns WHERE itemID = NEW.itemID)) > 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The total pattern share for the item you are trying to add exceeds 1 (i.e. 100%).';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS DC_ItemPatterns_ShareTotal_Update;

DELIMITER //
CREATE TRIGGER DC_ItemPatterns_ShareTotal_Update BEFORE UPDATE ON wItemPatterns
FOR EACH ROW
BEGIN
	IF ((NEW.patternShare + (SELECT SUM(patternShare) FROM wItemPatterns WHERE itemID = NEW.itemID)) > 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The total pattern share for the item you are trying to update exceeds 1 (i.e. 100%).';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS DC_ItemColors_ShareTotal_Insert;

DELIMITER //
CREATE TRIGGER DC_ItemColors_ShareTotal_Insert BEFORE INSERT ON wItemColors
FOR EACH ROW
BEGIN
	IF ((NEW.colorShare + (SELECT SUM(colorShare) FROM wItemColors WHERE itemID = NEW.itemID)) > 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The total color share for the item you are trying to add exceeds 1 (i.e. 100%).';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS DC_ItemPatterns_ShareTotal_Update;

DELIMITER //
CREATE TRIGGER DC_ItemColors_ShareTotal_Update BEFORE UPDATE ON wItemColors
FOR EACH ROW
BEGIN
	IF ((NEW.colorShare + (SELECT SUM(colorShare) FROM wItemColors WHERE itemID = NEW.itemID)) > 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The total color share for the item you are trying to update exceeds 1 (i.e. 100%).';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS DC_ItemMaterials_ShareTotal_Insert;

DELIMITER //
CREATE TRIGGER DC_ItemMaterials_ShareTotal_Insert BEFORE INSERT ON wItemMaterials
FOR EACH ROW
BEGIN
	IF ((NEW.materialShare + (SELECT SUM(materialShare) FROM wItemMaterials WHERE itemID = NEW.itemID)) > 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The total material share for the item you are trying to add exceeds 1 (i.e. 100%).';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS DC_ItemMaterials_ShareTotal_Update;

DELIMITER //
CREATE TRIGGER DC_ItemMaterials_ShareTotal_Update BEFORE UPDATE ON wItemMaterials
FOR EACH ROW
BEGIN
	IF ((NEW.materialShare + (SELECT SUM(materialShare) FROM wItemMaterials WHERE itemID = NEW.itemID)) > 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The total material share for the item you are trying to update exceeds 1 (i.e. 100%).';
    END IF;
END //
DELIMITER ;



/************************/
/*  CREATING FUNCTIONS  */
/************************/

DROP FUNCTION IF EXISTS getFitId;

DELIMITER //
CREATE FUNCTION getFitId (fit_date_time VARCHAR(255), occasion VARCHAR(30))
	RETURNS INT
	BEGIN
		DECLARE ID INT;
        DECLARE date_time_of_fit DATE;
        DECLARE fit_occasion_id TINYINT;
        SET fit_occasion_id = getFitOccasionId(occasion);
        SET date_time_of_fit = CONVERT(fit_date_time, DATETIME);
        
        SELECT fitID INTO ID
        FROM wFit
        WHERE occasionID = fit_occasion_id
        AND fitDateTime = date_time_of_fit;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


DROP FUNCTION IF EXISTS getStatusId;

DELIMITER //
CREATE FUNCTION getStatusId (status_name VARCHAR(30))
	RETURNS TINYINT
	BEGIN
		DECLARE ID TINYINT;

		SELECT statusID INTO ID
        FROM wStatus
        WHERE statusName = status_name;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


DROP FUNCTION IF EXISTS getItemBrandId;

DELIMITER //
CREATE FUNCTION getItemBrandId (brand_name VARCHAR(30))
	RETURNS SMALLINT
	BEGIN
		DECLARE ID SMALLINT;
        
        SELECT brandID INTO ID
        FROM wItemBrand
        WHERE brandName = brand_name;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


DROP FUNCTION IF EXISTS getItemTypeId;

DELIMITER //
CREATE FUNCTION getItemTypeId (type_name VARCHAR(30))
	RETURNS TINYINT
	BEGIN
		DECLARE ID TINYINT;
        
        SELECT typeID INTO ID
        FROM wItemType
        WHERE typeName = type_name;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


DROP FUNCTION IF EXISTS getKeyWordId;

DELIMITER //
CREATE FUNCTION getKeyWordId (key_word VARCHAR(20))
	RETURNS SMALLINT
	BEGIN
		DECLARE ID SMALLINT;
        
        SELECT wordID INTO ID
        FROM wKeyWord
        WHERE word = key_word;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


DROP FUNCTION IF EXISTS getItemOwnerId;

DELIMITER //
CREATE FUNCTION getItemOwnerId (email_address VARCHAR(255))
	RETURNS TINYINT
	BEGIN
		DECLARE ID TINYINT;
		
        SELECT ownerID INTO ID
        FROM wItemOwner
        WHERE emailAddress = email_address;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


DROP FUNCTION IF EXISTS getMaterialId;

DELIMITER //
CREATE FUNCTION getMaterialId (material VARCHAR(50))
	RETURNS TINYINT
	BEGIN
		DECLARE ID TINYINT;
        
        SELECT materialID INTO ID
        FROM wMaterial
        WHERE materialName = material;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


DROP FUNCTION IF EXISTS getPatternId;

DELIMITER //
CREATE FUNCTION getPatternId (pattern VARCHAR(20))
	RETURNS TINYINT
	BEGIN
		DECLARE ID TINYINT;
        
        SELECT patternID INTO ID
        FROM wPattern
        WHERE patternName = pattern;
        
        IF ID IS NULL THEN
			SET ID = -1;
		END IF;
		
        RETURN ID;
	END //
DELIMITER ;


/*************************/
/*  CREATING PROCEDURES  */
/*************************/

DROP PROCEDURE IF EXISTS addPattern;

DELIMITER //
CREATE PROCEDURE addPattern (IN pattern_name VARCHAR(20))
	BEGIN        
		INSERT INTO wPattern (patternName)
        VALUES (pattern_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addColor;

DELIMITER //
CREATE PROCEDURE addColor (IN hex_code CHAR(7), common_name VARCHAR(20))
	BEGIN       
		INSERT INTO wColor (hexCode, commonName)
        VALUES (LOWER(hex_code), common_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addMaterial;

DELIMITER //
CREATE PROCEDURE addMaterial (IN mat_name VARCHAR(20))
	BEGIN        
		INSERT INTO wMaterial (materialName)
        VALUES (mat_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addKeyWord;

DELIMITER //
CREATE PROCEDURE addKeyWord (IN key_word VARCHAR(20))
	BEGIN        
		INSERT INTO wKeyWord (word)
        VALUES (key_word);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItemOwner;

DELIMITER //
CREATE PROCEDURE addItemOwner (IN email_address VARCHAR(255), IN first_name VARCHAR(30), last_name VARCHAR(50))
	BEGIN        
		INSERT INTO wItemOwner (emailAddress, firstName, lastName)
        VALUES (email_address, first_name, last_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItemType;

DELIMITER //
CREATE PROCEDURE addItemType (IN type_name VARCHAR(20))
	BEGIN        
		INSERT INTO wItemType (typeName)
        VALUES (type_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addStatus;

DELIMITER //
CREATE PROCEDURE addStatus (IN status_name VARCHAR(30))
	BEGIN        
		INSERT INTO wStatus (statusName)
        VALUES (status_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItemStatus;

DELIMITER //
CREATE PROCEDURE addItemStatus (IN item_id MEDIUMINT, status_name VARCHAR(30))
	BEGIN       
		INSERT INTO wItemStatus (itemID, statusID)
        VALUES (item_id, getStatusId(status_name));
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItemBrand;

DELIMITER //
CREATE PROCEDURE addItemBrand (IN brand_name VARCHAR(30))
	BEGIN        
		INSERT INTO wItemBrand (brandName)
        VALUES (brand_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addFitOccasion;

DELIMITER //
CREATE PROCEDURE addFitOccasion (IN occasion_name VARCHAR(20))
	BEGIN
		INSERT INTO wFitOccasion (occasionName)
        VALUES (occasion_name);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addFit;

DELIMITER //
CREATE PROCEDURE addFit (IN fit_date_time VARCHAR(255), occasion_name VARCHAR(20), satisfaction_rtg TINYINT)
	BEGIN
		DECLARE date_time DATETIME;
        SET date_time = CONVERT(fit_date_time, DATETIME);
        
		INSERT INTO wFit (fitDateTime, occasionID, satisfactionRating)
        VALUES (date_time, getFitOccasionId(occasion_name), satisfaction_rtg);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addFitItems;

DELIMITER //
CREATE PROCEDURE addFitItems (IN fit_id INT, item_id MEDIUMINT)
	BEGIN       
		INSERT INTO wFitItems (fitID, itemID)
        VALUES (fit_id, item_id);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItemColor;

DELIMITER //
CREATE PROCEDURE addItemColor (IN item_id MEDIUMINT, hex_code CHAR(7), color_share DECIMAL(3,2))
	BEGIN       
		INSERT INTO wItemColors (itemID, hexCode, colorShare)
        VALUES (item_id, hex_code, color_share);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItemPattern;

DELIMITER //
CREATE PROCEDURE addItemPattern (IN item_id MEDIUMINT, patternName VARCHAR(20), pattern_share DECIMAL(3,2))
	BEGIN       
		INSERT INTO wItemPatterns (itemID, patternID, patternShare)
        VALUES (item_id, getPatternId(patternName), pattern_share);
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItemMaterial;

DELIMITER //
CREATE PROCEDURE addItemMaterial (IN item_id MEDIUMINT, materialName VARCHAR(50), material_share DECIMAL(3,2))
	BEGIN       
		INSERT INTO wItemMaterials (itemID, materialID, materialShare)
        VALUES (item_id, getMaterialId(materialName), material_share);
	END //
DELIMITER;


DROP PROCEDURE IF EXISTS addItemKeyWord;

DELIMITER //
CREATE PROCEDURE addItemKeyWord(IN item_id MEDIUMINT, key_word VARCHAR(20))
	BEGIN       
		INSERT INTO wItemKeyWords (itemID, wordID)
        VALUES (item_id, getKeyWordId(key_word));
	END //
DELIMITER ;


DROP PROCEDURE IF EXISTS addItem;

DELIMITER //
CREATE PROCEDURE addItem (IN active_status BOOLEAN
                        , IN descrip VARCHAR(100)
                        , IN email_address VARCHAR(255)
                        , IN brand_name VARCHAR(30)
                        , IN item_size JSON
                        , IN type_name VARCHAR(30)
                        , IN quantity TINYINT
                        , IN purchase_date VARCHAR(255)
                        , IN item_cost DECIMAL(6,2)
                        , IN photo_path VARCHAR(50))
	BEGIN     
		INSERT INTO wItem (active
						 , description
                         , ownerID
                         , brandID
                         , size
                         , itemTypeID
                         , qtyOwned
                         , purchaseDate
                         , cost
                         , photoFileSubPath)
        VALUES (active_status
              , descrip
              , getItemOwnerId(email_address)
              , getItemBrandId(brand_name)
              , item_size
              , getItemTypeId(type_name)
              , quantity
              , CONVERT(purchase_date, DATE)
              , item_cost
              , photo_path);
	END //
DELIMITER ;


/********************/
/*  CREATING VIEWS  */
/********************/

DROP VIEW IF EXISTS vAllActiveItems;

CREATE VIEW vAllActiveItems AS 
	SELECT wi.itemID AS 'Item ID'
		, wi.description AS 'Clothing Item'
		, wit.typeName AS 'Type'
		, wib.brandName AS 'Brand'
		, wi.size AS 'Sizing'
		, GROUP_CONCAT(DISTINCT ic.commonName) AS 'Colors'
		, GROUP_CONCAT(DISTINCT im.materialName) AS 'Materials'
		, GROUP_CONCAT(DISTINCT ip.patternName) AS 'Patterns'
		, GROUP_CONCAT(DISTINCT st.statusName) AS 'Statuses'
		, GROUP_CONCAT(DISTINCT kw.word) AS 'Keywords'
		, CONCAT(wio.firstName, ' ', wio.lastName) AS 'Owner Name'
		, wi.qtyOwned AS 'Quantity'
		, wi.cost AS 'Item Cost'
		, wi.purchaseDate AS 'Date of Purchase'
    
	FROM wItem wi
	JOIN wItemOwner wio ON wio.ownerID = wi.ownerID
	JOIN wItemBrand wib ON wib.brandID = wi.brandID
	JOIN wItemType wit ON wit.typeID = wi.itemTypeID
	LEFT JOIN (SELECT wikw.itemID, wkw.word FROM wItemKeyWords wikw JOIN wKeyWord wkw ON wikw.wordID = wkw.wordID) kw ON kw.itemID = wi.itemID
	LEFT JOIN (SELECT wis.itemID, ws.statusName FROM wItemStatus wis JOIN wStatus ws ON wis.statusID = ws.statusID) st ON st.itemID = wi.itemID
	LEFT JOIN (SELECT wic.itemID, wc.commonName FROM wItemColors wic JOIN wColor wc ON wic.hexCode = wc.hexCode) ic ON ic.itemID = wi.itemID
	LEFT JOIN (SELECT wim.itemID, wm.materialName FROM wItemMaterials wim JOIN wMaterial wm ON wim.materialID = wm.materialID) im ON im.itemID = wi.itemID
	LEFT JOIN (SELECT wip.itemID, wp.patternName FROM wItemPatterns wip JOIN wPattern wp ON wip.patternID = wp.patternID) ip ON ip.itemID = wi.itemID

	WHERE wi.active = 1

	GROUP BY 1, 2, 3, 4, 5, 11, 12, 13, 14;
    

DROP VIEW IF EXISTS vAllFits;

CREATE VIEW vAllFits AS 
	SELECT oc.fitID AS 'Fit ID'
		, oc.fitDateTime AS 'Fit Date/Time'
		, oc.occasionName AS 'Occassion'
		, GROUP_CONCAT(DISTINCT wi.description) AS 'Clothing Items'
		, satisfactionRating AS 'Satisfaction Rating'
    
	FROM wFitItems wfi
	JOIN wItem wi ON wi.itemID = wfi.itemID
	JOIN (SELECT wf.fitID, wf.fitDateTime, wfo.occasionName, wf.satisfactionRating FROM wFit wf JOIN wFitOccasion wfo ON wf.occasionID = wfo.occasionID) oc ON oc.fitID = wfi.fitID

	GROUP BY 1, 2, 3, 5;
    
    
DROP VIEW IF EXISTS vAllItemColors;

CREATE VIEW vAllItemColors AS 
	SELECT c.hexCode
		, c.commonName
        , SUM(i.colorShare) AS 'totalShare'

	FROM wItemColors i 
	JOIN wColor c ON c.hexCode = i.hexCode 
    JOIN wItem wi ON i.itemID = wi.itemID
    
    WHERE wi.active = 1

	GROUP BY c.hexCode, c.commonName 
	ORDER BY c.commonName, c.hexCode;
    

DROP VIEW IF EXISTS vAllFitColors;

CREATE VIEW vAllFitColors AS 
	SELECT DATE_FORMAT(wf.fitDateTime, '%Y-%m-%d') AS fitDate, ic.hexCode, ic.commonName, SUM(ic.colorShare) AS 'totalShare'

	FROM wFitItems wfi
	LEFT JOIN (
		SELECT wi.itemID, wic.hexCode, wc.commonName, wic.colorShare
		FROM wItemColors wic 
		JOIN wItem wi ON wi.itemID = wic.itemID
		JOIN wColor wc ON wc.hexCode = wic.hexCode
		) ic ON ic.itemID = wfi.itemID
	LEFT JOIN wFit wf ON wf.fitID = wfi.fitID
		
	GROUP BY wf.fitDateTime, ic.hexCode, ic.commonName
	ORDER BY ic.commonName, ic.hexCode;

SHOW TABLES;
