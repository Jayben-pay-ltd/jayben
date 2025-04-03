// deno-lint-ignore-file
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

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

    try {
        // sends a message & notifications
        await check_if_chatroom_exists(supabaseClient, body);

        return new Response(JSON.stringify({ data: "message sent", error_message: "none" }), {
            headers: { 'Content-Type': 'application/json' },
            status: 200,
        });
    } catch (e) {
        console.log("There was an error boss: ", e);

        return new Response(JSON.stringify({ data: "There was an error trying to send message", error_message: e }), {
            headers: { 'Content-Type': 'application/json' },
            status: 400,
        });
    }
});

// checks if the chatroom exists and then sends the message
const check_if_chatroom_exists = async (supabaseClient: any, body: any): Promise<any> => {
    let chatrooms_results = [];

    // gets a list of the chatroom
    const chatrooms_results_1 = await supabaseClient.from("chatrooms").select().eq("first_member_user_id", body.user_id).eq("second_member_user_id", body.other_person_user_id).eq("is_active", true).then((result: any) => chatrooms_results.push(...result["data"]));

    const chatrooms_results_2 = await supabaseClient.from("chatrooms").select().eq("first_member_user_id", body.other_person_user_id).eq("second_member_user_id", body.user_id).eq("is_active", true).then((result: any) => chatrooms_results.push(...result["data"]));

    // if the chatroom doesn't exist yet
    if (chatrooms_results.length == 0) {
        // gets the agent's user account
        const agent_account = await supabaseClient.from("users").select().eq("user_id", body.other_person_user_id);

        // gets the customer's account
        const customer_account = await supabaseClient.from("users").select().eq("user_id", body.user_id);

        const chatroom_id = crypto.randomUUID();

        const customer_transaction_id = crypto.randomUUID();

        const agent_transaction_id = crypto.randomUUID();

        const agents_bal_after = agent_account["data"][0]["balance"] - body.amount * 0.01;

        // 1). creates a new chatroom row and then sends the message
        // 2). creates a transaction record for the customer
        // 3). creates a transaction record for the agent
        await Promise.all([
            supabaseClient.from("chatrooms").insert({
                "members_with_their_details": [
                    {
                        "profile_image_url": agent_account["data"][0].profile_image_url,
                        "first_name": agent_account["data"][0].first_name,
                        "last_name": agent_account["data"][0].last_name,
                        "user_id": body.other_person_user_id
                    },
                    {
                        "profile_image_url": body.profile_image_url,
                        "first_name": body.first_name,
                        "last_name": body.last_name,
                        "user_id": body.user_id
                    },
                ],
                "second_member_user_id": body.other_person_user_id,
                "chatroom_creator_details": {
                    "profile_image_url": body.profile_image_url,
                    "first_name": body.first_name,
                    "last_name": body.last_name,
                    "user_id": body.user_id
                },
                "last_message_sender_details": {
                    "profile_image_url": body.profile_image_url,
                    "first_name": body.first_name,
                    "last_name": body.last_name,
                    "user_id": body.user_id
                },
                "last_message_date": new Date().toISOString(),
                "members": [
                    agent_account["data"][0].user_id,
                    body.user_id,
                ],
                "users_that_have_muted_this_chatroom": [],
                "last_message_seen_by": [body.user_id],
                "first_member_user_id": body.user_id,
                "last_message_uid": body.user_id,
                "last_message": "Chat created",
                "last_message_type": "prompt",
                "chatroom_id": chatroom_id,
                "number_of_members": 2,
                "extra_details": {},
                "is_active": true,
            }),
            supabaseClient.from("transactions").insert({
                comment: "💰",
                is_public: false,
                status: "Pending",
                attended_to: false,
                number_of_views: 0,
                number_of_likes: 0,
                amount: body.amount,
                number_of_replies: 0,
                user_id: body.user_id,
                currency: body.currency,
                withdrawal_details: null,
                p2p_sender_details: null,
                sent_received: "Received",
                transaction_type: "Deposit",
                method: 'From Jayben Agent',
                p2p_recipient_details: null,
                transaction_fee_details: null,
                savings_account_details: null,
                description: `From Jayben Agent P2P`,
                currency_symbol: body.currency_symbol,
                transaction_id: customer_transaction_id,
                country: customer_account["data"][0]["country"],
                deposit_details: {
                    Chatroom_id: chatroom_id,
                    provider: "Jayben Agent",
                    deposit_method: "Mobile Money",
                    agent_user_id: body.other_person_user_id,
                    agents_transaction_id: agent_transaction_id,
                    customers_transaction_id: customer_transaction_id,
                    charge_depositer_the_deposit_fee_from_provider: null,
                },
                wallet_balance_details: {
                    wallet_balances_difference: body.amount,
                    Rule: "The balance after must always be larger than before",
                    wallet_balance_before_transaction: customer_account["data"][0]["balance"],
                    wallet_balance_after_transaction: customer_account["data"][0]["balance"] + body.amount,
                },
                user_is_verified: customer_account["data"][0]["user_is_verified"],
                full_names: `${customer_account["data"][0]["first_name"]} ${customer_account["data"][0]["last_name"]}`,
            }),
            supabaseClient.from("transactions").insert({
                comment: "",
                is_public: false,
                attended_to: true,
                status: "Pending",
                number_of_views: 0,
                number_of_likes: 0,
                number_of_replies: 0,
                sent_received: "Sent",
                currency: body.currency,
                withdrawal_details: null,
                p2p_sender_details: null,
                amount: body.amount * 0.01,
                p2p_recipient_details: null,
                method: 'To Jayben Customer',
                transaction_type: "Withdraw",
                transaction_fee_details: null,
                savings_account_details: null,
                user_id: body.other_person_user_id,
                transaction_id: agent_transaction_id,
                currency_symbol: body.currency_symbol,
                description: `To Jayben Customers Wallet`,
                country: agent_account["data"][0]["country"],
                deposit_details: {
                    Chatroom_id: chatroom_id,
                    provider: "Jayben Agent",
                    customer_user_id: body.user_id,
                    deposit_method: "Mobile Money",
                    agents_transaction_id: agent_transaction_id,
                    customers_transaction_id: customer_transaction_id,
                    charge_depositer_the_deposit_fee_from_provider: null,
                },
                wallet_balance_details: {
                    commission_currency: "ZMW",
                    commission_percentage: "1%",
                    commission_paid: body.amount * 0.01,
                    original_withdraw_amount: body.amount,
                    wallet_balances_difference: body.amount * 0.01,
                    wallet_balance_after_transaction: agents_bal_after,
                    Rule: "The balance after must always be smaller than before",
                    wallet_balance_before_transaction: agent_account["data"][0]["balance"],
                },
                user_is_verified: agent_account["data"][0]["user_is_verified"],
                full_names: `${agent_account["data"][0]["first_name"]} ${agent_account["data"][0]["last_name"]}`,
            }),
        ]);
    }

    // sends the message to the chatroom
    await send_agent_chatroom_message_v1(supabaseClient, body);
};

const send_agent_chatroom_message_v1 = async (supabaseClient: any, body: any): Promise<any> => {
    /*
        body preview

        {
            "reply_message_details": {
                "reply_message_thumbnail_url": string,
                "reply_message_first_name": string,
                "reply_message_last_name": string,
                "reply_message_type": string,
                "reply_message_uid": string,
                "reply_message_id": string,
                "reply_message": string,
                "reply_caption": string,
            },
            "message_details": {
                "message_extension": string,
                "thumbnail_url": string,
                "message_type": string,
                "aspect_ratio": float,
                "media_url":string,
                "caption": string,
                "message": string,
            },
            "other_person_user_id": string,
            "profile_image_url": string,
            "last_message": string,
            "message_type": string,
            "chatroom_id": string,
            "first_name": string,
            "last_name": string,
            "user_id": string,
            
            "currency_symbol": string,
            "currency": string,
            "amount": float,
        }
    */

    let chatrooms_results: any = [];

    // gets a list of the chatroom
    const chatrooms_results_1 = await supabaseClient.from("chatrooms").select().eq("first_member_user_id", body.user_id).eq("second_member_user_id", body.other_person_user_id).eq("is_active", true).then((result: any) => chatrooms_results.push(...result["data"]));

    const chatrooms_results_2 = await supabaseClient.from("chatrooms").select().eq("first_member_user_id", body.other_person_user_id).eq("second_member_user_id", body.user_id).eq("is_active", true).then((result: any) => chatrooms_results.push(...result["data"]));

    let promise_operations = [];

    // gets the other member's user account
    const other_member_account = await supabaseClient.from("users").select().eq("user_id", body.other_person_user_id);

    // 1). updates the chatroom row
    // 2). creates a chatroom message row
    // 3). sends a notif to the other person in the chatroom
    promise_operations.push(
        supabaseClient.from("chatrooms").update({
            "last_message_sender_details": {
                "profile_image_url": body.profile_image_url,
                "first_name": body.first_name,
                "last_name": body.last_name,
                "user_id": body.user_id
            },
            "last_message_date": new Date().toISOString(),
            "last_message_seen_by": [body.user_id],
            "last_message_type": body.message_type,
            "last_message": body.last_message,
            "last_message_uid": body.user_id,
        }).eq("chatroom_id", chatrooms_results[0]["chatroom_id"]),
        supabaseClient.from("chatroom_messages").insert({
            "reply_message_details": {
                "reply_message_thumbnail_url": body.reply_message_details.reply_message_thumbnail_url,
                "reply_message_first_name": body.reply_message_details.reply_message_first_name,
                "reply_message_last_name": body.reply_message_details.reply_message_last_name,
                "reply_message_type": body.reply_message_details.reply_message_type,
                "reply_message_uid": body.reply_message_details.reply_message_uid,
                "reply_message_id": body.reply_message_details.reply_message_id,
                "reply_message": body.reply_message_details.reply_message,
                "reply_caption": body.reply_message_details.reply_caption,
            },
            "message_details": {
                "message_extension": body.message_details.message_extension,
                "thumbnail_url": body.message_details.thumbnail_url,
                "aspect_ratio": body.message_details.aspect_ratio,
                "media_url": body.message_details.media_url,
                "caption": body.message_details.caption,
                "message_type": body.message_type,
                "message": body.last_message,
            },
            "chatroom_id": chatrooms_results[0]["chatroom_id"],
            "sender_details": {
                "profile_image_url": body.profile_image_url,
                "first_name": body.first_name,
                "last_name": body.last_name,
                "user_id": body.user_id
            },
            "is_seen_by": [{
                "profile_image_url": body.profile_image_url,
                "first_name": body.first_name,
                "last_name": body.last_name,
                "user_id": body.user_id
            }],
            "user_id": body.user_id,
            "extra_details": {},
        }),
        supabaseClient.rpc("send_notifications_via_firebase", { title: `${body.first_name} sent you a message`, body: body.last_message, notif_tokens: [other_member_account["data"][0]["notification_token"]] }),
    );

    // runs all the operations at once
    await Promise.all(promise_operations);
};