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

    // Function to shuffle an array
    const shuffle = (array) => {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
        return array;
    };

    // Define async function to generate judges for each episode
    const generateJudgesForEpisode = async (episode, season, previousJudges) => {
        console.log(`Generating judges for Season ${season}, Episode ${episode}`);

        // Retrieve random chefs who are eligible to be judges
        const eligibleJudges = await new Promise((resolve, reject) => {
            connection.query('SELECT * FROM chef WHERE NOT EXISTS (SELECT * FROM episode_entries WHERE episode_id = ? AND season_id = ? AND chef_id = chef.chef_id) ORDER BY RAND() LIMIT 3', [episode, season], (err, result) => {
                if (err) reject(err);
                resolve(result);
            });
        });

        // Shuffle the eligible judges randomly
        const shuffledJudges = shuffle(eligibleJudges);

        // Select the first three judges
        const judges = shuffledJudges.slice(0, 3);

        // Output judges data
        console.log(`Judges for Season ${season}, Episode ${episode}:`);
        console.log(`First Judge: ${judges[0].chef_id}`);
        console.log(`Second Judge: ${judges[1].chef_id}`);
        console.log(`Third Judge: ${judges[2].chef_id}`);
        console.log('---------------------');

        // Insert judges data into the judges table
        const judgesEntry = {
            episode_id: episode,
            season_id: season,
            first_judge_id: judges[0].chef_id,
            second_judge_id: judges[1].chef_id,
            third_judge_id: judges[2].chef_id
        };

        await new Promise((resolve, reject) => {
            connection.query('INSERT INTO judges SET ?', judgesEntry, (err, result) => {
                if (err) reject(err);
                console.log(`Inserted judges entry for Episode ${episode} of Season ${season}`);
                resolve();
            });
        });
    };

    // Define async function to generate judges for each season
    const generateJudgesForSeason = async (season) => {
        // Fetch participation of judges in previous episodes
        const previousJudges = {};
        const judges = await new Promise((resolve, reject) => {
            connection.query('SELECT * FROM judges WHERE season_id = ?', [season], (err, result) => {
                if (err) reject(err);
                resolve(result);
            });
        });

        judges.forEach((judge) => {
            const episode_id = judge.episode_id;
            if (!previousJudges[episode_id]) {
                previousJudges[episode_id] = [];
            }
            previousJudges[episode_id].push(judge.first_judge_id);
            previousJudges[episode_id].push(judge.second_judge_id);
            previousJudges[episode_id].push(judge.third_judge_id);
        });

        // Generate judges for each episode of the current season
        for (let episode = 1; episode <= 10; episode++) {
            await generateJudgesForEpisode(episode, season, previousJudges);
        }
    };

    // Define async function to generate judges for all seasons
    const generateJudges = async () => {
        for (let season = 1; season <= 5; season++) {
            console.log(`Generating judges for Season ${season}`);
            await generateJudgesForSeason(season);
        }
    };

    // Call the async function to generate judges
    generateJudges();
});
