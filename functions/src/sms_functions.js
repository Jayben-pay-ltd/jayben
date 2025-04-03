const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors);

module.exports = function (e) {
    app.post('/api/internal/v1/sms/send/zambia', async (req, res) => {
        const body = req.body;

        /*
            body preview
            {
                "sender_id": "string",
                "phone_numbers": text[],
                "text_content": "string",
            }

            phone numbers must contain a '+' at the beginning
        */

        try {
            // sends justin an sms so he can process the withdrawal
            require('africastalking')({
                apiKey: '7eef716206eb9b641718604995f48bd165663a4005ea37f7db6af4f7297ab5ee',
                username: 'Jayben_zambia',
            }).SMS.send({
                to: [...body.phone_numbers],
                message: body.text_content,
                from: 'Jayben_ZM',
            })
                .then(console.log)
                .catch(console.log);

            // await axios({
            //     method: 'post',
            //     url: "https://www.smszambia.com/smsservice/jsonapi",
            //     data: '{"auth":{"username":"sm7-jayben","password":"J@yEnt","sender_id":"' + body.sender_id + '"},"messages":[{"phone":"' + body.phone_number + '","message":"' + body.text_content + '"}]}',
            // }).then(async function (response) {
            //     console.log(response.data);
            // });

            res.status(409).send("Done boss!");
        } catch (e) {
            console.log(e);

            res.status(409).send("Failed");
        }
    });

    e.sms = functions.https.onRequest(app);
};
