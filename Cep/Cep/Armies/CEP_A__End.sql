--

--
-- Gold Costs
--

UPDATE Units
SET HurryCostModifier = 50
WHERE (Combat > 0 OR RangedCombat > 0) AND HurryCostModifier >= 0;

UPDATE Units
SET HurryCostModifier = -1
WHERE Special = 'SPECIALUNIT_PEOPLE'
AND NOT CombatClass = 'UNITCOMBAT_DIPLOMACY';

UPDATE Units
SET ExtraMaintenanceCost = 3
WHERE Cost > 0 AND (Combat = 0 AND RangedCombat = 0);

UPDATE Units
SET ExtraMaintenanceCost = Cost / 50
WHERE Cost > 0 AND (Combat > 0 OR RangedCombat > 0);

/*
UPDATE Units
SET ExtraMaintenanceCost = ExtraMaintenanceCost -
    (SELECT MAX(0, 3 - tech.GridX * 0.5) FROM Technologies tech WHERE Units.PrereqTech = tech.Type);
--*/

UPDATE Units
SET ExtraMaintenanceCost = 0.5 * ExtraMaintenanceCost
WHERE Type IN (
	SELECT UnitType FROM Civilization_UnitClassOverrides
	WHERE CivilizationType = 'CIVILIZATION_BARBARIAN'
) AND Domain = 'DOMAIN_SEA';
--*/

UPDATE Units
SET ExtraMaintenanceCost = 0.75 * ExtraMaintenanceCost
WHERE ExtraMaintenanceCost > 0 AND (
	Domain = 'DOMAIN_AIR'
	OR CombatClass = 'UNITCOMBAT_NAVALRANGED'
	OR CombatClass = 'UNITCOMBAT_NAVALMELEE'
);

UPDATE Units
SET ExtraMaintenanceCost = 0.5 * ExtraMaintenanceCost
WHERE ExtraMaintenanceCost > 0 AND (
	Class = 'UNITCLASS_GATLINGGUN'
	OR Class = 'UNITCLASS_MACHINE_GUN'
	OR Type = 'UNIT_AZTEC_JAGUAR'
	OR Type = 'UNIT_POLYNESIAN_MAORI_WARRIOR'
);

UPDATE Units SET ExtraMaintenanceCost = MAX(1, ROUND(ExtraMaintenanceCost, 0)) WHERE ExtraMaintenanceCost <> 0;

UPDATE Units SET ExtraMaintenanceCost = 0 WHERE NoMaintenance = 1;

UPDATE Units SET ExtraMaintenanceCost = 55 WHERE Class = 'UNITCLASS_ATOMIC_BOMB';
UPDATE Units SET ExtraMaintenanceCost = 90 WHERE Class = 'UNITCLASS_NUCLEAR_MISSILE';
UPDATE Units SET ExtraMaintenanceCost = 12 WHERE Class = 'UNITCLASS_GUIDED_MISSILE';

UPDATE Units SET Cost =  50, HurryCostModifier =  0 WHERE Class = 'UNITCLASS_MESSENGER';
UPDATE Units SET Cost =  75, HurryCostModifier =  25 WHERE Class = 'UNITCLASS_ENVOY';
UPDATE Units SET Cost = 100, HurryCostModifier =  50 WHERE Class = 'UNITCLASS_EMISSARY';
UPDATE Units SET Cost = 150, HurryCostModifier =  75 WHERE Class = 'UNITCLASS_DIPLOMAT';
UPDATE Units SET Cost = 200, HurryCostModifier = 100 WHERE Class = 'UNITCLASS_AMBASSADOR';


--
-- Faith Costs
--

UPDATE Units SET FaithCost = 3 * Cost WHERE FaithCost > 0 AND Cost > 0;


--
-- Conquest
--

UPDATE Buildings
SET ConquestProb = 100
WHERE HurryCostModifier != -1;

UPDATE Buildings
SET ConquestProb = 0
WHERE BuildingClass IN (
	'BUILDINGCLASS_COURTHOUSE',
	'BUILDINGCLASS_WALLS',
	'BUILDINGCLASS_CASTLE',
	'BUILDINGCLASS_ARSENAL',
	'BUILDINGCLASS_MILITARY_BASE',
	'BUILDINGCLASS_FACTORY',
	'BUILDINGCLASS_SOLAR_PLANT',
	'BUILDINGCLASS_NUCLEAR_PLANT'
);

UPDATE Buildings
SET ConquestProb = 50
WHERE BuildingClass IN (
	'BUILDINGCLASS_LIBRARY',
	'BUILDINGCLASS_COLOSSEUM',
	'BUILDINGCLASS_THEATRE',
	'BUILDINGCLASS_STADIUM',
	'BUILDINGCLASS_MARKET',
	'BUILDINGCLASS_BANK',
	'BUILDINGCLASS_STOCK_EXCHANGE',
	'BUILDINGCLASS_MINT',
	'BUILDINGCLASS_HARBOR',
	'BUILDINGCLASS_WAREHOUSE'
);

/*
--
-- Free Land Promotions
--

UPDATE Unit_FreePromotions
SET PromotionType = 'PROMOTION_CITY_ASSAULT'
WHERE PromotionType = 'PROMOTION_CITY_SIEGE';

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_CITY_SIEGE'
FROM Units WHERE Class IN (
	'UNITCLASS_SWORDSMAN',
	'UNITCLASS_LONGSWORDSMAN'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_CAMARADERIE'
FROM Units WHERE CombatClass IN (
	'UNITCOMBAT_RECON'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_DEFENSE_1'
FROM Units WHERE Class IN (
--	'UNITCLASS_SPEARMAN'			,
--	'UNITCLASS_PIKEMAN'				,
	'UNITCLASS_ANTI_TANK_GUN'		,
	'UNITCLASS_ANTI_AIRCRAFT_GUN'	,
	'UNITCLASS_MOBILE_SAM'			
) OR CombatClass IN (
	'UNITCOMBAT_RECON'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_RIVAL_TERRITORY'
FROM Units WHERE Class IN (
	'UNITCLASS_SUBMARINE'			,
	'UNITCLASS_NUCLEAR_SUBMARINE'	
);

--DELETE FROM Unit_FreePromotions WHERE UnitType = 'UNIT_HUN_BATTERING_RAM';


INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_RANGED_DEFENSE_II'
FROM Units WHERE Class IN (
	'UNITCLASS_GATLINGGUN',
	'UNITCLASS_MACHINE_GUN'
) OR CombatClass = 'UNITCOMBAT_NAVALRANGED';

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_CAN_MOVE_AFTER_ATTACKING'
FROM Units WHERE Class IN (
	'UNITCLASS_CHARIOT_ARCHER'
) AND NOT Type = 'UNIT_BARBARIAN_CHARIOT_ARCHER'
;-- OR CombatClass = 'UNITCOMBAT_NAVALMELEE';

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_FORMATION_1' AND UnitType IN
(SELECT DISTINCT Type
FROM Units WHERE Class IN (
	'UNITCLASS_LANCER'
));

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_ANTI_CAVALRY'
FROM Units WHERE Class IN (
	'UNITCLASS_LANCER'
);

UPDATE Unit_FreePromotions
SET PromotionType = 'PROMOTION_SMALL_CITY_PENALTY'
WHERE PromotionType = 'PROMOTION_CITY_PENALTY'
AND UnitType IN (
	SELECT DISTINCT Type
	FROM Units WHERE Class IN (
		'UNITCLASS_HORSEMAN',
		'UNITCLASS_KNIGHT',
		'UNITCLASS_LANCER',
		'UNITCLASS_CAVALRY'
	)
);

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_DEFENSIVE_EMBARKATION';

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_CITY_PENALTY'
AND UnitType IN (
	SELECT DISTINCT Type
	FROM Units WHERE Class IN (
		'UNITCLASS_MECH'
	)
);

UPDATE Unit_FreePromotions
SET PromotionType = 'PROMOTION_CITY_ATTACK_II'
WHERE PromotionType IN ('PROMOTION_CITY_ASSAULT', 'PROMOTION_CITY_SIEGE')
AND UnitType IN (
	SELECT DISTINCT Type
	FROM Units WHERE CombatClass = 'UNITCOMBAT_SIEGE'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_LAND_PENALTY_II'
FROM Units WHERE CombatClass = 'UNITCOMBAT_SIEGE';

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_RANGED_DEFENSE_II'
FROM Units WHERE CombatClass = 'UNITCOMBAT_SIEGE';

UPDATE Unit_FreePromotions
SET PromotionType = 'PROMOTION_ANTI_MOUNTED_NOUPGRADE_II'
WHERE PromotionType = 'PROMOTION_ANTI_MOUNTED_I'
AND UnitType IN (
	SELECT DISTINCT Type
	FROM Units WHERE Class IN (
		'UNITCLASS_SPEARMAN',
		'UNITCLASS_PIKEMAN'
	)
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_SMALL_CITY_PENALTY'
FROM Units WHERE CombatClass IN (
	'UNITCOMBAT_ARCHER',
	'UNITCOMBAT_MOUNTED_ARCHER',
	'UNITCOMBAT_ARMOR'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_CITY_SIEGE'
FROM Units WHERE Class IN (
	'UNITCLASS_MECH'
);


--
-- Free Sea Promotions
--

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_LAND_BONUS_I'
FROM Units WHERE CombatClass IN (
	'UNITCOMBAT_NAVALMELEE'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_SEA_BONUS_I'
FROM Units WHERE CombatClass IN (
	'UNITCOMBAT_NAVALMELEE'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_ATTACK_BONUS_NOUPGRADE_I'
FROM Units WHERE Class IN (
	'UNITCLASS_LANCER'				,
	'UNITCLASS_SUBMARINE'			,
	'UNITCLASS_NUCLEAR_SUBMARINE'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_DEFENSE_PENALTY'
FROM Units WHERE Class IN (
	'UNITCLASS_LANCER'				,
	'UNITCLASS_SUBMARINE'			,
	'UNITCLASS_NUCLEAR_SUBMARINE'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_CITY_ATTACK_II'
FROM Units WHERE Class IN (
	'UNITCLASS_TRIREME'				,
	'UNITCLASS_GALLEASS'			,
	'UNITCLASS_SHIP_OF_THE_LINE'	,
	'UNITCLASS_IRONCLAD'			,
	'UNITCLASS_BATTLESHIP'			,
	'UNITCLASS_MISSILE_CRUISER'		
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_ANTI_SUBMARINE_I'
FROM Units WHERE Class IN (
	'UNITCLASS_DESTROYER'			,
	'UNITCLASS_MISSILE_DESTROYER'	
);

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_ANTI_SUBMARINE_I'
AND UnitType IN (SELECT DISTINCT Type FROM Units WHERE Class IN (
	'UNITCLASS_MISSILE_CRUISER'	
));

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_ATTACK_BONUS_II'
AND UnitType IN (
	'UNIT_SUBMARINE'				,
	'UNIT_NUCLEAR_SUBMARINE'		
);

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_PRIZE_SHIPS'
AND UnitType = 'UNIT_PRIVATEER';

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_SILENT_HUNTER';

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_ONLY_DEFENSIVE'
AND UnitType IN (SELECT Type FROM Units WHERE Domain = 'DOMAIN_SEA');

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_ONLY_DEFENSIVE'
FROM Units WHERE CombatClass = 'UNITCOMBAT_NAVALRANGED';

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_ANTI_SUBMARINE_I' AND UnitType IN
(SELECT DISTINCT Type
FROM Units WHERE Class IN (
	'UNITCLASS_NUCLEAR_SUBMARINE'
));

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_CARGO_II'
FROM Units WHERE Class IN (
	'UNITCLASS_MISSILE_DESTROYER'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_OCEAN_IMPASSABLE'
FROM Units WHERE Class IN (
	'UNITCLASS_LIBURNA'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_EXTRA_SIGHT_NOUPGRADE_I'
FROM Units WHERE Class IN (
	'UNITCLASS_DESTROYER',
	'UNITCLASS_MISSILE_DESTROYER'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_SIGHT_PENALTY'
FROM Units WHERE Class IN (
	'UNITCLASS_SUBMARINE',
	'UNITCLASS_NUCLEAR_SUBMARINE'
);

--
-- Free Air Promotions
--

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_LAND_BONUS_II'
FROM Units WHERE CombatClass IN (
	'UNITCOMBAT_BOMBER'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_SEA_BONUS_II'
FROM Units WHERE CombatClass IN (
	'UNITCOMBAT_BOMBER'
);

DELETE FROM Unit_FreePromotions
WHERE PromotionType = 'PROMOTION_ANTI_AIR_II';


--
-- Promotion Classes
--

UPDATE UnitPromotions
SET Class = 'PROMOTION_CLASS_ATTRIBUTE_POSITIVE'
WHERE ((PediaType = 'PEDIA_ATTRIBUTES' AND LostWithUpgrade = 1)
	OR Type LIKE '%NOUPGRADE%'
	OR Type IN (
		'PROMOTION_CITY_SIEGE'					, -- 
		'PROMOTION_GREAT_GENERAL'				, -- leadership
		'PROMOTION_CAN_MOVE_AFTER_ATTACKING'	, -- mobile
		'PROMOTION_ANTI_HELICOPTER'				, -- fighters
		'PROMOTION_MERCENARY'					  -- landsknecht
	)
);

UPDATE UnitPromotions
SET Class = 'PROMOTION_CLASS_ATTRIBUTE_NEGATIVE'
WHERE (Type LIKE '%PENALTY%'
	OR Type IN (
		'PROMOTION_MUST_SET_UP'					,
		'PROMOTION_ROUGH_TERRAIN_ENDS_TURN'		,
		'PROMOTION_FOLIAGE_IMPASSABLE'			,
		'PROMOTION_NO_CAPTURE'					,
		'PROMOTION_ONLY_DEFENSIVE'				,
		'PROMOTION_NO_DEFENSIVE_BONUSES'
	)
);

UPDATE UnitPromotions
SET Class = 'PROMOTION_CLASS_ATTRIBUTE_POSITIVE'
WHERE PediaType = 'PEDIA_ATTRIBUTES'
AND NOT Type IN (
	'PROMOTION_INDIRECT_FIRE', 					-- earned
	'PROMOTION_CAN_MOVE_AFTER_ATTACKING',		-- not important
	'PROMOTION_IGNORE_TERRAIN_COST', 			-- minutemen
	'PROMOTION_PHALANX', 						-- hoplites
	'PROMOTION_GOLDEN', 						-- immortals	
	'PROMOTION_DESERT_POWER', 					-- barbarians
	'PROMOTION_ARCTIC_POWER', 					-- barbarians
	'PROMOTION_GUERRILLA', 						-- barbarians
	'PROMOTION_FREE_UPGRADES', 					-- citystates	
	'PROMOTION_HANDICAP', 						-- handicap
	'PROMOTION_OCEAN_MOVEMENT',					-- england
	'PROMOTION_EXTRA_MOVES_I'					-- special bonus
	)
AND NOT Type IN (
	SELECT PromotionType
	FROM Unit_FreePromotions
	WHERE UnitType IN (
		SELECT UnitType
		FROM Civilization_UnitClassOverrides
		WHERE CivilizationType != 'CIVILIZATION_BARBARIAN'
	)
);

UPDATE UnitPromotions
SET LostWithUpgrade = 0
WHERE Class = 'PROMOTION_CLASS_PERSISTANT';

UPDATE UnitPromotions
SET LostWithUpgrade = 1
WHERE Class <> 'PROMOTION_CLASS_PERSISTANT';

UPDATE UnitPromotions
SET   PortraitIndex = '58'
WHERE PortraitIndex = '59'
AND   Class = 'PROMOTION_CLASS_ATTRIBUTE_POSITIVE';

UPDATE UnitPromotions
SET   PortraitIndex = '59'
WHERE PortraitIndex = '58'
AND   Class = 'PROMOTION_CLASS_PERSISTANT'
AND NOT Type IN (
	'PROMOTION_HANDICAP' 		-- handicap
);

*/

--
-- Promotion icon order
--

-- Promotions sort from left (high priority) to right (low priority)

UPDATE UnitPromotions
SET OrderPriority = 10;

UPDATE UnitPromotions
SET OrderPriority = 100
WHERE Type IN (
	'PROMOTION_SCOUTING_1',
	'PROMOTION_SCOUTING_2',
	'PROMOTION_NAVAL_RECON_1',
	'PROMOTION_NAVAL_RECON_2'
);

UPDATE UnitPromotions
SET OrderPriority = 90
WHERE Type IN (
	'PROMOTION_SHOCK_1',
	'PROMOTION_SHOCK_2',
	'PROMOTION_SHOCK_3',
	'PROMOTION_ACCURACY_1',
	'PROMOTION_ACCURACY_2',
	'PROMOTION_ACCURACY_3',
	'PROMOTION_TRENCHES_1',
	'PROMOTION_TRENCHES_2',
	'PROMOTION_TRENCHES_3',
	'PROMOTION_TARGETING_1',
	'PROMOTION_TARGETING_2',
	'PROMOTION_TARGETING_3',
	'PROMOTION_INTERCEPTION_1',
	'PROMOTION_INTERCEPTION_2',
	'PROMOTION_INTERCEPTION_3',
	'PROMOTION_AIR_SIEGE_1',
	'PROMOTION_AIR_SIEGE_2',
	'PROMOTION_AIR_SIEGE_3'
);

UPDATE UnitPromotions
SET OrderPriority = 80
WHERE Type IN (
	'PROMOTION_DRILL_1',
	'PROMOTION_DRILL_2',
	'PROMOTION_DRILL_3',
	'PROMOTION_BARRAGE_1',
	'PROMOTION_BARRAGE_2',
	'PROMOTION_BARRAGE_3',
	'PROMOTION_GUERRILLA_1',
	'PROMOTION_GUERRILLA_2',
	'PROMOTION_GUERRILLA_3',
	'PROMOTION_BOMBARDMENT_1',
	'PROMOTION_BOMBARDMENT_2',
	'PROMOTION_BOMBARDMENT_3',
	'PROMOTION_DOGFIGHTING_1',
	'PROMOTION_DOGFIGHTING_2',
	'PROMOTION_DOGFIGHTING_3',
	'PROMOTION_AIR_TARGETING_1',
	'PROMOTION_AIR_TARGETING_2'
);

UPDATE UnitPromotions
SET OrderPriority = 70
WHERE Type IN (
	'PROMOTION_SIEGE',
	'PROMOTION_NAVAL_SIEGE',
	'PROMOTION_MEDIC',
	'PROMOTION_REPAIR',
	'PROMOTION_AIR_REPAIR',
	'PROMOTION_HELI_REPAIR',
	'PROMOTION_VOLLEY'
);

UPDATE UnitPromotions
SET OrderPriority = 60
WHERE Type IN (
	'PROMOTION_MARCH',
	'PROMOTION_MARCH_RANGED',
	'PROMOTION_MARCH_IV',
	'PROMOTION_AIR_RANGE',
	'PROMOTION_SORTIE'
);

UPDATE UnitPromotions
SET OrderPriority = 50
WHERE Type IN (
	'PROMOTION_BLITZ',
	'PROMOTION_LOGISTICS',
	'PROMOTION_AIR_LOGISTICS',
	'PROMOTION_NAVAL_LOGISTICS',
	'PROMOTION_COVER_VANGUARD_1',
	'PROMOTION_COVER_VANGUARD_2',
	'PROMOTION_AIR_AMBUSH_1',
	'PROMOTION_AIR_AMBUSH_2'
);

UPDATE UnitPromotions
SET OrderPriority = 40
WHERE Type IN (
	'PROMOTION_CHARGE',
	'PROMOTION_INDIRECT_FIRE',
	'PROMOTION_RANGE'
);

UPDATE UnitPromotions
SET OrderPriority = 30
WHERE Type IN (
	'PROMOTION_COVER_1',
	'PROMOTION_COVER_2',
	'PROMOTION_SKIRMISH',
	'PROMOTION_AMBUSH_1',
	'PROMOTION_AMBUSH_2'
);


UPDATE LoadedFile SET Value=1 WHERE Type='GEA_End.sql';