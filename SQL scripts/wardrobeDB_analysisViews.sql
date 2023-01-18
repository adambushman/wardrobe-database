USE WardrobeDB;

DROP VIEW IF EXISTS vWardrobeKeywordFreq;

CREATE VIEW vWardrobeKeywordFreq AS 
	SELECT
		wi.itemID, ROUND(AVG(wf.frequency), 1) AS avg_word_freq 
	FROM (
		-- All words for each item
		SELECT i.itemID, i.description, k.wordID
		FROM wItemKeywords ik
		LEFT JOIN wItem i ON i.itemID = ik.itemId
		LEFT JOIN wKeyword k ON k.wordID = ik.wordId
		ORDER BY i.itemID
	) AS wi
	LEFT JOIN (
		-- Word frequency
		SELECT 
			k.wordId, 
			COALESCE(w.freq, 0) AS frequency
		FROM wKeyword k
		LEFT JOIN (
			SELECT ik.wordId, COUNT(*) AS freq
			FROM wFitItems fi
			INNER JOIN wItemKeywords ik ON ik.itemId = fi.itemId
			INNER JOIN wFit f ON f.fitID = fi.fitId
			WHERE f.fitDateTime >= (NOW() - INTERVAL 90 DAY)
			GROUP BY ik.wordId
		) w ON w.wordId = k.wordID
	) AS wf ON wf.wordId = wi.wordId 
	GROUP BY 
		wi.itemID, wi.description
	ORDER BY 
		AVG(wf.frequency) DESC;


DROP VIEW IF EXISTS vWardrobeColorFreq;

CREATE VIEW vWardrobeColorFreq AS 
	SELECT
		wi.itemID, wi.description, 
		ROUND(AVG(wf.frequency), 1) AS avg_col_freq 
	FROM (
		SELECT i.itemID, i.description, ic.hexCode
		FROM wItemColors ic
		LEFT JOIN wItem i ON i.itemID = ic.itemId
		ORDER BY i.itemID
	) AS wi
	LEFT JOIN (
		SELECT 
			k.hexCode, COALESCE(c.freq, 0) AS frequency
		FROM wColor k
		LEFT JOIN (
			SELECT ic.hexCode, COUNT(*) AS freq
			FROM wFitItems fi
			INNER JOIN wItemColors ic ON ic.itemId = fi.itemId
			INNER JOIN wFit f ON f.fitID = fi.fitId
			WHERE f.fitDateTime >= (NOW() - INTERVAL 90 DAY)
			GROUP BY ic.hexCode
		) c ON c.hexCode = k.hexCode
	) AS wf ON wf.hexCode = wi.hexCode
	GROUP BY wi.itemID, wi.description
	ORDER BY AVG(wf.frequency) DESC;


DROP VIEW IF EXISTS vWardrobePatternFreq;

CREATE VIEW vWardrobePatternFreq AS 
	SELECT
		wi.itemID, wi.description, 
		ROUND(AVG(wf.frequency), 1) AS avg_pat_freq 
	FROM (
		SELECT i.itemID, i.description, ip.patternId
		FROM wItemPatterns ip
		LEFT JOIN wItem i ON i.itemID = ip.itemId
		ORDER BY i.itemID
	) AS wi
	LEFT JOIN (
		SELECT 
			k.patternId, 
			COALESCE(p.freq, 0) AS frequency
		FROM wPattern k
		LEFT JOIN (
			SELECT ip.patternId, COUNT(*) AS freq
			FROM wFitItems fi
			INNER JOIN wItemPatterns ip ON ip.itemId = fi.itemId
			INNER JOIN wFit f ON f.fitID = fi.fitId
			WHERE f.fitDateTime >= (NOW() - INTERVAL 90 DAY)
			GROUP BY ip.patternId
		) p ON p.patternId = k.patternId
	) AS wf ON wf.patternId = wi.patternID
	GROUP BY wi.itemID, wi.description
	ORDER BY AVG(wf.frequency) DESC;
    

DROP VIEW IF EXISTS vWardrobeMaterialFreq;

CREATE VIEW vWardrobeMaterialFreq AS 
	SELECT
		wi.itemID, wi.description, 
		ROUND(AVG(wf.frequency), 1) AS avg_mat_freq 
	FROM (
		SELECT i.itemID, i.description, im.materialId
		FROM wItemMaterials im
		LEFT JOIN wItem i ON i.itemID = im.itemId
		ORDER BY i.itemID
	) AS wi
	LEFT JOIN (
		SELECT 
			k.materialId, 
			COALESCE(m.freq, 0) AS frequency
		FROM wMaterial k
		LEFT JOIN (
			SELECT im.materialId, COUNT(*) AS freq
			FROM wFitItems fi
			INNER JOIN wItemMaterials im ON im.itemId = fi.itemId
			INNER JOIN wFit f ON f.fitID = fi.fitId
			WHERE f.fitDateTime >= (NOW() - INTERVAL 90 DAY)
			GROUP BY im.materialID
		) m ON m.materialId = k.materialId
	) AS wf ON wf.materialId = wi.materialId
	GROUP BY wi.itemID, wi.description
	ORDER BY AVG(wf.frequency) DESC;


DROP VIEW IF EXISTS vWardrobeBrandFreq;

CREATE VIEW vWardrobeBrandFreq AS 
SELECT
	wi.itemID, wi.description, 
    ROUND(AVG(wf.frequency), 1) AS avg_brand_freq 
FROM (
	SELECT i.itemID, i.description, ib.brandId
	FROM wItemBrand ib
	LEFT JOIN wItem i ON i.brandId = ib.brandId
	ORDER BY i.itemID
) AS wi
LEFT JOIN (
	SELECT 
		k.brandId, 
		COALESCE(b.freq, 0) AS frequency
	FROM wItemBrand k
	LEFT JOIN (
		SELECT ib.brandId, COUNT(*) AS freq
		FROM (
			SELECT f.*, i.brandId
            FROM wFitItems f
            LEFT JOIN wItem i ON i.itemID = f.itemId
        ) fi
		INNER JOIN wItemBrand ib ON ib.brandID = fi.brandId
        INNER JOIN wFit f ON f.fitID = fi.fitId
        WHERE f.fitDateTime >= (NOW() - INTERVAL 90 DAY)
		GROUP BY ib.brandId
	) b ON b.brandId = k.brandId
) AS wf ON wf.brandId = wi.brandId
GROUP BY wi.itemID, wi.description
ORDER BY AVG(wf.frequency) DESC;


DROP VIEW IF EXISTS vWardrobeTypeFreq;

CREATE VIEW vWardrobeTypeFreq AS 
	SELECT
		i.itemID, i.description, 
		COALESCE(wi.raw_freq - wf.cat_freq, 0) AS rel_freq
	FROM (
		SELECT *
		FROM wItem
	) AS i
	LEFT JOIN (
		SELECT i.itemID, COUNT(*) AS raw_freq
		FROM wFitItems f
		LEFT JOIN wItem i ON i.itemID = f.itemId
		GROUP BY i.itemID
	) AS wi ON wi.itemID = i.itemID
	LEFT JOIN (
		SELECT 
			k.typeId, 
			COALESCE(t.freq, 0) AS cat_freq
		FROM wItemType k
		LEFT JOIN (
			SELECT it.typeId, COUNT(fi.fitId) / COUNT(DISTINCT fi.itemId) AS freq
			FROM (
				SELECT f.*, i.itemTypeId AS typeId
				FROM wFitItems f
				LEFT JOIN wItem i ON i.itemID = f.itemId
			) fi
			INNER JOIN wFit f ON f.fitID = fi.fitId
			INNER JOIN wItemType it ON it.typeID = fi.typeId
			WHERE f.fitDateTime >= (NOW() - INTERVAL 90 DAY)
			GROUP BY it.typeId
		) t ON t.typeId = k.typeId
	) AS wf ON wf.typeId = i.itemTypeId
	ORDER BY COALESCE(wi.raw_freq - wf.cat_freq, 0) DESC;


DROP VIEW IF EXISTS vWardrobeEval;

CREATE VIEW vWardrobeEval AS 
	SELECT
		i.`Item ID`, i.`Clothing Item`, i.`Type`, 
		COALESCE(ai.freq, 0) AS raw_freq, 
		(COALESCE(t.rel_freq, (SELECT AVG(rel_freq) FROM vWardrobeTypeFreq)) + 
		COALESCE(k.avg_word_freq, (SELECT AVG(avg_word_freq) FROM vWardrobeKeywordFreq)) + 
		COALESCE(c.avg_col_freq, (SELECT AVG(avg_col_freq) FROM vWardrobeColorFreq)) + 
		COALESCE(p.avg_pat_freq, (SELECT AVG(avg_pat_freq) FROM vWardrobePatternFreq)) + 
		COALESCE(m.avg_mat_freq, (SELECT AVG(avg_mat_freq) FROM vWardrobeMaterialFreq)) + 
		COALESCE(b.avg_brand_freq, (SELECT AVG(avg_brand_freq) FROM vWardrobeBrandFreq))) / 6 AS overall_freq
	FROM
		vAllActiveItems AS i
	LEFT JOIN (
		SELECT wfi.itemId, COUNT(*) AS freq
		FROM wFitItems wfi
		LEFT JOIN wFit wf ON wf.fitID = wfi.fitID
		WHERE wf.fitDateTime >= DATE(now() - INTERVAL 90 DAY)
		GROUP BY wfi.itemId
		ORDER BY COUNT(*) DESC
	) ai ON ai.itemId = i.`Item ID`
	LEFT JOIN 
		vWardrobeTypeFreq t ON t.itemID = i.`Item ID`
	LEFT JOIN 
		vWardrobeKeywordFreq k ON k.itemID = i.`Item ID`
	LEFT JOIN 
		vWardrobeColorFreq c ON c.itemID = i.`Item ID`
	LEFT JOIN 
		vWardrobePatternFreq p ON p.itemID = i.`Item ID`
	LEFT JOIN 
		vWardrobeMaterialFreq m ON m.itemID = i.`Item ID`
	LEFT JOIN 
		vWardrobeBrandFreq b ON b.itemID = i.`Item ID`
	ORDER BY
		(COALESCE(t.rel_freq, (SELECT AVG(rel_freq) FROM vWardrobeTypeFreq)) + 
		COALESCE(k.avg_word_freq, (SELECT AVG(avg_word_freq) FROM vWardrobeKeywordFreq)) + 
		COALESCE(c.avg_col_freq, (SELECT AVG(avg_col_freq) FROM vWardrobeColorFreq)) + 
		COALESCE(p.avg_pat_freq, (SELECT AVG(avg_pat_freq) FROM vWardrobePatternFreq)) + 
		COALESCE(m.avg_mat_freq, (SELECT AVG(avg_mat_freq) FROM vWardrobeMaterialFreq)) + 
		COALESCE(b.avg_brand_freq, (SELECT AVG(avg_brand_freq) FROM vWardrobeBrandFreq))) / 6 DESC;