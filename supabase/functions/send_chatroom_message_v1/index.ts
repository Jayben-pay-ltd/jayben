// deno-lint-ignore-file
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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
    let chatrooms_results: any = [];

    // gets a list of the chatroom
    const chatrooms_results_1 = await supabaseClient.from("chatrooms").select().eq("first_member_user_id", body.user_id).eq("second_member_user_id", body.other_person_user_id).eq("is_active", true).then((result: any) => chatrooms_results.push(...result["data"]));

    const chatrooms_results_2 = await supabaseClient.from("chatrooms").select().eq("first_member_user_id", body.other_person_user_id).eq("second_member_user_id", body.user_id).eq("is_active", true).then((result: any) => chatrooms_results.push(...result["data"]));

    console.log("The chatrooms_results are: ", chatrooms_results);

    // if the chatroom doesn't exist yet
    if (chatrooms_results.length == 0) {
        // gets the other member's user account`
        const other_member_account = await supabaseClient.from("users").select().eq("user_id", body.other_person_user_id);

        // creates a new chatroom row and then sends the message
        await supabaseClient.from("chatrooms").insert({
            "members_with_their_details": [
                {
                    "profile_image_url": other_member_account["data"][0].profile_image_url,
                    "first_name": other_member_account["data"][0].first_name,
                    "last_name": other_member_account["data"][0].last_name,
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
                other_member_account["data"][0].user_id,
                body.user_id,
            ],
            "users_that_have_muted_this_chatroom": [],
            "last_message_seen_by": [body.user_id],
            "first_member_user_id": body.user_id,
            "last_message_uid": body.user_id,
            "last_message": "Chat created",
            "last_message_type": "prompt",
            "number_of_members": 2,
            "extra_details": {},
            "is_active": true,
        });
    }

    // sends the message to the chatroom
    await send_chatroom_message_v1(supabaseClient, body);
};

const send_chatroom_message_v1 = async (supabaseClient: any, body: any): Promise<any> => {
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