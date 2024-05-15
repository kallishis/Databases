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
            const generateDataForSeason = async (season) => {
                // Function to generate data for a single episode
                const generateDataForEpisode = async (episode, previousEpisodes) => {
                    console.log(`Generating data for Season ${season}, Episode ${episode}`);
                    const episodeChefs = [];
                    
                    // Retrieve 10 random national cuisines
                    const cuisines = await new Promise((resolve, reject) => {
                        connection.query('SELECT * FROM national_cuisine ORDER BY RAND() LIMIT 10', (err, result) => {
                            if (err) reject(err);
                            resolve(result);
                        });
                    });

                    // Iterate over each national cuisine
                    for (const cuisine of cuisines) {
                        let chef_id;
                        let recipe;
                        let selectedChef = false;

                        // Select a random chef and recipe until a suitable one is found
                        while (!selectedChef) {
                            // Select a random chef for the cuisine
                            const chefResult = await new Promise((resolve, reject) => {
                                connection.query('SELECT * FROM chef_national_cuisines INNER JOIN chef ON chef_national_cuisines.chef_id = chef.chef_id  WHERE nt_name = ? ORDER BY RAND() LIMIT 1', [cuisine.nt_name], (err, result) => {
                                    if (err) reject(err);
                                    resolve(result);
                                });
                            });

                            chef_id = chefResult[0].chef_id;

                            // Check if the chef participated in the previous 3 episodes
                            if (!previousEpisodes[chef_id] || !previousEpisodes[chef_id].includes(episode - 1) || !previousEpisodes[chef_id].includes(episode - 2) || !previousEpisodes[chef_id].includes(episode - 3)) {
                                selectedChef = true;
                            }
                        }

                        // Select a random recipe for the cuisine
                        recipe = await new Promise((resolve, reject) => {
                            connection.query('SELECT * FROM recipe WHERE national_cuisine = ? ORDER BY RAND() LIMIT 1', [cuisine.nt_name], (err, result) => {
                                if (err) reject(err);
                                resolve(result);
                            });
                        });

                        // Store the chef ID for this episode
                        episodeChefs.push(chef_id);

                        // Output episode data
                        console.log(`Season ${season}, Episode ${episode}, Entry ${(episode - 1) * 10 + (season - 1) * 100 + cuisines.indexOf(cuisine) + 1}:`);
                        console.log(`National Cuisine: ${cuisine.nt_name}`);
                        console.log(`Recipe: ${recipe[0].recipe_name}`);
                        console.log(`Chef: ${chef_id}`);
                        console.log('---------------------');

                        // Insert episode data into episode_entries table
                        const episodeEntry = {
                            entry_id: (episode - 1) * 10 + (season - 1) * 100 + cuisines.indexOf(cuisine) + 1,
                            episode_id: episode,
                            season_id: season,
                            nt_name: cuisine.nt_name,
                            chef_id: chef_id,
                            rc_id: recipe[0].recipe_id,
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
                    }
                };

                // Fetch participation of chefs in previous episodes
                const previousEpisodes = {};
                const episodes = await new Promise((resolve, reject) => {
                    connection.query('SELECT * FROM episode_entries', (err, result) => {
                        if (err) reject(err);
                        resolve(result);
                    });
                });

                episodes.forEach((episode) => {
                    const chef_id = episode.chef_id;
                    const episode_season = episode.season_id;
                    const episode_num = episode.episode_id;
                    if (!previousEpisodes[chef_id]) {
                        previousEpisodes[chef_id] = [];
                    }
                    previousEpisodes[chef_id].push(episode_num + (episode_season - 1) * 10);
                });

                // Generate data for each episode of the current season
                for (let episode = 1; episode <= 10; episode++) {
                    await generateDataForEpisode(episode, previousEpisodes);
                }
            };

            // Function to generate random score from 1 to 5
            const generateRandomScore = () => {
                return Math.floor(Math.random() * 5) + 1;
            };

            // Generate data for 5 seasons
            for (let season = 1; season <= 5; season++) {
                console.log(`Generating data for Season ${season}`);
                await generateDataForSeason(season);
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