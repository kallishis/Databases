The GitHub repository for the database is as follows: 
https://github.com/kallishis/Databases.git

Initially, we install Git Bash, Node.js, MySQL, and MySQL Workbench.

Then, through Git Bash, we can clone the repository using the following command: 
git clone https://github.com/kallishis/Databases.git

In MySQL Workbench, we run the files DDL.sql, DML.sql, roles.sql (in that order!).

Afterward, in an editor (We used Visual Studio Code), we install mysql2 via the terminal with the command: 
npm install mysql2

Next, we navigate to the folder where we have saved the files copied from the repository and run the files random.js and random_judges.js with the commands:
node random.js
node random_judges.js

After the final step, we can connect to the database and execute queries.