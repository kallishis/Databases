DROP DATABASE cooking_competition;

CREATE DATABASE cooking_competition;
USE cooking_competition;
CREATE TABLE meal_type (
	mt_name VARCHAR(50) PRIMARY KEY
);
CREATE TABLE label (
	label_name VARCHAR(30) PRIMARY KEY
);
CREATE TABLE tip (
	tip_id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(600) UNIQUE NOT NULL
);
CREATE TABLE equipment(
	eq_id INT AUTO_INCREMENT PRIMARY KEY,
	eq_name VARCHAR(100) ,
    instructions VARCHAR(1000) NOT NULL
);
CREATE TABLE ingredient_group(
	ing_g_name VARCHAR(50) PRIMARY KEY,
    description VARCHAR(1000) NOT NULL,
    characterization VARCHAR(100) NOT NULL
);
CREATE TABLE ingredient(
	ing_id INT AUTO_INCREMENT PRIMARY KEY,
	ing_name VARCHAR(50),
    calories_per_100g NUMERIC(5,2) CHECK(calories_per_100g >= 0 AND calories_per_100g<=900),
    fat_per_100g NUMERIC(5,2) CHECK(fat_per_100g >= 0 AND fat_per_100g <= 100),
    protein_per_100g NUMERIC(5,2) CHECK(protein_per_100g >= 0 AND protein_per_100g <= 100),
    carbs_per_100g NUMERIC(5,2) CHECK(carbs_per_100g >= 0 AND carbs_per_100g <= 100),-- Triger if fat+protein+carbs > 100
    ing_group VARCHAR(50) NOT NULL,
    FOREIGN KEY (ing_group) REFERENCES ingredient_group(ing_g_name) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT sum_of_macros CHECK (fat_per_100g+protein_per_100g+carbs_per_100g <= 100)
);
CREATE TABLE thematic_section(
	ts_name VARCHAR(100) PRIMARY KEY,
    description VARCHAR(1000) NOT NULL
);
CREATE TABLE national_cuisine(
	nt_name VARCHAR(30) PRIMARY KEY
);
CREATE TABLE users(
	username VARCHAR(20) PRIMARY KEY,
    password VARCHAR(20) NOT NULL,
    user_type VARCHAR(10) NOT NULL,
    CONSTRAINT password_length CHECK (LENGTH(password) BETWEEN 7 AND 21),
    CONSTRAINT user_type_accepted_values CHECK (user_type in ('admin','chef'))
);
CREATE TABLE chef(
	chef_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    username VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    age INT NOT NULL,
	years_of_expertice INT NOT NULL CHECK (years_of_expertice >= 0), -- Trigger for years_of_expertice >= age 
    professional_title VARCHAR(20) NOT NULL,
    FOREIGN KEY (username) REFERENCES users(username) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE admin(
	admin_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
	username VARCHAR(20) NOT NULL, 
    FOREIGN KEY (username) REFERENCES users(username) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE phonebook(
	phone_number VARCHAR(20) PRIMARY KEY,
	chef_id INT NOT NULL,
	label VARCHAR(30),
	FOREIGN KEY (chef_id) REFERENCES chef(chef_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE unit_of_measure(
	u_o_m_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    conversion_rate NUMERIC(8,2) NOT NULL CHECK (conversion_rate >= 0)
);
CREATE TABLE recipe(
	recipe_id INT AUTO_INCREMENT PRIMARY KEY,
	recipe_name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    recipe_type VARCHAR(20) NOT NULL,
    difficulty INT NOT NULL CHECK(difficulty >= 1 AND difficulty <= 5),
    prep_time INT NOT NULL CHECK(prep_time >= 0),
    exec_time INT NOT NULL CHECK(exec_time >= 0),
	basic_ingredient INT NOT NULL,
    characterization VARCHAR(100) ,
    national_cuisine VARCHAR(30) NOT NULL,
    portions INT NOT NULL CHECK(portions > 0 ) DEFAULT 0,
    calories_per_portion NUMERIC(8,2) NOT NULL CHECK (calories_per_portion >= 0) DEFAULT 0,
	fat_per_portion NUMERIC(8,2) NOT NULL CHECK (fat_per_portion >= 0) DEFAULT 0,
	protein_per_portion NUMERIC(8,2) NOT NULL CHECK (protein_per_portion >= 0) DEFAULT 0,
	carbs_per_portion NUMERIC(8,2) NOT NULL CHECK (carbs_per_portion >= 0) DEFAULT 0,
    FOREIGN KEY (national_cuisine) REFERENCES national_cuisine(nt_name) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (basic_ingredient) REFERENCES ingredient(ing_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT recipe_type_values CHECK (recipe_type in ('savory','confectionery'))
);
CREATE TABLE step(
	step_id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(1000) NOT NULL,
    step_order INT NOT NULL,
    recipe_id INT NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE recipe_meal_type(
	rc_id INT NOT NULL,
    mt_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (rc_id,mt_name),
    FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (mt_name) REFERENCES meal_type(mt_name) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE recipe_label(
	rc_id INT  NOT NULL,
    lb_name VARCHAR(30) NOT NULL,
    PRIMARY KEY (rc_id,lb_name),
    FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (lb_name) REFERENCES label(label_name) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE recipe_tips(
	rc_id INT NOT NULL,
    tip_id INT NOT NULL,
    PRIMARY KEY (rc_id,tip_id),
	FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (tip_id) REFERENCES tip(tip_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE equipment_used(
	rc_id INT NOT NULL,
    eq_id INT NOT NULL,
    PRIMARY KEY (rc_id,eq_id),
    FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (eq_id) REFERENCES equipment(eq_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE ingredients_used(
	rc_id INT NOT NULL,
    ing_id INT NOT NULL,
    amount NUMERIC(10,4) NOT NULL CHECK(amount > 0),
    unit INT NOT NULL,
	PRIMARY KEY (rc_id,ing_id),
    FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (unit) REFERENCES unit_of_measure(u_o_m_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ing_id) REFERENCES ingredient(ing_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE recipe_thematic_section(
	rc_id INT NOT NULL,
    ts_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (rc_id,ts_name),
    FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ts_name) REFERENCES thematic_section(ts_name) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE chef_national_cuisines(
	chef_id INT NOT NULL,
    nt_name VARCHAR(30) NOT NULL,
    PRIMARY KEY (chef_id,nt_name),
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nt_name) REFERENCES national_cuisine(nt_name) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE chef_recipe(
	chef_id INT NOT NULL,
    rc_id INT NOT NULL,
	PRIMARY KEY (chef_id,rc_id),
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE episode(
	episode_id INT NOT NULL,
    season_id INT NOT NULL,
    PRIMARY KEY (episode_id,season_id)
);
CREATE TABLE episode_entries(
    entry_id INT AUTO_INCREMENT PRIMARY KEY,
    episode_id INT NOT NULL,
    season_id INT NOT NULL,
    nt_name VARCHAR(30) NOT NULL,
    chef_id INT NOT NULL,
    rc_id INT NOT NULL,
    score1 INT NOT NULL CHECK(score1 >= 1 AND score1 <=5),
	score2 INT NOT NULL CHECK(score2 >= 1 AND score2 <=5),
	score3 INT NOT NULL CHECK(score3 >= 1 AND score3 <=5),
    total_score INT GENERATED ALWAYS AS (score1 + score2 + score3) STORED,
    FOREIGN KEY (episode_id,season_id) REFERENCES episode(episode_id,season_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (rc_id) REFERENCES recipe(recipe_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nt_name) REFERENCES national_cuisine(nt_name) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE judges(
	episode_id INT NOT NULL,
    season_id INT NOT NULL,
    first_judge_id INT NOT NULL,
    second_judge_id INT NOT NULL,
    third_judge_id INT NOT NULL,
    PRIMARY KEY (episode_id,season_id),
    FOREIGN KEY (episode_id,season_id) REFERENCES episode(episode_id,season_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (first_judge_id) REFERENCES chef(chef_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (second_judge_id) REFERENCES chef(chef_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (third_judge_id) REFERENCES chef(chef_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DELIMITER //
CREATE PROCEDURE update_recipe_nutritional_info_after_insert( IN rc_id INT, IN ing_id INT, IN amount NUMERIC(10,4), IN unit INT )
BEGIN
    DECLARE calories NUMERIC(8,2);
    DECLARE fat NUMERIC(8,2);
    DECLARE carbs NUMERIC(8,2);
    DECLARE protein NUMERIC(8,2);
    
    -- Calculate the nutritional values of the ingredient based on its amount and unit
    SELECT 
        (amount * ing.calories_per_100g * uom.conversion_rate / 100),
        (amount * ing.fat_per_100g * uom.conversion_rate / 100),
        (amount * ing.carbs_per_100g * uom.conversion_rate / 100),
        (amount * ing.protein_per_100g * uom.conversion_rate / 100)
    INTO 
        calories, fat, carbs, protein
    FROM 
        ingredient ing
    JOIN 
        unit_of_measure uom ON uom.u_o_m_id = unit
    WHERE 
        ing.ing_id = ing_id;
    
    -- Update the recipe table with the new nutritional values
    UPDATE recipe 
    SET 
        calories_per_portion = calories_per_portion + calories/portions,
        fat_per_portion = fat_per_portion + fat/portions,
        carbs_per_portion = carbs_per_portion + carbs/portions,
        protein_per_portion = protein_per_portion + protein/portions
    WHERE 
        recipe_id = rc_id;
END;
//
CREATE PROCEDURE update_recipe_nutritional_info_after_delete( IN rc_id INT, IN ing_id INT, IN amount NUMERIC(10,4), IN unit INT)
BEGIN
    DECLARE calories NUMERIC(8,2);
    DECLARE fat NUMERIC(8,2);
    DECLARE carbs NUMERIC(8,2);
    DECLARE protein NUMERIC(8,2);
    
    -- Calculate the nutritional values of the ingredient based on its amount and unit
    SELECT 
        (amount * ing.calories_per_100g * uom.conversion_rate / 100),
        (amount * ing.fat_per_100g * uom.conversion_rate / 100),
        (amount * ing.carbs_per_100g * uom.conversion_rate / 100),
        (amount * ing.protein_per_100g * uom.conversion_rate / 100)
    INTO 
        calories, fat, carbs, protein
    FROM 
        ingredient ing
    JOIN 
        unit_of_measure uom ON uom.u_o_m_id = unit
    WHERE 
        ing.ing_id = ing_id;
    
    -- Update the recipe table by subtracting the nutritional values of the deleted ingredient
    UPDATE recipe 
    SET 
        calories_per_portion = calories_per_portion - calories/portions,
        fat_per_portion = fat_per_portion - fat/portions,
        carbs_per_portion = carbs_per_portion - carbs/portions,
        protein_per_portion = protein_per_portion - protein/portions
    WHERE 
        recipe_id = rc_id;
END;
//
CREATE TRIGGER update_nutritional_info_after_insert_t AFTER INSERT ON ingredients_used
FOR EACH ROW
BEGIN
    CALL update_recipe_nutritional_info_after_insert(NEW.rc_id, NEW.ing_id, NEW.amount, NEW.unit);
END;
//
CREATE TRIGGER update_nutritional_info_after_delete_t AFTER DELETE ON ingredients_used
FOR EACH ROW
BEGIN
	CALL update_recipe_nutritional_info_after_delete(OLD.rc_id, OLD.ing_id, OLD.amount, OLD.unit);
END;
//
CREATE TRIGGER update_nutritional_info_after_update_t AFTER UPDATE ON ingredients_used
FOR EACH ROW
BEGIN
	CALL update_recipe_nutritional_info_after_delete(OLD.rc_id, OLD.ing_id, OLD.amount, OLD.unit);
    CALL update_recipe_nutritional_info_after_insert(NEW.rc_id, NEW.ing_id, NEW.amount, NEW.unit);
END;
//
CREATE TRIGGER autocharacterization BEFORE INSERT ON recipe
FOR EACH ROW
BEGIN
    DECLARE rec_character VARCHAR(100);
    SELECT characterization INTO rec_character
    FROM ingredient
    INNER JOIN ingredient_group ON ingredient.ing_group = ingredient_group.ing_g_name
    WHERE ing_id = NEW.basic_ingredient;
    
    SET NEW.characterization = rec_character;
END;
//
CREATE TRIGGER consecutive_episodes_check BEFORE INSERT ON episode_entries
FOR EACH ROW
BEGIN

    -- Check if the chef has participated in the last three episodes
    IF EXISTS (
           SELECT 1
           FROM episode_entries
           WHERE chef_id = NEW.chef_id AND season_id = NEW.season_id AND episode_id IN (new.episode_id, new.episode_id - 1, new.episode_id - 2)
           GROUP BY chef_id, season_id
           HAVING COUNT(*) >= 3
       ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chef cannot compete in more than 3 consecutive episodes in the same season.';
    END IF;
    
    -- Check if the recipe has participated in the last three episodes
    IF EXISTS (
           SELECT 1
           FROM episode_entries
           WHERE rc_id = NEW.rc_id AND season_id = NEW.season_id AND episode_id IN (new.episode_id, new.episode_id - 1, new.episode_id - 2)
           GROUP BY rc_id, season_id
           HAVING COUNT(*) >= 3
       ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recipe cannot compete in more than 3 consecutive episodes in the same season.';
    END IF;
    
    -- Check if the national cuisine has participated in the last three episodes
    IF EXISTS (
           SELECT 1
           FROM episode_entries
           WHERE nt_name = NEW.nt_name AND season_id = NEW.season_id AND episode_id IN (new.episode_id, new.episode_id - 1, new.episode_id - 2)
           GROUP BY nt_name, season_id
           HAVING COUNT(*) >= 3
       ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A national cuisine cannot compete in more than 3 consecutive episodes in the same season.';
    END IF;
END//

CREATE TRIGGER check_tip_recipe_limit
BEFORE INSERT ON recipe_tips
FOR EACH ROW
BEGIN
    DECLARE tip_count INT;

    -- Count the current number of tips for the recipe
    SELECT COUNT(*)
    INTO tip_count
    FROM recipe_tips
    WHERE rc_id = NEW.rc_id;

    -- Check if the number of tips exceeds the limit
    IF tip_count >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A recipe cannot have more than 3 tips.';
    END IF;
END//

DELIMITER ;
