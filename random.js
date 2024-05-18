const mysql = require('mysql');

// Create MySQL connection
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'password',
    database: 'cooking_competition'
});

// Connect to MySQL
connection.connect((err) => {
    if (err) {
        console.error('Error connecting to database: ' + err.stack);
        return;
    }
    
    console.log('Connected to database');
    
    
    // Define async function to generate data
    const generateData = async () => {
        try {
            // Define async function to generate data for a single season
            const generateDataForSeason = async (season,nationalCuisines) => {
                // Fetch participation in previous episodes
                const previousEpisodesChef = {};
                const previousEpisodesNt = {};
                const previousEpisodesRc = {};
                // Function to generate data for a single episode
                const generateDataForEpisode = async (episode, previousEpisodesChef, previousEpisodesRc, previousEpisodesNt) => {
                    console.log(`Generating data for Season ${season}, Episode ${episode}`);
                    
                    const episodeCuisines = [];

                    // List to keep track of selected chefs for this episode
                    const selectedChefs = [];

                    // Loop until we have selected 10 unique cuisines for this episode
                    while (episodeCuisines.length < 10) {
                        // Find a valid national cuisine not participating in the last 3 episodes
                        const validCuisine = await findValidCuisine(previousEpisodesNt, episode, nationalCuisines);

                        // Check if the cuisine is not already selected for this episode
                        if (!episodeCuisines.includes(validCuisine.nt_name)) {
                            episodeCuisines.push(validCuisine.nt_name);

                            let chef_id;
                            let recipe;

                            // Attempt to find a valid chef and recipe until successful or exhausted
                            let attempts = 0;
                            while (attempts < 25) { 
                                // Find a valid chef for the cuisine not participating in the last 3 episodes
                                chef_id = await findValidChef(validCuisine.nt_name, previousEpisodesChef, episode, selectedChefs);

                                // Find a valid recipe for the cuisine and chef not participating in the last 3 episodes
                                recipe = await findValidRecipe(validCuisine.nt_name, chef_id, previousEpisodesRc, episode);

                                // If a valid recipe is found, break the loop
                                if (recipe) {
                                    break;
                                }

                                // Increment attempts and try again with another chef
                                attempts++;
                            }

                            // Output episode data
                            console.log(`Season ${season}, Episode ${episode}, Entry ${(episode - 1) * 10 + (season - 1) * 100 + episodeCuisines.length}:`);
                            console.log(`National Cuisine: ${validCuisine.nt_name}`);
                            console.log(`Recipe: ${recipe ? recipe.recipe_name : 'No valid recipe found'}`);
                            console.log(`Chef: ${chef_id}`);
                            console.log('---------------------');

                            // Insert episode data into episode_entries table
                            const episodeEntry = {
                                entry_id: (episode - 1) * 10 + (season - 1) * 100 + episodeCuisines.length,
                                episode_id: episode,
                                season_id: season,
                                nt_name: validCuisine.nt_name,
                                chef_id: chef_id,
                                rc_id: recipe ? recipe.recipe_id : null,
                                score1: generateRandomScore(),
                                score2: generateRandomScore(),
                                score3: generateRandomScore()
                            };

                            await new Promise((resolve, reject) => {
                                connection.query('INSERT INTO episode_entries SET ?', episodeEntry, (err, result) => {
                                    if (err) reject(err);
                                    console.log(`Inserted episode entry with ID ${result.insertId}`);
                                    resolve();
                                });
                            });

                            // Add selected chef to the list
                            selectedChefs.push(chef_id);
                            if (!previousEpisodesChef[chef_id]) {
                                    previousEpisodesChef[chef_id] = [];
                            }
                            if (!previousEpisodesRc[recipe.recipe_id]) {
                                previousEpisodesRc[recipe.recipe_id] = [];
                            }
                            if (!previousEpisodesNt[nationalCuisines.indexOf(validCuisine.nt_name)]) {
                                previousEpisodesNt[nationalCuisines.indexOf(validCuisine.nt_name)] = [];
                            }
                            previousEpisodesChef[chef_id].push(episode);
                            previousEpisodesRc[recipe.recipe_id].push(episode);
                            previousEpisodesNt[nationalCuisines.indexOf(validCuisine.nt_name)].push(episode);
                            
            
                        }
                    }
                };


                // Generate data for each episode of the current season
                for (let episode = 1; episode <= 10; episode++) {
                    await generateDataForEpisode(episode, previousEpisodesChef, previousEpisodesRc,previousEpisodesNt);
                }
            };

            // Function to find a valid national cuisine not participating in the last 3 episodes
            const findValidCuisine = async (previousEpisodes, episode, nationalCuisines) => {
                let cuisine;
                let selectedCuisine = false;

                while (!selectedCuisine) {
                    cuisine = await new Promise((resolve, reject) => {
                        connection.query('SELECT * FROM national_cuisine ORDER BY RAND() LIMIT 1', (err, result) => {
                        if (err) reject(err);
                            resolve(result[0]);
                        });
                    });

                    // Check if the cuisine has participated in the last 3 episodes
                    const cuisineName = cuisine.nt_name;
                    if (!previousEpisodes[nationalCuisines.indexOf(cuisineName)] || !previousEpisodes[nationalCuisines.indexOf(cuisineName)].includes(episode - 1) || !previousEpisodes[nationalCuisines.indexOf(cuisineName)].includes(episode - 2) || !previousEpisodes[nationalCuisines.indexOf(cuisineName)].includes(episode - 3)) {
                        selectedCuisine = true;
                    }
                }

                return cuisine;
            };

            const findValidChef = async (cuisineName, previousEpisodes, episode, selectedChefs) => {
                let chef_id;
                let selectedChef = false;
            
                while (!selectedChef) {
                    // Select a random chef for the cuisine
                    const chefResult = await new Promise((resolve, reject) => {
                        connection.query('SELECT * FROM chef_national_cuisines INNER JOIN chef ON chef_national_cuisines.chef_id = chef.chef_id WHERE nt_name = ? ORDER BY RAND() LIMIT 1', [cuisineName], (err, result) => {
                            if (err) reject(err);
                            resolve(result);
                        });
                    });
            
                    chef_id = chefResult[0].chef_id;
            
                    // Check if the chef has participated in the previous 3 episodes and is not already selected for this episode
                    if ((!previousEpisodes[chef_id] || !previousEpisodes[chef_id].includes(episode - 1) || !previousEpisodes[chef_id].includes(episode - 2) || !previousEpisodes[chef_id].includes(episode - 3)) && !selectedChefs.includes(chef_id)) {
                        selectedChef = true;
                    }
                }
            
                return chef_id;
            };

            // Function to find a valid recipe not participating in the last 3 episodes
            const findValidRecipe = async (cuisine, chef_id, previousEpisodes, episode) => {
                let recipe;
                let selectedRecipe = false;
            
                while (!selectedRecipe) {
                    recipe = await new Promise((resolve, reject) => {
                        connection.query('SELECT * FROM recipe INNER JOIN chef_recipe ON recipe.recipe_id = chef_recipe.rc_id WHERE recipe.national_cuisine = ? AND chef_recipe.chef_id = ? ORDER BY RAND() LIMIT 1', [cuisine, chef_id], (err, result) => {
                            if (err) reject(err);
                            resolve(result[0]);
                        });
                    });
            
                    // Check if the recipe has participated in the last 3 episodes
                    const recipeId = recipe ? recipe.recipe_id : null;
                    if (!previousEpisodes[recipeId] || !previousEpisodes[recipeId].includes(episode - 1) || !previousEpisodes[recipeId].includes(episode - 2) || !previousEpisodes[recipeId].includes(episode - 3)) {
                        selectedRecipe = true;
                    }
                }
            
                return recipe;
            };

            // Function to generate random score from 1 to 5
            const generateRandomScore = () => {
                return Math.floor(Math.random() * 5) + 1;
            };

            // Generate data for 5 seasons
            for (let season = 1; season <= 5; season++) {
                console.log(`Generating data for Season ${season}`);
                
                // Fetch all cuisines
                const nationalCuisines = await new Promise((resolve, reject) => {
                    connection.query('SELECT nt_name FROM national_cuisine', (err, results) => {
                        if (err) reject(err);
                        const cuisineNames = results.map(row => row.nt_name);
                        resolve(cuisineNames);
                    });
                });
            
                await generateDataForSeason(season, nationalCuisines);
            }
        } catch (error) {
            console.error('Error generating data: ' + error);
        } finally {
            // Close MySQL connection after generating data for all seasons
            connection.end();
        }
    };

    // Call the async function to generate data
    generateData();
});
