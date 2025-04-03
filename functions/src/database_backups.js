/* eslint-disable camelcase */
const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });
const json2csv = require("json2csv").parse;
const admin = require("firebase-admin");
const { v4: uuidv4 } = require('uuid');
const express = require('express');
const axios = require("axios");
const db = admin.firestore();
const fs = require('fs').promises;
const path = require('path');
const os = require('os');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors);

module.exports = function (e) {
    // ============ V1 Database Data Backup functions

    /*
        The production V1 url being used in apps is
        https://us-central1-jayben-de41c.cloudfunctions.net/backup/api/v1/security/database/backup/all_tables
    */

    // receives all tables and their content, stores them in a csv file and uploads them to storage
    app.post('/api/v1/security/database/backup/all_collections_and_tables', async (req, res) => {
        // gets tables and 
        const backup_data = async () => {
            // gets the public supabase keys document
            const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

            // calls a supabase API that gets a copy of all the supabase tables and their rows
            await axios({
                "method": "post",
                url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                headers: {
                    "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                    "Content-Type": "application/json",
                },
                data: JSON.stringify({
                    "request_type": "create_database_backups",
                }),
            }).then(async function (response) {
                // console.log(response.data);

                if (response.data.status_code == 200 && response.data.status_message == 'success') {
                    const csvFile = json2csv(response.data.data);

                    // Create a temporary directory
                    const tempDirectory = path.join(os.tmpdir(), 'backups', 'csv');
                    const tempCSVFilePath = path.join(tempDirectory, `database_backup_csv_file_${uuidv4()}.csv`);

                    try {
                        // Ensure the temporary directory exists
                        await fs.mkdir(tempDirectory, { recursive: true });

                        // Write CSV data to a file
                        await fs.writeFile(tempCSVFilePath, csvFile);

                        console.log(`Created the csv here: `, tempCSVFilePath);

                        // Upload the CSV file to storage
                        const url = await upload_csv_files_to_storage(tempCSVFilePath);

                        // Send the storage URL in the response
                        res.status(200).send(url);
                    } catch (error) {
                        console.error('Error:', error);
                        res.status(500).send('Error occurred while processing the file.');
                    }
                } else {
                    res.status(200).send("failed");
                }
            }).catch(async function (error) {
                console.log(error);

                res.status(200).send("failed");
            });
        };

        const upload_csv_files_to_storage = async (file_path) => {
            const bucket = admin.storage().bucket();

            await bucket.upload(file_path, { destination: `DatabaseBackups/database_backup_${uuidv4()}.csv` });

            const fileUrl = await bucket.file(`DatabaseBackups/database_backup_${uuidv4()}.csv`).getSignedUrl({
                expires: '09-09-4000',
                action: 'read',
            });

            // converts array to string
            const csv_file_url = fileUrl.toString();

            console.log(`The csv file url is ${csv_file_url}`);

            return csv_file_url;
        };

        try {
            await backup_data();
        } catch (e) {
            console.log(e);

            res.status(400).send("failed");
        }
    });

    e.backup = functions.runWith({
        timeoutSeconds: 180,
        memory: '1GB',
    }).https.onRequest(app);
};
