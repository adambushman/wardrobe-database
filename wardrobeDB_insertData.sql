USE WardrobeDB;

/****************************/
/* Populating Clothing Item */
/****************************/

-- Step 1: Add Owner (if not already present in DB)
CALL addItemOwner('hello@me.com', 'Adam', 'Bushman');

-- Step 2: Add Clothing Item Type (if not already present in DB)
CALL addItemType('Blazer');

-- Step 3: Add Clothing Brand (if not already present in DB)
CALL addItemBrand('Arctic Cool');

-- Step 4: Add Clothing Item (if not already present in DB)
CALL addItem (
		  TRUE
        , 'Gray Cooling Shirt'
        , 'adam.bushman1@gmail.com'
        , 'Arctic Cool'
        , '{ "main": "Large" }'
        , 'Shirts'
        , 1
        , NULL
        , NULL
        , NULL);

-- Step 5: Add Clothing Status (if not already present in DB)
CALL addStatus('Damaged');

-- Step 6: Add Multiple Statuses for the Item (if not already present in DB)
CALL addItemStatus(205, 'Damaged');
CALL addItemStatus(205, 'Stained');

-- Step 7: Add Colors (if not already present in DB)
CALL addColor('#a10025', 'Red');
CALL addColor('#595a5f', 'Gray');

-- Step 8: Add Multiple Colors for the Item (if not already present in DB)
CALL addItemColor(205, '#595a5f', 0.85);
CALL addItemColor(205, '#a10025', 0.15);

-- Step 9: Add Materials (if not already present in DB)
CALL addMaterial('Polyester');
CALL addMaterial('Cotton');

-- Step 10: Add Multiple Materials for the Item (if not already present in DB)
CALL addItemMaterial(205, 'Cotton', 0.65);
CALL addItemMaterial(205, 'Polyester', 0.35);

-- Step 11: Add Patterns (if not already present in DB)
CALL addPattern('Textured');

-- Step 12: Add Multiple Patterns for the Item (if not already present in DB)
CALL addItemPattern(205, 'Textured', 1);

-- Step 13: Add KeyWords (if not already present in DB)
CALL addKeyWord('casual');
CALL addKeyWord('comfy');
CALL addKeyWord('t-shirt');

-- Step 14: Add Multiple KeyWords for the Item (if not already present in DB)
CALL addItemKeyWord(205, 'casual');
CALL addItemKeyWord(205, 'comfy');
CALL addItemKeyWord(205, 't-shirt');


/******************/
/* Populating Fit */
/******************/

-- Step 1: Add Occasions (if not already present in DB)
CALL addFitOccasion('Everyday');
CALL addFitOccasion('Party');
CALL addFitOccasion('Church');

-- Step 2: Add Fit for Items (if not already present in DB)
CALL addFit('2022-05-22 11:30:00', 'Everyday', 4);

-- Step 3: Add Fit for Items (if not already present in DB)
CALL addFitItems(12, 205);
CALL addFitItems(12, 205);
