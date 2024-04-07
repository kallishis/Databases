DROP DATABASE cooking_competition;
CREATE DATABASE cooking_competition;
USE cooking_competition;
CREATE TABLE meal_type (
	mt_name VARCHAR(15) PRIMARY KEY
);
CREATE TABLE label (
	label_name VARCHAR(30) PRIMARY KEY
);
CREATE TABLE tip (
	tip_id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE equipment(
	eq_name VARCHAR(30) PRIMARY KEY,
    instructions VARCHAR(1000) NOT NULL
);
CREATE TABLE ingredient_group(
	ing_g_name VARCHAR(50) PRIMARY KEY,
    description VARCHAR(1000) NOT NULL
);
CREATE TABLE ingredient(
	ing_name VARCHAR(50) PRIMARY KEY,
    calories_per_100g NUMERIC(5,2) CHECK(calories_per_100g >= 0 AND calories_per_100g<=900),
    fat_per_100g NUMERIC(5,2) CHECK(fat_per_100g >= 0 AND fat_per_100g <= 100),
    protein_per_100g NUMERIC(5,2) CHECK(protein_per_100g >= 0 AND protein_per_100g <= 100),
    carbs_per_100g NUMERIC(5,2) CHECK(carbs_per_100g >= 0 AND carbs_per_100g <= 100),-- Triger if fat+protein+carbs > 100
    ing_group VARCHAR(50) NOT NULL,
    FOREIGN KEY (ing_group) REFERENCES ingredient_group(ing_g_name)
);
CREATE TABLE thematic_section(
	ts_name VARCHAR(100) PRIMARY KEY,
    description VARCHAR(1000) NOT NULL
);
CREATE TABLE step(
	step_id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(1000) NOT NULL,
    next_id INT UNIQUE,
    FOREIGN KEY (next_id) REFERENCES step(step_id)
);
CREATE TABLE national_cuisine(
	nt_name VARCHAR(30) PRIMARY KEY
);
CREATE TABLE chef(
	chef_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    age INT NOT NULL,
	years_of_expertice INT NOT NULL CHECK (years_of_expertice >= 0), -- Trigger for years_of_expertice >= age 
    professional_title VARCHAR(20) NOT NULL
);
CREATE TABLE phonebook(
	phone_number VARCHAR(20) PRIMARY KEY,
	chef_id INT NOT NULL,
	label VARCHAR(30),
	FOREIGN KEY (chef_id) REFERENCES chef(chef_id)
);
CREATE TABLE recipe(
	recipe_name VARCHAR(100) PRIMARY KEY,
    description VARCHAR(500) NOT NULL,
    difficulty INT NOT NULL CHECK(difficulty >= 1 AND difficulty <= 5),
    prep_time INT NOT NULL CHECK(prep_time >= 0),
    exec_time INT NOT NULL CHECK(exec_time >= 0),
    portions INT NOT NULL CHECK(portions > 0 ),
    calories_per_portion NUMERIC(8,2) NOT NULL CHECK (calories_per_portion >= 0),
	fat_per_portion NUMERIC(8,2) NOT NULL CHECK (fat_per_portion >= 0),
	protein_per_portion NUMERIC(8,2) NOT NULL CHECK (protein_per_portion >= 0),
	carbs_per_portion NUMERIC(8,2) NOT NULL CHECK (carbs_per_portion >= 0),
    basic_ingredient VARCHAR(50) NOT NULL,
    characterization VARCHAR(100) NOT NULL,
    first_step_id INT NOT NULL,
    national_cuisine VARCHAR(30) NOT NULL,
    FOREIGN KEY (national_cuisine) REFERENCES national_cuisine(nt_name),
    FOREIGN KEY (first_step_id) REFERENCES step(step_id),
    FOREIGN KEY (basic_ingredient) REFERENCES ingredient(ing_name)
);
CREATE TABLE episode(
	episode_id INT PRIMARY KEY,
    season INT NOT NULL CHECK (season >=1 AND season <= 5)
);
CREATE TABLE recipe_meal_type(
	rc_name VARCHAR(100) NOT NULL,
    mt_name VARCHAR(15) NOT NULL,
    PRIMARY KEY (rc_name,mt_name),
    FOREIGN KEY (rc_name) REFERENCES recipe(recipe_name),
    FOREIGN KEY (mt_name) REFERENCES meal_type(mt_name)
);
CREATE TABLE recipe_label(
	rc_name VARCHAR(100) NOT NULL,
    lb_name VARCHAR(30) NOT NULL,
    PRIMARY KEY (rc_name,lb_name),
    FOREIGN KEY (rc_name) REFERENCES recipe(recipe_name),
    FOREIGN KEY (lb_name) REFERENCES label(label_name)
);
CREATE TABLE recipe_tips(
	rc_name VARCHAR(100) NOT NULL,
    tip_id INT NOT NULL,
    PRIMARY KEY (rc_name,tip_id),
    FOREIGN KEY (rc_name) REFERENCES recipe(recipe_name),
    FOREIGN KEY (tip_id) REFERENCES tip(tip_id)
);
CREATE TABLE recipe_equipment(
	rc_name VARCHAR(100) NOT NULL,
    eq_name VARCHAR(30) NOT NULL,
    PRIMARY KEY (rc_name,eq_name),
    FOREIGN KEY (rc_name) REFERENCES recipe(recipe_name),
    FOREIGN KEY (eq_name) REFERENCES equipment(eq_name)
);
CREATE TABLE ingredients_used(
	rc_name VARCHAR(100) NOT NULL,
    ing_name VARCHAR(50) NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0),
    unit VARCHAR(20) NOT NULL,
	PRIMARY KEY (rc_name,ing_name),
    FOREIGN KEY (rc_name) REFERENCES recipe(recipe_name),
    FOREIGN KEY (ing_name) REFERENCES ingredient(ing_name)
);
CREATE TABLE recipe_thematic_section(
	rc_name VARCHAR(100) NOT NULL,
    ts_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (rc_name,ts_name),
    FOREIGN KEY (rc_name) REFERENCES recipe(recipe_name),
    FOREIGN KEY (ts_name) REFERENCES thematic_section(ts_name)
);
CREATE TABLE chef_national_cuisines(
	chef_id INT NOT NULL,
    nt_name VARCHAR(30) NOT NULL,
    PRIMARY KEY (chef_id,nt_name),
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id),
    FOREIGN KEY (nt_name) REFERENCES national_cuisine(nt_name)
);
CREATE TABLE episode_entries(
	episode_id INT NOT NULL,
    nt_name VARCHAR(30) NOT NULL,
    chef_id INT NOT NULL,
    recipe VARCHAR(100) NOT NULL,
    score1 INT NOT NULL CHECK(score1 >= 1 AND score1 <=5),
	score2 INT NOT NULL CHECK(score2 >= 1 AND score2 <=5),
	score3 INT NOT NULL CHECK(score3 >= 1 AND score3 <=5),
    avg_score DECIMAL(3,2) GENERATED ALWAYS AS ((score1 + score2 + score3) / 3.0) STORED,
    PRIMARY KEY (episode_id,nt_name),
	FOREIGN KEY (recipe) REFERENCES recipe(recipe_name),
    FOREIGN KEY (episode_id) REFERENCES episode(episode_id),
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id),
    FOREIGN KEY (nt_name) REFERENCES national_cuisine(nt_name)
);
