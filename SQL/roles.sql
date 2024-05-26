DELIMITER //
-- Procedure to update chef information
CREATE PROCEDURE update_chef_info(IN id INT, IN new_name VARCHAR(50),  IN new_surname VARCHAR(50), IN new_date_of_birth date, IN new_age INT,IN new_years_of_expertice INT,IN new_professional_title VARCHAR(20), IN new_img_id INT)
BEGIN
    IF (id = CURRENT_USER_ID()) THEN
        UPDATE chef SET name = new_name, surname = new_surname, _date_of_birth = new_date_of_birth, age = new_age,
        years_of_expertice = new_years_of_expertice, professional_title = new_professional_title, img_id = new_img_id WHERE id = chef_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission denied';
    END IF;
END //


-- Procedure to update a recipe
CREATE PROCEDURE update_recipe(IN recip_id INT, IN c_id INT, IN new_name VARCHAR(100), IN new_description VARCHAR(500),  IN new_recipe_type VARCHAR(20), IN new_difficulty INT, IN new_ INT,
IN new_exec_time INT, IN new_basic_ingredient INT,IN new_nt VARCHAR(30), IN new_portions INT, IN new_img_id INT)
BEGIN
    IF ( (EXISTS(SELECT * FROM chef_recipe WHERE (chef_id = c_id AND rc_id = recip_id)))  AND c_id = CURRENT_USER_ID()) THEN
        UPDATE recipe SET name = new_name, description = new_description, recipe_type = new_recipe_type, difficulty = new_difficulty, prep_time = new_prep_time,
        exec_time = new_exec_time, basic_ingredient = new_basic_ingredient, national_cuisine = new_nt, portions = new_portions, img_id = new_img_id WHERE recipe_id = recip_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permission denied';
    END IF;
END //
DELIMITER ;
CREATE ROLE chef_role;
GRANT EXECUTE ON PROCEDURE update_chef_info TO chef_role;
GRANT EXECUTE ON PROCEDURE update_recipe TO chef_role;
GRANT INSERT ON cooking_competition.recipe  TO chef_role;
GRANT INSERT ON cooking_competition.ingredients_used TO chef_role;
GRANT INSERT ON cooking_competition.equipment_used TO chef_role;
GRANT INSERT ON cooking_competition.recipe_label TO chef_role;
GRANT INSERT ON cooking_competition.recipe_meal_type TO chef_role;
GRANT INSERT ON cooking_competition.recipe_thematic_section TO chef_role;
GRANT INSERT ON cooking_competition.recipe_tips TO chef_role;
GRANT INSERT ON cooking_competition.step TO chef_role;
DELIMITER //
CREATE PROCEDURE create_chef_users()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE chef_id INT;
    DECLARE chef_username VARCHAR(255);
    DECLARE chef_password VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT c.chef_id, c.username, u.password FROM chef c INNER JOIN users u ON c.username = u.username;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO chef_id, chef_username, chef_password;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Dynamic SQL to create user
        SET @sql = CONCAT('CREATE USER "', chef_username, '"@"localhost" IDENTIFIED BY "', chef_password, '";');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Grant necessary permissions to the user
        SET @grant_sql = CONCAT('GRANT chef_role TO "', chef_username, '"@"localhost";');
        PREPARE grant_stmt FROM @grant_sql;
        EXECUTE grant_stmt;
        DEALLOCATE PREPARE grant_stmt;
    END LOOP;

    CLOSE cur;
END //
DELIMITER ;
CREATE USER 'admin_1'@'localhost' IDENTIFIED BY 'W3lc0m3';
CREATE USER 'admin_2'@'localhost' IDENTIFIED BY 'I4mth3b3st';
GRANT ALL PRIVILEGES ON cooking_competition.* TO 'admin_1'@'localhost';
GRANT ALL PRIVILEGES ON cooking_competition.* TO 'admin_2'@'localhost';
CALL create_chef_users;




