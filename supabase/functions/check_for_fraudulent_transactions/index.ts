// deno-lint-ignore-file
// deno-lint-ignore-file no-explicit-any require-await
import { RSA } from "https://deno.land/x/god_crypto@v1.4.11/mod.ts";
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7&no-check";

serve(async (req: Request) => {
    const body = await req.json();

    // Create a Supabase client with the Auth context of the logged in user.
    const supabaseClient = createClient(
        // Supabase API URL - env var exported by default.
        Deno.env.get("SUPABASE_URL") ?? "",
        // Supabase API ANON KEY - env var exported by default.
        Deno.env.get("SUPABASE_ANON_KEY") ?? "",
        // Create client with Auth context of the user that called the function.
        // This way your row-level-security (RLS) policies are applied.
        {
            global: { headers: { Authorization: req.headers.get("Authorization")! } },
            auth: {
                detectSessionInUrl: false,
                autoRefreshToken: false,
                persistSession: false,
            }
        },
    )

    let fraud_result: any = "";

    if (body.user_id == "") {
        // checks for fraud for all users all at once
        await check_for_fraud_for_account_users(supabaseClient, body);
    } else {
        // checks for fraud for 1 user at a time
        fraud_result = await check_for_fraud_for_account_users(supabaseClient, body.user_id);
    }

    return new Response(JSON.stringify({
        money_out_amount: fraud_result.money_out_amount,
        money_in_amount: fraud_result.money_in_amount,
        currency: fraud_result.currency,
        data: fraud_result.response
    }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200,
    });
});

// goes through the user's transactions and checks if they have 
// withdrawn more money than they have ever deposited
const check_for_fraud_for_account_users = async (supabase: any, user_id: any): Promise<any> => {
    /*
        body preview
        {
            "user_id": string,
        }
    */

    let wallet_bal = 0.0;
    let total_p2p_in = 0.0;
    let total_p2p_out = 0.0;
    let total_withdrawals = 0.0;
    let total_airtime_purchases = 0.0;
    let total_deposits_momo_card = 0.0;
    let total_transfer_to_savings = 0.0;
    let total_commissions_received = 0.0;
    let total_deposits_from_savings = 0.0;

    // get's the user's account row
    const user_row = await supabase.from("users").select().eq("user_id", user_id);

    // gets the user's referral commissions transactions
    const user_referral_commission_rows = await supabase.from("referral_commission_transactions").select().eq("user_id", user_id);

    // gets all the user's withdrawal records
    const transaction_rows = await supabase.from("transactions").select().eq("user_id", user_id);

    for (var i = 0; i < transaction_rows["data"].length; i++) {
        // DEPOSITS TO WALLET
        if (transaction_rows["data"][i]["transaction_type"] == "Deposit") {
            // MOMO & CARD PAYMENTS
            if (transaction_rows["data"][i]["method"] != "From Group No Access Savings") {
                total_deposits_momo_card += transaction_rows["data"][i]["amount"];
            }

            // FROM EXPIRED SAVINGS ACCOUNTS
            if (transaction_rows["data"][i]["method"] == "From Group No Access Savings") {
                total_deposits_from_savings += transaction_rows["data"][i]["amount"];
            }
        }

        // P2P TRANSFERS
        if (transaction_rows["data"][i]["transaction_type"] == "Transfer") {
            // TRANSFERS OUT OF WALLET
            if (transaction_rows["data"][i]["sent_received"] == "Sent") {
                total_p2p_out += transaction_rows["data"][i]["amount"];
            }

            // TRANSFERS INTO WALLET
            if (transaction_rows["data"][i]["sent_received"] == "Received") {
                total_p2p_in += transaction_rows["data"][i]["amount"];
            }
        }

        // TRANSFERS TO SAVINGS
        if (transaction_rows["data"][i]["transaction_type"] == "Savings Transfer") {
            total_transfer_to_savings += transaction_rows["data"][i]["amount"];
        }

        // WITHDRAWALS
        if (transaction_rows["data"][i]["transaction_type"] == "Withdrawal") {
            if (transaction_rows["data"][i]["status"] == "Completed" || transaction_rows["data"][i]["status"] == "Pending") {
                total_withdrawals += transaction_rows["data"][i]["amount"];
            }
        }

        // AIRTIME
        if (transaction_rows["data"][i]["transaction_type"] == "Airtime Purchase") {
            total_airtime_purchases += transaction_rows["data"][i]["amount"];
        }
    }

    // gets the total of all the referral commissions received
    for (let i = 0; i < user_referral_commission_rows["data"].length; i++) {
        total_commissions_received += user_referral_commission_rows["data"][i]["amount"];
    }

    // =============== scan all the user's shared nas accounts for donations

    // scans all the user's nas accounts where they own the nas accounts
    const total_donations_received = await scan_all_nas_accs(supabase, user_id);

    // ===============

    let total_money_in = 0.0;
    let total_money_out = 0.0;

    // sums up all the money in transactions
    total_money_in = total_p2p_in + total_deposits_momo_card + total_commissions_received + total_donations_received;

    // sums up all the money out transactions
    total_money_out = total_p2p_out + total_airtime_purchases + total_withdrawals;

    let response = "";

    console.log(`The total money in is ${total_money_in}`);

    console.log(`The total money out is ${total_money_out}`);

    if (total_money_out > total_money_in) {
        response = "Fraudulent activity detected: This person is trying to withdraw more money than they have ever deposited.";

        const amount = total_money_out - total_money_in;

        // creates a potential fraud alert record
        await supabase.from("potential_fraud_alerts").insert({
            "fraud_type": `money in - money out imbalance. The money in is ${total_money_in} & the money out is ${total_money_out}`,
            "comment": "The money in - money out ratio is not normal for this user's account & transactions",
            "first_name": user_row["data"][0]["first_name"],
            "last_name": user_row["data"][0]["last_name"],
            "currency": user_row["data"][0]["currency"],
            "user_id": user_row["data"][0]["user_id"],
            "extra_details": user_row["data"][0],
            "alert_id": crypto.randomUUID(),
            "transaction_id": "",
            "amount": amount,
        });
    } else if (total_money_out < total_money_in || total_money_out == total_money_in) {
        response = "Everything looks good boss. No fraudulent activity detected.";
    }

    return {
        "currency": user_row["data"][0]["currency"],
        "money_out_amount": total_money_out,
        "money_in_amount": total_money_in,
        "response": response,
    };
};

// checks if the user received money as donations
const scan_all_nas_accs = async (supabase: any, user_id: any): Promise<any> => {
    // gets all the user's shared nas accounts
    const accounts_rows = await supabase.from("shared_no_access_savings_accounts").select().eq("user_id", user_id);

    let money_received_as_donations = 0.0;

    // for all the nas accounts, get their transactions and look for donations
    for (let i = 0; i < accounts_rows["data"].length; i++) {
        // stores the current nas account's data
        const current_account_row = accounts_rows["data"][i];

        // gets the shared nas account owner's user id
        const nas_account_owners_user_id = current_account_row["user_id"];

        // if the user is the owner of the nas account
        if (nas_account_owners_user_id == user_id) {
            // gets the current savings account's transactions
            const acc_transaction_rows = await supabase.from("shared_no_access_savings_accounts_transactions").select().eq("savings_account_id", current_account_row["account_id"]);

            // these are the people who are part of the nas account
            const account_member_user_ids = current_account_row["user_ids_able_to_view_accounts"];

            // for all the transactions, check for donations
            for (let j = 0; j < acc_transaction_rows["data"].length; j++) {
                // stores the current transaction's data
                const current_nas_acc_transaction = acc_transaction_rows["data"][j];

                console.log(`The current transactions's user_id is ${current_nas_acc_transaction["user_id"]}`);

                // if the transaction's user id isn't amongst the list of member user ids
                // record that transaction as money received as a donation
                if (account_member_user_ids.includes(current_nas_acc_transaction["user_id"]) == false) {
                    console.log(`Now adding the transaction's amount as a donation boss`);
                    money_received_as_donations += current_nas_acc_transaction["amount"];
                }
            }
        }
    }

    console.log(`The money received as donations is ${money_received_as_donations}`);

    return money_received_as_donations;
};

const check_for_uncompleted_deposits = async (supabase: any, user_id: any): Promise<any> => {
    // const v2_mobile_money_deposit_rows = await supabs
}

