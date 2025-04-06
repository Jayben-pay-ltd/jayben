// deno-lint-ignore-file
// deno-lint-ignore-file no-explicit-any require-await
import { RSA } from "https://deno.land/x/god_crypto@v1.4.11/mod.ts";
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7&no-check";

serve(async (req: Request) => {
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

    // runs all the minute operations
    await run_minute_operations(supabaseClient);

    return new Response(JSON.stringify({ data: "Done boss!" }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200,
    });
});

// this runs all the minute operations
const run_minute_operations = async (supabaseClient: any) => {
    try {
        await Promise.all([update_personal_no_access_savings_accounts(supabaseClient), update_shared_no_access_savings_accounts(supabaseClient)]);
    } catch (e) {
        console.log(e);
    }
}

// runs all the personal no access account operations
const update_personal_no_access_savings_accounts = async (supabaseClient: any): Promise<void> => {
    let promise_operations = [];

    // gets all the active no access savings accounts 
    const active_no_access_savings_accounts = await supabaseClient.from("no_access_savings_accounts").select().eq("is_active", true).neq("number_of_minutes_left", 0);

    // if there any accounts that are active
    if (active_no_access_savings_accounts["data"].length != 0) {
        // loops all the active no access accounts
        for (let i = 0; i < active_no_access_savings_accounts["data"].length; i++) {
            let account_info = active_no_access_savings_accounts["data"][i];

            if (account_info["number_of_minutes_left"] == 1 && account_info["balance"] != 0) {
                // 1). Updates the no access account row
                // 2). Creates a deposit transaction row
                // 3). Updates the user's wallet balance
                // 4). Sends a firebase notification telling user of deposit
                promise_operations.push(
                    supabaseClient.from("no_access_savings_accounts").update({
                        number_of_withdrawals_made_from_account: 1,
                        number_of_minutes_left: 0,
                        is_deleted: true,
                        is_active: false,
                    }).eq("account_id", account_info["account_id"]),
                    supabaseClient.from("transactions").insert({
                        comment: "",
                        is_public: false,
                        attended_to: true,
                        number_of_views: 0,
                        number_of_likes: 0,
                        status: "Completed",
                        number_of_replies: 0,
                        currency_symbol: "K",
                        deposit_details: null,
                        withdrawal_details: null,
                        p2p_sender_details: null,
                        sent_received: "Received",
                        transaction_type: "Deposit",
                        p2p_recipient_details: null,
                        transaction_fee_details: null,
                        savings_account_details: null,
                        amount: account_info["balance"],
                        user_id: account_info["user_id"],
                        method: 'From No Access Savings',
                        country: account_info["country"],
                        currency: account_info["currency"],
                        transaction_id: crypto.randomUUID(),
                        wallet_balance_details: {
                            wallet_balance_after_transaction: null,
                            wallet_balance_before_transaction: null,
                            wallet_balances_difference: account_info["balance"]
                        },
                        description: `From account: ${account_info["account_name"]}`,
                        user_is_verified: account_info["account_holder_details"]["user_is_verified"],
                        full_names: `${account_info["account_holder_details"]["first_name"]} ${account_info["account_holder_details"]["last_name"]}`,
                    }),
                    supabaseClient.rpc("update_firebase_user_wallet_balance", { user_id: account_info["user_id"], amount: account_info["balance"] }),
                    supabaseClient.rpc("send_notifications_via_firebase", { title: "You've been Paid 💰💸🔥", body: `You have just been paid ${account_info["currency"]} ${account_info["balance"]} to your wallet 🤑 time to go spend it 💯`, notif_tokens: [account_info["account_holder_notification_token"]] }),
                );
            } else if (account_info["number_of_minutes_left"] == 1 && account_info["balance"] == 0) {
                // 1). Updates the account's row
                // 2). Tells user the account has been closed
                promise_operations.push(
                    supabaseClient.from("no_access_savings_accounts").update({
                        number_of_withdrawals_made_from_account: 1,
                        number_of_minutes_left: 0,
                        is_deleted: true,
                        is_active: false,
                    }).eq("account_id", account_info["account_id"]),
                    supabaseClient.rpc("send_notifications_via_firebase", { title: 'No Access Account Closed 😕', body: `Your no access account '${account_info["account_name"]}' has expired and been closed. Create a new one and add money to it.`, notif_tokens: [...account_info["account_holder_notification_token"]] })
                );
            } else if (account_info["number_of_minutes_left"] != 1) {
                // Decreases the account's number of minutes left value
                promise_operations.push(supabaseClient.rpc("decrease_no_access_savings_accounts_number_of_minutes_left", { row_id: account_info["account_id"] }));
            }
        }
    }

    // runs all the operations
    await Promise.all(promise_operations);
};

// runs all the shared no access account operations
const update_shared_no_access_savings_accounts = async (supabaseClient: any): Promise<void> => {
    let promise_operations = [];

    // gets all the active shared no access savings accounts 
    const active_no_access_savings_accounts = await supabaseClient.from("shared_no_access_savings_accounts").select().eq("is_active", true).neq("number_of_minutes_left", 0);

    // if there any accounts that are active
    if (active_no_access_savings_accounts["data"].length != 0) {
        // loops all the active no access accounts
        for (let i = 0; i < active_no_access_savings_accounts["data"].length; i++) {
            let account_info = active_no_access_savings_accounts["data"][i];

            if (account_info["number_of_minutes_left"] == 1 && account_info["balance"] != 0) {
                // list if this account's operations
                let account_operations = [];

                // gets the list of acc bal shares of each member
                const members_acc_bal_shares = account_info["account_balance_shares"];

                for (let i = 0; i < members_acc_bal_shares.length; i++) {
                    if (members_acc_bal_shares[i]["balance"] != 0) {
                        // 1). Creates a deposit transaction row
                        // 2). Updates the user's wallet balance
                        // 3). Sends a firebase notification telling user of deposit
                        account_operations.push(
                            supabaseClient.from("transactions").insert({
                                comment: "",
                                is_public: false,
                                attended_to: true,
                                number_of_views: 0,
                                number_of_likes: 0,
                                status: "Completed",
                                number_of_replies: 0,
                                deposit_details: null,
                                withdrawal_details: null,
                                p2p_sender_details: null,
                                sent_received: "Received",
                                transaction_type: "Deposit",
                                p2p_recipient_details: null,
                                transaction_fee_details: null,
                                savings_account_details: null,
                                transaction_id: crypto.randomUUID(),
                                method: 'From Group No Access Savings',
                                amount: members_acc_bal_shares[i]["balance"],
                                user_id: members_acc_bal_shares[i]["user_id"],
                                country: members_acc_bal_shares[i]["country"],
                                full_names: members_acc_bal_shares[i]["names"],
                                currency: members_acc_bal_shares[i]["currency"],
                                description: `From ${account_info["account_name"]}`,
                                currency_symbol: members_acc_bal_shares[i]["currency_symbol"],
                                user_is_verified: members_acc_bal_shares[i]["user_is_kyc_verified"],
                                wallet_balance_details: {
                                    wallet_balances_difference: members_acc_bal_shares[i]["balance"],
                                    wallet_balance_before_transaction: null,
                                    wallet_balance_after_transaction: null
                                },
                            }),
                            supabaseClient.rpc("update_firebase_user_wallet_balance", { user_id: members_acc_bal_shares[i]["user_id"], amount: members_acc_bal_shares[i]["balance"] }),
                            supabaseClient.rpc("send_notifications_via_firebase", { title: "You've been Paid 💰💸🔥", body: `You have just been paid ${members_acc_bal_shares[i]["currency"]} ${members_acc_bal_shares[i]["balance"]} to your wallet 🤑 time to go spend it 💯`, notif_tokens: [members_acc_bal_shares[i]["notification_token"]] })
                        );
                    } else {
                        // sends the people that didn't contribute to the account a notification
                        account_operations.push(
                            supabaseClient.rpc("send_notifications_via_firebase", { title: 'Group No Access Account Closed 😕', body: `Your group no access account '${account_info["account_name"]}' has expired and been closed. Unfortunetely you never made a deposit & the share of the account was 0.`, notif_tokens: [members_acc_bal_shares[i]["notification_token"]] })
                        );
                    }
                }

                // 1). Updates the no access account row
                // 2). adds the other account operations to the list
                promise_operations.push(
                    supabaseClient.from("shared_no_access_savings_accounts").update({
                        number_of_withdrawals_made_from_account: 1,
                        number_of_minutes_left: 0,
                        is_deleted: true,
                        is_active: false,
                    }).eq("account_id", account_info["account_id"]),
                    ...account_operations,
                );
            } else if (account_info["number_of_minutes_left"] == 1 && account_info["balance"] == 0) {
                let notifications_tokens = [];

                // gets the list of acc bal shares of each member
                const members_acc_bal_shares = account_info["account_balance_shares"];

                // get the notification tokens of each member
                for (let i = 0; i < members_acc_bal_shares.length; i++) {
                    notifications_tokens.push(members_acc_bal_shares[i]["notification_token"]);
                }
                // 1). Updates the account's row
                // 2). Tells user the account has been closed
                promise_operations.push(
                    supabaseClient.from("shared_no_access_savings_accounts").update({
                        number_of_withdrawals_made_from_account: 1,
                        number_of_minutes_left: 0,
                        is_deleted: true,
                        is_active: false,
                    }).eq("account_id", account_info["account_id"]),
                    supabaseClient.rpc("send_notifications_via_firebase", { title: 'Group No Access Account Closed 😕', body: `Your group no access account '${account_info["account_name"]}' has expired and been closed. Create a new one and add money to it.`, notif_tokens: notifications_tokens })
                );
            } else if (account_info["number_of_minutes_left"] != 1) {
                const new_minutes_left = account_info["number_of_minutes_left"] - 1;

                // Decreases the account's number of minutes left value
                promise_operations.push(supabaseClient.from("shared_no_access_savings_accounts").update({
                    number_of_minutes_left: new_minutes_left,
                }).eq("account_id", account_info["account_id"]));
            }
        }
    }

    // runs all the operations
    await Promise.all(promise_operations);
};