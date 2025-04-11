// deno-lint-ignore-file
// deno-lint-ignore-file no-explicit-any require-await
import { RSA } from "https://deno.land/x/god_crypto@v1.4.11/mod.ts";
import { serve } from "https://deno.land/std@0.210.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.44.2&no-check";

serve(async (req: Request) => {
  const body = await req.json();

  // Create a Supabase client with the Auth context of the logged in user.
  const supabaseClient = createClient(
    // Supabase API URL - env var exported by default.
    Deno.env.get("SUPABASE_URL") ?? "",
    // Supabase API SERVICE KEY - env var exported by default.
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    // Create client with Auth context of the user that called the function.
    // This way your row-level-security (RLS) policies are applied.
  );

  // a list of functions allowed to bypass login requirement
  const approved_by_pass_functions_list: Array<string> = [
    "get_zambian_mobile_money_account_names",
    "check_if_account_email_address_exists",
    "check_if_account_phone_number_exists",
    "get_todays_currency_exchange_rates",
    "check_if_account_username_exists",
    "check_if_referral_code_exists",
    "alert_admins_about_new_signup",
    "get_encrypted_password",
    "get_terms_of_service",
    "send_reset_password",
    "convert_currency",
  ];

  // gets the user's id from the request
  const user_id = await get_auth_user_id(req, supabaseClient);

  // if the user isn't logged in & the type of request isn't permitted to bypass login
  if (
    user_id == null &&
    !approved_by_pass_functions_list.includes(body["request_type"])
  ) {
    return new Response(JSON.stringify({ data: "Please login first" }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  }

  // TODO add a roadblock here that blocks all requests is user isn't logged in. Or if uid is null.

  let data_to_return_in_response: any = "Done boss!";

  try {
    switch (body.request_type) {
      case "convert_currency":
        // converts an amount from one currency to another currency
        data_to_return_in_response = await convert_currency(
          supabaseClient,
          body,
        );
        break;

      case "get_todays_currency_exchange_rates":
        // records today's currency exchange rates
        data_to_return_in_response = get_daily_currency_exchange_rates(
          supabaseClient,
        );
        break;

      case "delete_user_account":
        data_to_return_in_response = await delete_user_account(
          supabaseClient,
          req,
          body,
        );
        break;

      case "check_if_user_has_money_in_system_before_deletion":
        data_to_return_in_response =
          await check_if_user_has_money_in_system_before_deletion(
            supabaseClient,
            req,
            body,
          );
        break;

      case "record_all_user_accounts":
        data_to_return_in_response = await record_all_user_accounts(
          supabaseClient,
        );
        break;

      case "record_daily_metrics":
        data_to_return_in_response = await record_daily_metrics(supabaseClient);
        break;

      case "get_all_notification_tokens":
        data_to_return_in_response = await get_all_notification_tokens(
          supabaseClient,
        );
        break;

      case "create_database_backups":
        data_to_return_in_response = await create_database_backups(
          supabaseClient,
        );
        break;

      case "add_post_to_contacts":
        data_to_return_in_response = await add_post_to_contacts(
          supabaseClient,
          body,
        );
        break;

      case "add_money_to_shared_nas_account":
        data_to_return_in_response = await add_money_to_shared_nas_account(
          supabaseClient,
          req,
          body,
        );
        break;

      case "create_update_row_record":
        // await create_update_row_record(supabaseClient, body);
        break;

      case "mark_contact_as_existing_jayben_user":
        data_to_return_in_response = await mark_contact_as_existing_jayben_user(
          supabaseClient,
          body,
        );
        break;

      case "initiate_contacts_upload":
        data_to_return_in_response = await initiate_contacts_upload(
          supabaseClient,
          body,
        );
        break;

      case "scan_all_user_accounts_for_fraud_at_once":
        data_to_return_in_response =
          await scan_all_user_accounts_for_fraud_at_once(supabaseClient);
        break;

      case "run_each_user_through_fraud_check_algo":
        data_to_return_in_response =
          await run_each_user_through_fraud_check_algo(body);
        break;

      case "create_user_account_record":
        data_to_return_in_response = await create_user_account_record(
          supabaseClient,
          body,
          req,
        );
        break;

      case "check_if_account_email_address_exists":
        data_to_return_in_response =
          await check_if_account_email_address_exists(supabaseClient, body);
        break;

      case "check_if_account_username_exists":
        data_to_return_in_response = await check_if_account_username_exists(
          supabaseClient,
          body,
        );
        break;

      case "check_if_account_phone_number_exists":
        data_to_return_in_response = await check_if_account_phone_number_exists(
          supabaseClient,
          body,
        );
        break;

      case "check_if_referral_code_exists":
        data_to_return_in_response = await check_if_referral_code_exists(
          supabaseClient,
          body,
        );
        break;

      case "create_pin_code":
        data_to_return_in_response = await create_pin_code(
          supabaseClient,
          body,
          req,
        );
        break;

      case "check_if_pin_code_is_correct":
        data_to_return_in_response = await check_if_pin_code_is_correct(
          supabaseClient,
          body,
          req,
        );
        break;

      case "change_pin_code":
        data_to_return_in_response = await change_pin_code(
          supabaseClient,
          body,
          req,
        );
        break;

      case "reset_pin_code":
        data_to_return_in_response = await reset_pin_code(
          supabaseClient,
          body,
          req,
        );
        break;

      case "get_users_email_address":
        data_to_return_in_response = await get_users_email_address(
          supabaseClient,
          body,
          req,
        );
        break;

      case "get_terms_of_service":
        data_to_return_in_response = await get_terms_of_service(
          supabaseClient,
          body,
          req,
        );
        break;

      case "update_profile_image_url":
        data_to_return_in_response = await update_profile_image_url(
          supabaseClient,
          req,
          body,
        );
        break;

      case "get_user_account":
        data_to_return_in_response = await get_user_account(
          supabaseClient,
          req,
          body,
        );
        break;

      case "check_if_app_is_upto_date":
        data_to_return_in_response = await check_if_app_is_upto_date(
          supabaseClient,
          req,
          body,
        );
        break;

      case "get_all_users_transactions":
        data_to_return_in_response = await get_all_users_transactions(
          supabaseClient,
          req,
        );
        break;

      case "get_users_home_page_transactions":
        data_to_return_in_response = await get_users_home_page_transactions(
          supabaseClient,
          req,
        );
        break;

      case "update_user_notification_token":
        data_to_return_in_response = await update_user_notification_token(
          supabaseClient,
          req,
          body,
        );
        break;

      case "update_show_update_alert":
        data_to_return_in_response = await update_show_update_alert(
          supabaseClient,
          req,
          body,
        );
        break;

      case "get_feedback_submissions":
        data_to_return_in_response = await get_feedback_submissions(
          supabaseClient,
        );
        break;

      case "create_a_feedback_submission":
        data_to_return_in_response = await create_a_feedback_submission(
          supabaseClient,
          req,
          body,
        );
        break;

      case "upvote_an_existing_feedback_submission":
        data_to_return_in_response =
          await upvote_an_existing_feedback_submission(
            supabaseClient,
            req,
            body,
          );
        break;

      case "update_device_id_and_ip_address":
        data_to_return_in_response = await update_device_id_and_ip_address(
          supabaseClient,
          req,
          body,
        );
        break;

      case "update_last_time_seen_and_build_version":
        data_to_return_in_response =
          await update_last_time_seen_and_build_version(
            supabaseClient,
            req,
            body,
          );
        break;

      case "get_home_saving_accounts":
        data_to_return_in_response = await get_home_saving_accounts(
          supabaseClient,
          req,
        );
        break;

      case "get_limited_user_row_from_usercode":
        data_to_return_in_response = await get_limited_user_row_from_usercode(
          supabaseClient,
          body,
        );
        break;

      case "get_limited_user_row_from_userid":
        data_to_return_in_response = await get_limited_user_row_from_userid(
          supabaseClient,
          body,
        );
        break;

      case "send_money_via_qr_code":
        data_to_return_in_response = await send_money_via_qr_code(
          supabaseClient,
          req,
          body,
        );
        break;

      case "search_username":
        data_to_return_in_response = await search_username(
          supabaseClient,
          body,
          req,
        );
        break;

      // ====================== Savings Account Functions Getters

      case "get_my_shared_nas_account_transactions":
        data_to_return_in_response =
          await get_my_shared_nas_account_transactions(
            supabaseClient,
            req,
            body,
          );
        break;

      case "create_shared_no_access_savings_account":
        data_to_return_in_response =
          await create_shared_no_access_savings_account(
            supabaseClient,
            req,
            body,
          );
        break;

      case "search_username_in_db":
        data_to_return_in_response = await search_username_in_db(
          supabaseClient,
          req,
          body,
        );
        break;

      case "add_person_to_nas_account":
        data_to_return_in_response = await add_person_to_nas_account(
          supabaseClient,
          req,
          body,
        );
        break;

      case "extend_shared_nas_account_days":
        data_to_return_in_response = await extend_shared_nas_account_days(
          supabaseClient,
          req,
          body,
        );
        break;

      case "join_shared_nas_account":
        data_to_return_in_response = await join_shared_nas_account(
          supabaseClient,
          req,
          body,
        );
        break;

      case "donate_to_shared_nas_account":
        data_to_return_in_response = await donate_to_shared_nas_account(
          supabaseClient,
          req,
          body,
        );
        break;

      // ====================== Purchase Airtime

      case "purchase_airtime":
        data_to_return_in_response = await purchase_airtime(
          supabaseClient,
          req,
          body,
        );
        break;

      // ====================== Withdrawal Functions

      case "withdraw_funds":
        data_to_return_in_response = await withdraw_funds(
          supabaseClient,
          req,
          body,
        );
        break;

      // ====================== NFC Functions

      case "register_nfc_tag":
        data_to_return_in_response = await register_nfc_tag(
          supabaseClient,
          req,
          body,
        );
        break;

      case "get_my_registered_tags":
        data_to_return_in_response = await get_my_registered_tags(
          supabaseClient,
          req,
          body,
        );
        break;

      case "get_all_tags_transactions":
        data_to_return_in_response = await get_single_tag_transactions(
          supabaseClient,
          req,
          body,
        );
        break;

      case "get_single_tag_transactions":
        data_to_return_in_response = await get_single_tag_transactions(
          supabaseClient,
          req,
          body,
        );
        break;

      case "check_if_user_has_tags_registered":
        data_to_return_in_response = await check_if_user_has_tags_registered(
          supabaseClient,
          req,
        );
        break;

      case "check_if_tag_exists":
        data_to_return_in_response = await check_if_tag_exists(
          supabaseClient,
          req,
        );
        break;

      // ====================== Referral Functions

      case "get_my_referral_commissions":
        data_to_return_in_response = await get_my_referral_commissions(
          supabaseClient,
          req,
          body,
        );
        break;

      case "get_my_kyc_verification_records":
        data_to_return_in_response = await get_my_kyc_verification_records(
          supabaseClient,
          req,
          body,
        );
        break;

      // ====================== Payment Functions

      case "send_money_p2p":
        data_to_return_in_response = await send_money_p2p(
          supabaseClient,
          req,
          body,
        );
        break;

      case "send_money_with_time_limit":
        data_to_return_in_response = await send_money_with_time_limit(
          supabaseClient,
          req,
          body,
        );
        break;

      default:
    }

    return new Response(JSON.stringify({ data: data_to_return_in_response }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (e) {
    console.log("There was an error boss", e);

    return new Response(
      JSON.stringify({ data: "There was an error", errorMessage: e }),
      {
        headers: { "Content-Type": "application/json" },
        status: 400,
      },
    );
  }
});

// gets the user's user_id from the request header to enforce RLS policies
const get_auth_user_id = async (
  _req: Request,
  _supabaseClient: any,
): Promise<any> => {
  const token = _req.headers.get("Authorization")!.replace("Bearer ", "");

  const { data } = await _supabaseClient.auth.getUser(token);

  const user = data.user;

  if (user != null) {
    return user.id;
  } else {
    return null;
  }
};
// calls the currency exchange rate API and stores today's exchange rates
const get_daily_currency_exchange_rates = (_supabase: any) => {
  /*
        body preview:
        {
            "request_type": "get_todays_currency_exchange_rates",
        }
    */

  // calls the currency conversion API
  fetch(
    new Request(
      `https://openexchangerates.org/api/latest.json?app_id=5aaf7a6fe1304cd4ac12d86dbaa1b319`,
      {
        headers: {
          "content-type": "application/json",
        },
        method: "get",
      },
    ),
  ).then((response) => response.json()).then(async (data) => {
    console.log("The plain data is: ", data);

    // creates a daily record of today's currency exchange rates
    await _supabase.from("currency_exchange_rates").insert({
      "base_currency": data.base,
      "rates": data.rates,
    });
  }).catch(console.error);
};

// converts any amount (amount_to_convert) from one currency (from_currency) to another currency (to_currency)
const convert_currency = async (_supabase: any, _body: any): Promise<any> => {
  /*
        body preview:
        {
            "request_type": "convert_currency",
            "amount_to_convert": float,
            "from_currency": string,
            "to_currency": string,
        }
    */

  // gets a list of the stored exchange rates
  const stored_exchange_rates = await _supabase.from("currency_exchange_rates")
    .select().order("created_at", { ascending: false });

  // stores ONLY today's exchange rate row record
  const todays_rates_row = stored_exchange_rates["data"][0];

  // stores today's exchange rates as a json
  const todays_rates = todays_rates_row["rates"];

  // converts the amount_to_convert in from_currency to USD
  const usd_equivalent_of_amount_to_convert = _body.amount_to_convert /
    todays_rates[_body.from_currency];

  // converts the USD equivalent of the from_currency to the to_currency
  const final_converted_amount = usd_equivalent_of_amount_to_convert *
    todays_rates[_body.to_currency];

  return final_converted_amount;
};

// deletes an existing user account row
const delete_user_account = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<void> => {
  /*
        body preview:
        {
            "request_type": "delete_user_account",
            "deletion_reason": "string",
        }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the user's user account row
  const user_account_row = await _supabaseClient.from("users").select().eq(
    "user_id",
    user_id,
  );

  const account_row = user_account_row["data"][0];

  // creates a new record of the user's deleted account
  await _supabaseClient.from("users_deleted").insert({
    "date_joined": account_row["created_at"],
    ...account_row,
  });

  // deletes the user's record from the users table
  await _supabaseClient.from("users").delete().eq("user_id", user_id);
};

// deletes a specific user account row
const check_if_user_has_money_in_system_before_deletion = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        body preview:
        {
            "request_type": "check_if_user_has_money_in_system_before_deletion",
        }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status_code": 400,
      "status": "failed",
      "data": null,
    };
  } else {
    // gets the user's user account row
    const user_account_row = await _supabaseClient.from("users").select().eq(
      "user_id",
      user_id,
    );

    const savings_accounts = await _supabaseClient.from(
      "shared_no_access_savings_accounts",
    )
      .select()
      .eq("is_active", true)
      .neq("balance", 0)
      .contains("user_ids_able_to_view_accounts", [`${user_id}`]);

    const active_funded_nas_accs = savings_accounts["data"];

    const account_row = user_account_row["data"][0];

    return {
      "data": {
        "active_funded_nas_accs": active_funded_nas_accs,
        "user_account_row": account_row,
      },
      "message": "User has money in the system",
      "status": "success",
      "status_code": 200,
    };
  }
};

// ============================================================ Encryption Functions

// Utility: Convert between strings and ArrayBuffer
function encode(str: string): Uint8Array {
  return new TextEncoder().encode(str);
}

function decode(buf: Uint8Array): string {
  return new TextDecoder().decode(buf);
}

// Utility: Convert ArrayBuffer to Base64 and back
function toBase64(buffer: ArrayBuffer): string {
  return btoa(String.fromCharCode(...new Uint8Array(buffer)));
}

function fromBase64(base64: string): Uint8Array {
  return Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
}

// Generate a key from a passphrase (so you can reuse a string secret)
async function deriveKey(passphrase: string): Promise<CryptoKey> {
  const salt = encode("a_fixed_salt"); // You can customize or randomize
  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    encode(passphrase),
    "PBKDF2",
    false,
    ["deriveKey"],
  );

  return crypto.subtle.deriveKey(
    {
      name: "PBKDF2",
      salt,
      iterations: 100_000,
      hash: "SHA-256",
    },
    keyMaterial,
    { name: "AES-GCM", length: 256 },
    false,
    ["encrypt", "decrypt"],
  );
}

// Encrypt
export async function encrypt(
  plainText: string,
  secret: string,
): Promise<string> {
  const iv = crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV
  const key = await deriveKey(secret);
  const encrypted = await crypto.subtle.encrypt(
    { name: "AES-GCM", iv },
    key,
    encode(plainText),
  );

  // Combine IV + encrypted and return as base64
  const result = new Uint8Array(iv.length + encrypted.byteLength);
  result.set(iv);
  result.set(new Uint8Array(encrypted), iv.length);
  return toBase64(result.buffer);
}

// Decrypt
export async function decrypt(
  encryptedBase64: string,
  secret: string,
): Promise<string> {
  const data = fromBase64(encryptedBase64);
  const iv = data.slice(0, 12); // first 12 bytes
  const encrypted = data.slice(12);
  const key = await deriveKey(secret);
  const decrypted = await crypto.subtle.decrypt(
    { name: "AES-GCM", iv },
    key,
    encrypted,
  );
  return decode(new Uint8Array(decrypted));
}

// ============================================================ Security Functions

const create_pin_code = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "create_pin_code",
      "decrypted_pin_code": string
    }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  } else {
    const user_account_row = await _supabaseClient.from("users").update({
      "pin_code": _body["decrypted_pin_code"],
    }).eq(
      "user_id",
      user_id,
    );

    return {
      "message": "successfully updated the user's pin code",
      "status": "success",
      "status_code": 200,
      "data": {
        "user_account_row": user_account_row["data"][0],
      },
    };
  }
};

const check_if_pin_code_is_correct = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
  body preview
  {
    "request_type": "check_if_pin_code_is_correct",
    "pin_code": string
  }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // TODO add code to add rate limits here to prevent bruteforce attacks

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  } else {
    // Get user's account row
    const user_account_row = await _supabaseClient.from("users").select().eq(
      "user_id",
      user_id,
    );

    const user = user_account_row["data"][0];

    // Get user's decrypted pin code
    const decrypted_pin_code = _decrypt_pin_code(_supabaseClient, user, _req);

    if (_body["pin_code"] == decrypted_pin_code) {
      return {
        "message": "Correct pin code",
        "status": "success",
        "status_code": 200,
        "data": null,
      };
    } else {
      return {
        "message": "Incorrect pin code",
        "status": "failed",
        "status_code": 400,
        "data": null,
      };
    }
  }
};

const _decrypt_pin_code = async (
  _supabaseClient: any,
  _user: any,
  _req: Request,
): Promise<any> => {
};

const change_pin_code = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
  body preview
  {
    "request_type": "change_pin_code",
    "old_pin_code": string,
    "new_pin_code": string
  }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  } else {
    // Get user's current pin code
    const user_account_row = await _supabaseClient.from("users")
      .select()
      .eq("user_id", user_id);

    const user = user_account_row["data"][0];

    const decrypted_pin_code = _decrypt_pin_code(
      _supabaseClient,
      user,
      _req,
    );

    if (_body["old_pin_code"] != decrypted_pin_code) {
      return {
        "message": "Incorrect old pin code",
        "status": "failed",
        "status_code": 400,
        "data": null,
      };
    } else {
      // Update to new pin code
      await _supabaseClient.from("users")
        .update({
          "pin_code": _body["new_pin_code"],
        })
        .eq("user_id", user_id);

      return {
        "message": "PIN code changed successfully",
        "status": "success",
        "status_code": 200,
        "data": null,
      };
    }
  }
};

const reset_pin_code = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
    body preview
    {
      "any_previous_pin_code_used": string,
      "request_type": "reset_pin_code",
    }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  } else {
    // generate new temporary pin code
    const temporary_pin_code = await generate_temporary_pin_code(
      _supabaseClient,
    );

    // sends sms or email to user
    const result = await send_temporary_pin_code_to_user(
      _supabaseClient,
      temporary_pin_code,
    );

    if (result.status == "success") {
      // update user's pin code
      await _supabaseClient.from("users").update({
        "pin_code": temporary_pin_code,
      }).eq("user_id", user_id);

      return {
        "message": "PIN code reset successfully",
        "status": "success",
        "status_code": 200,
      };
    } else {
      return {
        "message": "PIN code reset failed",
        "status": "failed",
        "status_code": 400,
        "data": null,
      };
    }
  }
};

const generate_temporary_pin_code = async (
  _supabaseClient: any,
): Promise<any> => {
  return "1234";
};

const send_temporary_pin_code_to_user = async (
  _supabaseClient: any,
  _temporary_pin_code: any,
): Promise<any> => {
  // TODO add functionality to send temporary PIN via sms or email

  fetch(
    new Request(
      "https://api.emailjs.com/api/v1.0/email/send",
      {
        method: "POST",
        headers: {
          "origin": "http://localhost",
          "content-type": "application/json",
        },
        body: JSON.stringify({
          "user_id": _temporary_pin_code,
          "service_id": "your_service_id",
          "template_id": "your_template_id",
          "template_params": {
            "to_email": "recipient@email.com",
            "from_name": "Company Name",
            "from_email": "company@email.com",
            "user_subject": "Your temporary PIN",
            "to_name": "User Name",
            "message": `Your temporary PIN is: ${_temporary_pin_code}`,
          },
        }),
      },
    ),
  ).then((response) => response.json()).then(async (data) => {
    console.log("The plain data is: ", data);

    return {
      "message": "PIN code sent successfully",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  }).catch(console.error);

  // return {
  //   "message": "PIN code sent successfully",
  //   "status": "success",
  //   "status_code": 200,
  //   "data": null,
  // };
};

// ============================================================ Home Class Functions

const get_user_account = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_user_account",
      "get_app_wide_settings": true,
    }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the user's account row
  const user_data = await _supabaseClient.from("users").select().eq(
    "user_id",
    user_id,
  );

  if (_body["get_app_wide_settings"]) {
    const settings_data = await _supabaseClient.from(
      "appwide_admin_settings_private",
    )
      .select()
      .eq("record_name", "---- App Wide Settings ---")
      .eq("country", "Zambia");

    console.log(user_id);

    return {
      "message": "successfully got the user's account row",
      "status": "success",
      "status_code": 200,
      "data": {
        "app_wide_settings": settings_data[0],
        "user_data": user_data[0],
      },
    };
  } else {
    return {
      "message": "successfully got the user's account row",
      "status": "success",
      "status_code": 200,
      "data": {
        "app_wide_settings": null,
        "user_data": user_data[0],
      },
    };
  }
};

const get_all_users_transactions = async (
  _supabaseClient: any,
  _req: Request,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_all_users_transactions",
    }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  const res = await _supabaseClient.from("transactions").select()
    .eq(
      "user_id",
      user_id,
    ).order("created_at", { ascending: false });

  return {
    "message": "successfully got the user's transactions",
    "status": "success",
    "status_code": 200,
    "data": res["data"],
  };
};

// gets the 5 or less transactions that are displated in the app's home page
const get_users_home_page_transactions = async (
  _supabaseClient: any,
  _req: Request,
): Promise<any> => {
  /*
  body preview
  {
    "request_type": "get_users_home_page_transactions",
  }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  let transactions_to_return = [];

  try {
    const res = await _supabaseClient.from("transactions").select()
      .limit(5)
      .eq(
        "user_id",
        user_id,
      ).order("created_at", { ascending: false });

    transactions_to_return = res["data"];
  } catch (_) {
    const res = await _supabaseClient.from("transactions").select()
      .eq(
        "user_id",
        user_id,
      ).order("created_at", { ascending: false });

    transactions_to_return = res["data"];
  }

  return {
    "message": "successfully got the user's transactions",
    "status": "success",
    "status_code": 200,
    "data": transactions_to_return,
  };
};

const get_home_saving_accounts = async (
  _supabaseClient: any,
  _req: Request,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_home_saving_accounts",
    }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the shared supabase no access accounts
  const shared_nas_acocounts = await _supabaseClient
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("is_active", true)
    .contains("user_ids_able_to_view_accounts", [`${user_id}`]).order(
      "created_at",
      { ascending: false },
    );

  const top_20_nas_accounts = await _supabaseClient
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("is_active", true)
    .limit(20)
    .order("balance", { ascending: false });

  return {
    "message": "successfully got the user's shared no access savings accounts",
    "status": "success",
    "status_code": 200,
    "data": {
      "shared_nas_acocounts": shared_nas_acocounts["data"],
      "top_20_nas_accounts": top_20_nas_accounts["data"],
    },
  };
};

// updates the user's profile image url
const update_profile_image_url = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        body preview:
        {
            "request_type": "delete_user_account",
            "profile_image_url": "string",
        }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // updates the user's user account row
  await _supabaseClient.from("users").update({
    "profile_image_url": _body["profile_image_url"],
  }).eq(
    "user_id",
    user_id,
  );

  const shared_nas_accounts = await _supabaseClient
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("is_active", true)
    .contains("user_ids_able_to_view_accounts", [`${user_id}`]);

  let operations_to_run = [];

  // gets the user's current user record row
  const user_result = await _supabaseClient.from("users").select().eq(
    "user_id",
    user_id,
  );

  for (var i = 0; i < shared_nas_accounts.length; i++) {
    // gets a list of all the existing acc bal shares
    const existing_list_of_account_bal_shares =
      shared_nas_accounts[i]["account_balance_shares"];

    // gets the user's existing acc bal share map's index
    const index: number = existing_list_of_account_bal_shares.findIndex((
      map: any,
    ) => map["user_id"] == user_id);

    // gets user's the existing acc bal share map
    const existing_account_bal_share_map =
      existing_list_of_account_bal_shares[index];

    // removes the user's existing acc bal share map from list
    existing_list_of_account_bal_shares.splice(index, 1);

    // the user's updated acc bal share map
    const new_account_bal_share_map = {
      "user_is_kyc_verified": user_result[0]["account_kyc_is_verified"],
      "date_user_joined_account":
        existing_account_bal_share_map["date_user_joined_account"],
      "date_user_last_deposited":
        existing_account_bal_share_map["date_user_last_deposited"],
      "number_of_deposits_made":
        existing_account_bal_share_map["number_of_deposits_made"],
      "notification_token": user_result[0]["notification_token"],
      "balance": existing_account_bal_share_map["balance"],
      "currency_symbol": user_result[0]["currency_symbol"],
      "names": existing_account_bal_share_map["names"],
      "profile_image_url": _body["profile_image_url"],
      "currency": user_result[0]["currency"],
      "country": user_result[0]["country"],
      "user_id": user_id,
    };

    // updates the NAS account's row
    operations_to_run.push(
      _supabaseClient.from("shared_no_access_savings_accounts").update({
        "account_balance_shares": [
          ...existing_list_of_account_bal_shares,
          new_account_bal_share_map,
        ],
      }).eq("account_id", shared_nas_accounts[i]["account_id"]),
    );
  }

  // runs all the operations at once
  await Promise.all(operations_to_run);

  return {
    "message": "successfully updated user's profile picture",
    "status": "success",
    "status_code": 200,
    "data": null,
  };
};

// updates the users device id & ip address
const update_device_id_and_ip_address = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        body preview:
        {
          "request_type": "update_device_id_and_ip_address",
          "new_device_ip_address": string,
          "new_device_id": string
        }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // updates the user's user account row
  await _supabaseClient.from("users").update({
    "current_device_ip_address": _body["new_device_ip_address"],
    "last_time_online_timestamp": new Date().toISOString(),
    "current_device_id": _body["new_device_id"],
  }).eq(
    "user_id",
    user_id,
  );

  return {
    "message": "successfully updated device id and ip address",
    "status": "success",
    "status_code": 200,
    "data": null,
  };
};

// updates the users last seen timestamp and build version
const update_last_time_seen_and_build_version = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        body preview:
        {
          "request_type": "update_last_time_seen_and_build_version",
          "current_build_version": string,
          "current_platform_os": string,
        }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // updates the user's user account row
  await _supabaseClient.from("users").update({
    "current_build_version": _body["current_build_version"],
    "last_time_online_timestamp": new Date().toISOString(),
    "current_os_platform": _body["current_os_platform"],
  }).eq(
    "user_id",
    user_id,
  );

  return {
    "message": "successfully updated user last seen timestamp & build version",
    "status": "success",
    "status_code": 200,
    "data": null,
  };
};

// updates the user's notification token
const update_user_notification_token = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        body preview:
        {
            "request_type": "update_user_notification_token",
            "notification_token": "string",
        }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the user's user account row
  await _supabaseClient.from("users").update({
    "last_time_online_timestamp": new Date().toISOString(),
    "notification_token": _body["notification_token"],
  }).eq(
    "user_id",
    user_id,
  );

  // gets the current savings accounts
  const result = await _supabaseClient
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("is_active", true)
    .contains("user_ids_able_to_view_accounts", [`${user_id}`]);

  if (result.length == 0) return;

  let operations_to_run = [];

  // for reach NAS account, it updates the token
  for (let i = 0; i < result["data"].length; i++) {
    const existing_list_of_account_bal_shares =
      result["data"][i]["account_balance_shares"];

    // gets the user's existing acc bal share map's index
    const index: number = existing_list_of_account_bal_shares.findIndex((
      map: any,
    ) => map["user_id"] == user_id);

    // gets user's the existing acc bal share map
    const existing_account_bal_share_map =
      existing_list_of_account_bal_shares[index];

    // removes the user's existing acc bal share map from list
    existing_list_of_account_bal_shares.splice(index, 1);

    // the user's updated acc bal share map
    const new_account_bal_share_map = {
      "profile_image_url": existing_account_bal_share_map["profile_image_url"],
      "currency_symbol": existing_account_bal_share_map["currency_symbol"],
      "date_user_joined_account":
        existing_account_bal_share_map["date_user_joined_account"],
      "date_user_last_deposited":
        existing_account_bal_share_map["date_user_last_deposited"],
      "number_of_deposits_made":
        existing_account_bal_share_map["number_of_deposits_made"],
      "user_is_kyc_verified":
        existing_account_bal_share_map["user_is_kyc_verified"],
      "currency": existing_account_bal_share_map["currency"],
      "country": existing_account_bal_share_map["country"],
      "balance": existing_account_bal_share_map["balance"],
      "user_id": existing_account_bal_share_map["user_id"],
      "names": existing_account_bal_share_map["names"],
      "notification_token": _body["notification_token"],
    };

    operations_to_run.push(
      _supabaseClient.from("shared_no_access_savings_accounts").update({
        "account_balance_shares": [
          ...existing_list_of_account_bal_shares,
          new_account_bal_share_map,
        ],
      }).eq("account_id", result["data"][i]["account_id"]),
    );
  }

  // updates all savings accounts all at once
  await Promise.all(operations_to_run);

  return {
    "message": "successfully updated the user's notification tokens",
    "status": "success",
    "status_code": 200,
    "data": null,
  };
};

// updates the value of the show update alert
const update_show_update_alert = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        body preview:
        {
          "request_type": "update_show_update_alert",
          "new_value": boolean,
          "user_id": string
        }
    */

  // gets the user's id from the request
  // const user_id = await get_auth_user_id(_req, _supabaseClient);

  // updates the user's user account row
  await _supabaseClient.from("users").update({
    "show_update_alert": _body["new_value"],
  }).eq(
    "user_id",
    _body["user_id"],
  );

  return {
    "message": "successfully updated the show update alert value",
    "status": "success",
    "status_code": 200,
    "data": {
      "new_value": _body["new_value"],
      "user_id": _body["user_id"],
    },
  };
};

const check_if_app_is_upto_date = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        body preview:
        {
          "request_type": "check_if_app_is_upto_date",
          "current_build_version": string
        }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  const app_wide_settings = await _supabaseClient.from(
    "app_wide_settings_private",
  ).select().eq("record_name", "---- App Wide Settings ---").eq(
    "country",
    "Zambia",
  );

  if (
    app_wide_settings[0]["record_contents"][
      "current_most_recent_client_app_build_version"
    ] != _body["current_build_version"]
  ) {
    return {
      "message": "App is not up to date",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // gets the user's user account row
  const user_account_row = await _supabaseClient.from("users").update({
    "show_update_alert": false,
  }).eq(
    "user_id",
    user_id,
  );

  const user_row = user_account_row["data"][0];

  return {
    "message": "successfully got the user's account row",
    "status": "success",
    "status_code": 200,
    "data": {
      "show_update_alert": user_row["show_update_alert"],
      "current_build_version": user_row["current_build_version"],
    },
  };
};

const upvote_an_existing_feedback_submission = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "upvote_an_existing_feedback_submission",
      "submission_id": string,
    }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  } else {
    // gets the user's user account row
    const user_results = await _supabaseClient.from("users").select().eq(
      "user_id",
      user_id,
    );

    const user_row = user_results["data"][0];

    // gets a specific feedback submission using an ID
    const res = await _supabaseClient.from("feedback_submitted").select().eq(
      "submission_id",
      _body["submission_id"],
    );

    const feedback_row = res["data"][0];

    // stores the new upvote count
    const new_upvote_count = feedback_row["number_of_upvotes"] + 1;

    // if user has already upvoted the submission
    const hasUpvoted = feedback_row["users_who_upvoted"].some((user: any) =>
      user.user_id == user_id
    ) ?? false;

    if (hasUpvoted) {
      const date_today = new Date().toISOString();
      // updates the submission's upvote count
      await _supabaseClient.from("feedback_submitted").update({
        "users_who_upvoted": [
          {
            "current_build_version": user_row["current_build_version"],
            "current_platform_os": user_row["current_platform_os"],
            "profile_image_url": user_row["profile_image_url"],
            "first_name": user_row["first_name"],
            "last_name": user_row["last_name"],
            "date_upvoted": date_today,
            "user_id": user_id,
          },
          ...feedback_row["users_who_upvoted"],
        ],
        "number_of_upvotes": new_upvote_count,
      }).eq("submission_id", _body["submission_id"]);
    }

    return {
      "message": "successfully upvoted a feedback submission",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  }
};

const get_feedback_submissions = async (
  _supabaseClient: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_feedback_submissions",
    }
  */

  // gets a list of the app's current feedback submissions
  const res = await _supabaseClient.from("feedback_submitted").select().eq(
    "is_published",
    true,
  ).order("number_of_upvotes", { ascending: false });

  return res["data"];
};

const create_a_feedback_submission = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "create_a_feedback_submission",
      "submission_details": map
    }
  */

  const details = _body.submission_details;

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  } else {
    // gets a list of the app's current feedback submissions
    const res = await _supabaseClient.from("feedback_submitted").insert({
      "users_who_upvoted": [
        {
          "current_build_version":
            details["users_who_upvoted"][0]["current_build_version"],
          "current_platform_os":
            details["users_who_upvoted"][0]["current_platform_os"],
          "profile_image_url":
            details["users_who_upvoted"][0]["profile_image_url"],
          "date_upvoted": details["users_who_upvoted"][0]["date_upvoted"],
          "first_name": details["users_who_upvoted"][0]["first_name"],
          "last_name": details["users_who_upvoted"][0]["last_name"],
          "user_id": user_id,
        },
      ],
      "creator_current_build_version": details["creator_current_build_version"],
      "creator_details": {
        "profile_image_url": details["creator_details"]["profile_image_url"],
        "first_name": details["creator_details"]["first_name"],
        "last_name": details["creator_details"]["last_name"],
        "user_id": user_id,
      },
      "creator_platform_os": details["creator_platform_os"],
      "submission_type": details["submission_type"],
      "submission_text": details["submission_text"],
      "is_attended_to_by_admin": false,
      "number_of_downvotes": 0,
      "date_completed": null,
      "number_of_upvotes": 1,
      "is_published": true,
      "admin_comment": "",
      "user_id": user_id,
    });

    return {
      "message": "successfully created a feedback submission",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  }
};

const get_terms_of_service = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_terms_of_service",
      "kind_of_tos_to_get": string
    }
  */

  fetch(
    new Request(
      "https://us-central1-jayben-de41c.cloudfunctions.net/auth/getTOS",
      {
        method: "POST",
        headers: {
          "origin": "http://localhost",
          "content-type": "application/json",
        },
        body: JSON.stringify({}),
      },
    ),
  ).then((response) => response.json()).then(async (data) => {
    console.log("The plain data is: ", data);

    return {
      "message": "PIN code sent successfully",
      "status": "success",
      "status_code": 200,
      "data": {
        "content": data,
      },
    };
  }).catch((error) => {
    console.log("Error fetching terms of service:", error);

    return {
      "message": "Failed to get terms of service",
      "status": "failed",
      "status_code": 400,
      "data": {
        "content": "Not available, please contact Jayben support",
      },
    };
  });
};
// ============================================================ Payment Functions

// gets a list of user rows that have the username
const search_username = async (
  _supabase: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
  body preview
  {
    "request_type": "search_username",
    "username": string
  }
  */

  const user_id = await get_auth_user_id(_req, _supabase);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  const username_search_results = await _supabase
    .from("users")
    .select()
    .ilike("username_searchable", `%${_body["username"].toLowerCase()}%`);

  console.log(username_search_results);

  return {
    "message": "successfully searched for username",
    "data": username_search_results.data,
    "status": "success",
    "status_code": 200,
  };
};

// sends money p2p between two users with optional timeline post
const send_money_p2p = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "send_money_p2p",
      "receiver_user_id": string,
      "post_is_public": boolean,
      "media_details": [{
        "media_type": string,
        "media_caption": string,
        "post_type": string,
        "thumbnail_url": string,
        "aspect_ratio": number,
        "media_url": string
      }],
      "comment": string,
      "amount": number
    }
  */

  const appwide_admin_settings = await _supabaseClient.from(
    "appwide_admin_settings",
  )
    .select()
    .eq("record_name", "--- Timeline Settings ---");

  const default_timeline_privacy_setting = appwide_admin_settings["data"][0][
    "default_privacy_post_to_timeline_setting"
  ];

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // Get sender and receiver accounts
  const [sender, receiver] = await Promise.all([
    _supabaseClient.from("users").select().eq("user_id", user_id).single(),
    _supabaseClient.from("users").select().eq("user_id", _body.receiver_user_id)
      .single(),
  ]);

  if (!receiver.data) {
    return {
      "message": "Recipient not found",
      "status": "failed",
      "status_code": 404,
      "data": null,
    };
  }

  if (sender.data.balance < _body.amount) {
    // Send insufficient funds notification
    await _supabaseClient.rpc("send_notifications_via_firebase", {
      body: "You have insufficient balance to conduct this transfer.",
      notification_tokens: [sender.data.notification_token],
      title: "Transfer Declined",
    });

    return {
      "message": "Insufficient balance",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  const transaction_id = crypto.randomUUID();
  const receiver_transaction_id = crypto.randomUUID();

  try {
    // Create transaction records and update balances
    await Promise.all([
      // Create sender transaction
      _supabaseClient.from("transactions").insert({
        transaction_id: transaction_id,
        user_id: user_id,
        amount: _body.amount,
        comment: _body.comment,
        sent_received: "Sent",
        transaction_type: "Transfer",
        method: "Wallet transfer",
        status: "Completed",
        p2p_recipient_details: {
          user_id: receiver.data.user_id,
          recipient_wallet_balance_after_transaction: receiver.data.balance +
            _body.amount,
          recipient_wallet_balance_before_transaction: receiver.data.balance,
          phone_number: receiver.data.phone_number,
          full_names: `${receiver.data.first_name} ${receiver.data.last_name}`,
        },
        description:
          `To ${receiver.data.first_name} ${receiver.data.last_name}`,
        wallet_balance_details: {
          wallet_balance_after_transaction: sender.data.balance - _body.amount,
          wallet_balance_before_transaction: sender.data.balance,
          wallet_balances_difference: _body.amount,
          transaction_fee_amount: 0,
        },
        currency: sender.data.currency,
        currency_symbol: sender.data.currency_symbol,
        country: sender.data.country,
        is_public: _body.post_is_public,
        user_is_verified: sender.data.account_kyc_is_verified,
        full_names: `${sender.data.first_name} ${sender.data.last_name}`,
      }),

      // Create receiver transaction
      _supabaseClient.from("transactions").insert({
        transaction_id: receiver_transaction_id,
        user_id: receiver.data.user_id,
        amount: _body.amount,
        comment: _body.comment,
        sent_received: "Received",
        transaction_type: "Transfer",
        method: "Wallet transfer",
        status: "Completed",
        p2p_sender_details: {
          user_id: sender.data.user_id,
          senders_wallet_balance_after_transaction: sender.data.balance -
            _body.amount,
          senders_wallet_balance_before_transaction: sender.data.balance,
          phone_number: sender.data.phone_number,
          full_names: `${sender.data.first_name} ${sender.data.last_name}`,
        },
        description: `From ${sender.data.first_name} ${sender.data.last_name}`,
        wallet_balance_details: {
          wallet_balance_after_transaction: receiver.data.balance +
            _body.amount,
          wallet_balance_before_transaction: receiver.data.balance,
          wallet_balances_difference: _body.amount,
          transaction_fee_amount: 0,
        },
        currency: receiver.data.currency,
        currency_symbol: receiver.data.currency_symbol,
        country: receiver.data.country,
        is_public: _body.post_is_public,
        user_is_verified: receiver.data.account_kyc_is_verified,
        full_names: `${receiver.data.first_name} ${receiver.data.last_name}`,
      }),

      // Update sender balance
      _supabaseClient
        .from("users")
        .update({ balance: sender.data.balance - _body.amount })
        .eq("user_id", user_id),

      // Update receiver balance
      _supabaseClient
        .from("users")
        .update({ balance: receiver.data.balance + _body.amount })
        .eq("user_id", receiver.data.user_id),

      // Send notifications
      _supabaseClient.rpc("send_notifications_via_firebase", {
        body:
          `You sent ${sender.data.currency_symbol}${_body.amount} to ${receiver.data.first_name}`,
        notification_tokens: [sender.data.notification_token],
        title: "Money Sent ✅",
      }),

      _supabaseClient.rpc("send_notifications_via_firebase", {
        body:
          `You received ${receiver.data.currency_symbol}${_body.amount} from ${sender.data.first_name}`,
        notification_tokens: [receiver.data.notification_token],
        title: "Money Received 💰",
      }),
    ]);

    // Create timeline post if public
    if (_body.post_is_public) {
      await add_post_to_contacts(_supabaseClient, {
        media_details: _body.media_details,
        transaction_id: transaction_id,
        user_id: user_id,
      });
    }

    return {
      "message": "Transfer successful",
      "status": "success",
      "status_code": 200,
      "data": {
        transaction_id: transaction_id,
      },
    };
  } catch (error) {
    console.error("Transfer failed:", error);

    return {
      "message": "Transfer failed",
      "status": "failed",
      "status_code": 500,
      "data": null,
    };
  }
};

// sends money with a time delay before recipient can access
const send_money_with_time_limit = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      request_type: "send_money_with_time_limit",
      receiver_user_id: string,
      days_until_release: number,
      comment: string,
      amount: float
    }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // Get sender and receiver accounts
  const [sender, receiver] = await Promise.all([
    _supabaseClient.from("users").select().eq("user_id", user_id).single(),
    _supabaseClient.from("users").select().eq("user_id", _body.receiver_user_id)
      .single(),
  ]);

  if (!receiver.data) {
    return {
      "message": "Recipient not found",
      "status": "failed",
      "status_code": 404,
      "data": null,
    };
  }

  if (sender.data.balance < _body.amount) {
    return {
      "message": "Insufficient balance",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  const transaction_id = crypto.randomUUID();
  const release_date = new Date();
  release_date.setDate(release_date.getDate() + _body.days_until_release);

  // Create time-locked transaction records and update sender balance
  await Promise.all([
    // Create sender transaction
    _supabaseClient.from("time_locked_transactions").insert({
      transaction_id: transaction_id,
      user_id: user_id,
      amount: _body.amount,
      comment: _body.comment,
      sent_received: "Sent",
      transaction_type: "Time-Locked Transfer",
      method: "Wallet transfer",
      status: "Pending",
      recipient_details: {
        user_id: receiver.data.user_id,
        full_name: `${receiver.data.first_name} ${receiver.data.last_name}`,
        phone_number: receiver.data.phone_number,
      },
      currency: sender.data.currency,
      currency_symbol: sender.data.currency_symbol,
      release_date: release_date.toISOString(),
      days_until_release: _body.days_until_release,
      has_expired: false,
    }),

    // Create receiver transaction
    _supabaseClient.from("time_locked_transactions").insert({
      transaction_id: crypto.randomUUID(),
      user_id: receiver.data.user_id,
      amount: _body.amount,
      comment: _body.comment,
      sent_received: "Received",
      transaction_type: "Time-Locked Transfer",
      method: "Wallet transfer",
      status: "Pending",
      sender_details: {
        user_id: user_id,
        full_name: `${sender.data.first_name} ${sender.data.last_name}`,
        phone_number: sender.data.phone_number,
      },
      currency: receiver.data.currency,
      currency_symbol: receiver.data.currency_symbol,
      release_date: release_date.toISOString(),
      days_until_release: _body.days_until_release,
      has_expired: false,
    }),

    // Update sender balance
    _supabaseClient
      .from("users")
      .update({ balance: sender.data.balance - _body.amount })
      .eq("user_id", user_id),

    // Send notifications
    _supabaseClient.rpc("send_notifications_via_firebase", {
      body:
        `You sent ${sender.data.currency_symbol}${_body.amount} to ${receiver.data.first_name} (locked for ${_body.days_until_release} days)`,
      notification_tokens: [sender.data.notification_token],
      title: "Time-Locked Transfer Sent ⏳",
    }),

    _supabaseClient.rpc("send_notifications_via_firebase", {
      body:
        `You will receive ${receiver.data.currency_symbol}${_body.amount} from ${sender.data.first_name} in ${_body.days_until_release} days`,
      notification_tokens: [receiver.data.notification_token],
      title: "Time-Locked Transfer Received ⏳",
    }),
  ]);

  return {
    "message": "Time-locked transfer created successfully",
    "status": "success",
    "status_code": 200,
    "data": {
      transaction_id: transaction_id,
      release_date: release_date.toISOString(),
    },
  };
};

// ============================================================ Withdraw Functions

// handles mobile money withdrawals by users
const withdraw_funds = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "amount_to_withdraw_minus_fee": number,
      "amount_to_withdraw_plus_fee": number,
      "transaction_fee_currency": string,
      "request_type": "withdraw_funds",
      "transaction_fee_amount": number,
      "phone_number": string,
      "reference": string,
      "method": string
    }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // Get user's account details
  const user_result = await _supabaseClient
    .from("users")
    .select()
    .eq("user_id", user_id)
    .single();

  const user = user_result.data;

  const transaction_id = crypto.randomUUID();

  const appwide_settings = await _supabaseClient.from("appwide_admin_settings")
    .select().eq("record_name", "---- Withdrawal Settings ----");

  const withdraw_record_contents = appwide_settings["data"][0];

  // Check if user has sufficient balance
  if (user.balance >= _body.amount_to_withdraw_plus_fee) {
    try {
      // Create transaction record
      await _supabaseClient.from("transactions").insert({
        transaction_fee_details: {
          transaction_total_fee_percentage:
            withdraw_record_contents.withdraw_fee_percentage,
          transaction_fee_amount: _body.transaction_fee_amount,
          transaction_international_bank_tranfer_fee: "",
          transaction_total_fee_currency: user.currency,
          transcation_bank_transfer_fee_currency: "",
          transaction_local_bank_tranfer_fee: "",
        },
        wallet_balance_details: {
          wallet_balance_after_transaction: user.balance -
            _body.amount_to_withdraw_plus_fee,
          wallet_balances_difference: _body.amount_to_withdraw_minus_fee,
          rule: "balance before must be larger than balance after",
          transaction_fee_amount: _body.transaction_fee_amount,
          wallet_balance_before_transaction: user.balance,
        },
        withdrawal_details: {
          withdraw_amount_to_send_to_method: _body.amount_to_withdraw_minus_fee,
          withdraw_amount_minus_fee: _body.amount_to_withdraw_minus_fee,
          withdraw_amount_plus_fee: _body.amount_to_withdraw_plus_fee,
          picked_withdraw_method: _body.method,
          phone_number: _body.phone_number,
          bank_account_holder_name: "",
          reference: _body.reference,
          bank_routing_number: "",
          bank_account_number: "",
          bank_swift_code: "",
          bank_sort_code: "",
          bank_address: "",
          bank_country: "",
          bank_branch: "",
          bank_name: "",
        },
        description: `To ${_body.phone_number} ${_body.reference}`,
        full_names: `${user.first_name} ${user.last_name}`,
        user_is_verified: user.account_kyc_is_verified,
        amount: _body.amount_to_withdraw_minus_fee,
        currency_symbol: user.currency_symbol,
        transaction_type: "Withdrawal",
        transaction_id: transaction_id,
        savings_account_details: null,
        p2p_recipient_details: null,
        p2p_sender_details: null,
        currency: user.currency,
        country: user.country,
        deposit_details: null,
        sent_received: "Sent",
        number_of_replies: 0,
        method: _body.method,
        number_of_views: 0,
        number_of_likes: 0,
        attended_to: false,
        status: "Pending",
        is_public: false,
        user_id: user_id,
        comment: "",
      });

      const fraud_check_response = await fetch(
        new Request(
          "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/check_for_fraudulent_transactions",
          {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${Deno.env.get("SUPABASE_ANON_KEY")}`,
              "content-type": "application/json",
            },
            body: JSON.stringify({
              user_id: user_id,
            }),
          },
        ),
      );

      const fraud_check = await fraud_check_response.json();

      if (
        fraud_check.data ==
          "Everything looks good boss. No fraudulent activity detected."
      ) {
        // Update user balance
        await _supabaseClient
          .from("users")
          .update({
            balance: user.balance - _body.amount_to_withdraw_plus_fee,
          })
          .eq("user_id", user_id);

        // Send notification to user
        await _supabaseClient.rpc("send_notifications_via_firebase", {
          body:
            `You have withdrawn ${user.currency_symbol}${_body.amount_to_withdraw_minus_fee} to ${_body.method}. It will be processed shortly, please be patient.`,
          notification_tokens: [user.notification_token],
          title: "Withdrawal Submitted",
        });

        // Send SMS to admin
        // TODO: Implement SMS sending functionality

        return {
          "message": "Withdrawal submitted successfully",
          "status": "success",
          "status_code": 200,
          "data": {
            transaction_id: transaction_id,
          },
        };
      } else {
        // Flag transaction and put account on hold
        await Promise.all([
          _supabaseClient
            .from("transactions")
            .update({ status: "Flagged" })
            .eq("transaction_id", transaction_id),

          _supabaseClient
            .from("users")
            .update({ account_is_on_hold: true })
            .eq("user_id", user_id),

          _supabaseClient.rpc("send_notifications_via_firebase", {
            body:
              "Your withdrawal has been flagged. Please contact customer support.",
            notification_tokens: [user.notification_token],
            title: "Withdrawal Flagged 🚩",
          }),
        ]);

        return {
          "message": "Withdrawal flagged for suspicious activity",
          "status": "failed",
          "status_code": 400,
          "data": null,
        };
      }
    } catch (error) {
      console.error("Withdrawal error:", error);

      return {
        "message": "Error processing withdrawal",
        "status": "failed",
        "status_code": 500,
        "data": null,
      };
    }
  } else {
    await _supabaseClient.rpc("send_notifications_via_firebase", {
      body: "You have insufficient balance to conduct this withdrawal.",
      notification_tokens: [user.notification_token],
      title: "Withdrawal Declined",
    });

    return {
      "message": "Insufficient balance",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// ============================================================ Airtime Functions

// handles airtime purchases by users
const purchase_airtime = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "purchase_airtime",
      "method_of_purchase": string,
      "post_is_public": boolean,
      "media_details": [{
        "media_caption": string,
        "thumbnail_url": string,
        "aspect_ratio": number,
        "media_type": string,
        "post_type": string,
        "media_url": string
      }],
      "phone_number": string,
      "currency": string,
      "comment": string,
      "amount": number,
    }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // Get user's account details
  const user_result = await _supabaseClient
    .from("users")
    .select()
    .eq("user_id", user_id)
    .single();

  const user = user_result.data;

  // Check if user has sufficient balance
  if (user.balance < _body.amount) {
    await _supabaseClient.rpc("send_notifications_via_firebase", {
      body: "Insufficient balance for airtime purchase",
      notification_tokens: [user.notification_token],
      title: "Airtime Purchase Failed",
    });

    return {
      "message": "Insufficient balance",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  const transaction_id = crypto.randomUUID();

  try {
    // Call Africa's Talking API to purchase airtime
    const at_response = await fetch(
      "https://api.africastalking.com/version1/airtime/send",
      {
        method: "POST",
        headers: {
          "apiKey": Deno.env.get("AFRICASTALKING_API_KEY") ?? "",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: JSON.stringify({
          username: Deno.env.get("AFRICASTALKING_USERNAME"),
          recipients: [{
            phoneNumber: `+${_body.phone_number}`,
            currency: _body.currency,
            amount: _body.amount,
          }],
        }),
      },
    );

    const at_result = await at_response.json();

    if (at_result.errorMessage == "None") {
      if (_body["method_of_purchase"] == "cash") {
        // Update user balance
        await _supabaseClient
          .from("users")
          .update({
            balance: user.balance - _body.amount,
          })
          .eq("user_id", user_id);

        // Create transaction record
        await _supabaseClient
          .from("transactions")
          .insert({
            wallet_balance_details: {
              wallet_balance_before_transaction: user.balance,
              wallet_balance_after_transaction: user.balance -
                _body.amount,
              wallet_balances_difference: _body.amount,
            },
            full_names: `${user.first_name} ${user.last_name}`,
            user_is_verified: user.account_kyc_is_verified,
            description: `For +${_body.phone_number}`,
            currency_symbol: user.currency_symbol,
            transaction_type: "Airtime Purchase",
            is_public: _body.post_is_public,
            transaction_id: transaction_id,
            savings_account_details: null,
            transaction_fee_details: null,
            p2p_receipient_details: null,
            method: "Wallet transfer",
            p2p_sender_details: null,
            withdrawal_details: null,
            currency: user.currency,
            comment: _body.comment,
            country: user.country,
            sent_received: "Sent",
            deposit_details: null,
            amount: _body.amount,
            number_of_replies: 0,
            status: "Completed",
            number_of_views: 0,
            number_of_likes: 0,
            attended_to: false,
            user_id: user_id,
          });

        // Send success notification
        await _supabaseClient.rpc("send_notifications_via_firebase", {
          body:
            `Airtime purchase of ${user.currency_symbol}${_body.amount} to +${_body.phone_number} was successful`,
          notification_tokens: [user.notification_token],
          title: "Airtime Purchase Successful 🎉",
        });

        return {
          "message": "Airtime purchase successful",
          "status": "success",
          "status_code": 200,
          "data": {
            transaction_id: transaction_id,
          },
        };
      } else {
        // TODO implement current price per point and then deduct that price from their points.

        await complete_airtime_purchase_via_points(
          _supabaseClient,
          _body,
          user,
          user_id,
          transaction_id,
        );
      }
    } else {
      // Handle Africa's Talking API error
      await _supabaseClient.rpc("send_notifications_via_firebase", {
        body: "Airtime purchase failed. Please try again later.",
        notification_tokens: [user.notification_token],
        title: "Purchase Failed",
      });

      // Log error
      // await _supabaseClient
      //   .from("error_logs")
      //   .insert({
      //     error_type: "Airtime Purchase",
      //     error_details: at_result,
      //     user_id: user_id,
      //   });

      return {
        "message": "Airtime purchase failed",
        "status": "failed",
        "status_code": 400,
        "data": null,
      };
    }
  } catch (error) {
    console.error("Airtime purchase error:", error);

    await _supabaseClient.rpc("send_notifications_via_firebase", {
      body:
        "An error occurred during airtime purchase. Please try again later.",
      notification_tokens: [user.notification_token],
      title: "Purchase Error",
    });

    return {
      "message": "Error processing airtime purchase",
      "status": "failed",
      "status_code": 500,
      "data": null,
    };
  }
};

const complete_airtime_purchase_via_points = async (
  _supabaseClient: any,
  _body: any,
  _user: any,
  _user_id: any,
  _tranx_id: any,
): Promise<any> => {
  // Create transaction record
  await _supabaseClient
    .from("transactions")
    .insert({
      wallet_balance_details: {
        wallet_balance_before_transaction: _user.balance,
        wallet_balance_after_transaction: _user.balance -
          _body.amount,
        wallet_balances_difference: _body.amount,
      },
      full_names: `${_user.first_name} ${_user.last_name}`,
      user_is_verified: _user.account_kyc_is_verified,
      description: `For +${_body.phone_number}`,
      currency_symbol: _user.currency_symbol,
      transaction_type: "Airtime Purchase",
      is_public: _body.post_is_public,
      transaction_id: _tranx_id,
      savings_account_details: null,
      transaction_fee_details: null,
      p2p_receipient_details: null,
      method: "Wallet transfer",
      p2p_sender_details: null,
      withdrawal_details: null,
      currency: _user.currency,
      comment: _body.comment,
      country: _user.country,
      sent_received: "Sent",
      deposit_details: null,
      amount: _body.amount,
      number_of_replies: 0,
      status: "Completed",
      number_of_views: 0,
      number_of_likes: 0,
      attended_to: false,
      user_id: _user_id,
    });

  // Send success notification
  await _supabaseClient.rpc("send_notifications_via_firebase", {
    body:
      `Airtime purchase of ${_user.currency_symbol}${_body.amount} to +${_body.phone_number} was successful`,
    notification_tokens: [_user.notification_token],
    title: "Airtime Purchase Successful 🎉",
  });

  return {
    "message": "Airtime purchase successful",
    "status": "success",
    "status_code": 200,
    "data": {
      transaction_id: _tranx_id,
    },
  };
};

// ============================================================ Timeline Functions

// gets a feed of timeline posts for a user
const getFeedTransactions = async (
  _supabaseClient: any,
  _req: Request,
): Promise<any> => {
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  try {
    const feed = await _supabaseClient
      .from("timeline_posts")
      .select()
      .eq("user_id", user_id)
      .neq("post_owner_user_id", user_id)
      .order("created_at", { ascending: false })
      .limit(100);

    return {
      "message": "Feed retrieved successfully",
      "status": "success",
      "status_code": 200,
      "data": feed.data,
    };
  } catch (error) {
    return {
      "message": "Error retrieving feed",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// gets only the user's own timeline posts
const getMyFeedTransactions = async (
  _supabaseClient: any,
  _req: Request,
): Promise<any> => {
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  try {
    const myFeed = await _supabaseClient
      .from("timeline_posts")
      .select()
      .eq("user_id", user_id)
      .eq("post_owner_user_id", user_id)
      .order("created_at", { ascending: false })
      .limit(100);

    return {
      "message": "Personal feed retrieved successfully",
      "status": "success",
      "status_code": 200,
      "data": myFeed.data,
    };
  } catch (error) {
    return {
      "message": "Error retrieving personal feed",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// likes a post and updates all relevant records
const likePost = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  const user_id = await get_auth_user_id(_req, _supabaseClient);
  const post_info = _body.post_info;

  if (!user_id) {
    return {
      "message": "Unauthorized",
      "status": "failed",
      "status_code": 401,
      "data": null,
    };
  }

  try {
    // Get user info
    const user_result = await _supabaseClient
      .from("users")
      .select()
      .eq("user_id", user_id)
      .single();

    const user = user_result.data;

    // Mark user's copy of post as liked
    await _supabaseClient
      .from("timeline_posts")
      .update({
        "is_liked": true,
        "number_of_likes": 1,
      })
      .eq("user_id", user_id)
      .eq("post_id", post_info.post_id);

    // Get original post
    const original_post = await _supabaseClient
      .from("timeline_posts")
      .select()
      .eq("post_id", post_info.original_post_id)
      .single();

    const new_like_count = original_post.data.number_of_likes + 1;

    // Update original post like count
    await _supabaseClient
      .from("timeline_posts")
      .update({
        "number_of_likes": new_like_count,
      })
      .eq("post_id", post_info.original_post_id);

    // Create like record
    await _supabaseClient
      .from("liked_posts")
      .insert({
        "profile_image_url": user.profile_image_url,
        "post_id": post_info.original_post_id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "user_id": user_id,
      });

    return {
      "message": "Post liked successfully",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  } catch (error) {
    return {
      "message": "Error liking post",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// unlikes a post and updates all relevant records
const unlikePost = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  const user_id = await get_auth_user_id(_req, _supabaseClient);
  const post_info = _body.post_info;

  if (!user_id) {
    return {
      "message": "Unauthorized",
      "status": "failed",
      "status_code": 401,
      "data": null,
    };
  }

  try {
    // Mark user's copy as unliked
    await _supabaseClient
      .from("timeline_posts")
      .update({
        "is_liked": false,
        "number_of_likes": 0,
      })
      .eq("user_id", user_id)
      .eq("post_id", post_info.post_id);

    // Get original post
    const original_post = await _supabaseClient
      .from("timeline_posts")
      .select()
      .eq("post_id", post_info.original_post_id)
      .single();

    const new_like_count = original_post.data.number_of_likes - 1;

    // Update original post like count
    await _supabaseClient
      .from("timeline_posts")
      .update({
        "number_of_likes": new_like_count,
      })
      .eq("post_id", post_info.original_post_id);

    // Delete like record
    await _supabaseClient
      .from("liked_posts")
      .delete()
      .eq("post_id", post_info.original_post_id)
      .eq("user_id", user_id);

    return {
      "message": "Post unliked successfully",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  } catch (error) {
    return {
      "message": "Error unliking post",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// blocks a user and updates blocked users list
const blockUser = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  const user_id = await get_auth_user_id(_req, _supabaseClient);
  const user_to_block = _body.user_to_block;

  if (!user_id) {
    return {
      "message": "Unauthorized",
      "status": "failed",
      "status_code": 401,
      "data": null,
    };
  }

  try {
    // Get current user record
    const user_result = await _supabaseClient
      .from("users")
      .select()
      .eq("user_id", user_id)
      .single();

    const current_blocked_users =
      user_result.data.blocked_peoples_user_details || [];

    // Add blocked user to list
    await _supabaseClient
      .from("users")
      .update({
        "blocked_peoples_user_details": [
          {
            "profile_image_url": user_to_block.profile_image_url,
            "date_blocked": new Date().toISOString(),
            "first_name": user_to_block.first_name,
            "last_name": user_to_block.last_name,
            "user_id": user_to_block.user_id,
            "blocked_reason": "",
          },
          ...current_blocked_users,
        ],
      })
      .eq("user_id", user_id);

    return {
      "message": "User blocked successfully",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  } catch (error) {
    return {
      "message": "Error blocking user",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// reports a post for review
const reportPost = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  const user_id = await get_auth_user_id(_req, _supabaseClient);
  const report_info = _body.report_info;
  const post_info = _body.post_info;

  if (!user_id) {
    return {
      "message": "Unauthorized",
      "status": "failed",
      "status_code": 401,
      "data": null,
    };
  }

  try {
    const user_result = await _supabaseClient
      .from("users")
      .select()
      .eq("user_id", user_id)
      .single();

    const user = user_result.data;

    await _supabaseClient
      .from("reported_posts")
      .insert({
        "report_comment": report_info.report_comment,
        "report_type": report_info.report_type,
        "reporter_details": {
          "profile_image_url": user.profile_image_url,
          "first_name": user.first_name,
          "last_name": user.last_name,
          "user_id": user_id,
        },
        "post_id": post_info.post_id,
        "admin_reviewer_details": null,
        "is_reviewed_by_admin": false,
        "admin_review_comment": "",
        "user_id": user_id,
      });

    return {
      "message": "Post reported successfully",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  } catch (error) {
    return {
      "message": "Error reporting post",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// deletes a post and all its copies from timelines
const deletePost = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  const user_id = await get_auth_user_id(_req, _supabaseClient);
  const post_id = _body.post_id;

  if (!user_id) {
    return {
      "message": "Unauthorized",
      "status": "failed",
      "status_code": 401,
      "data": null,
    };
  }

  try {
    // Get all copies of the post
    const posts_result = await _supabaseClient
      .from("timeline_posts")
      .select()
      .eq("original_post_id", post_id);

    const delete_operations = posts_result.data.map((post: any) =>
      _supabaseClient
        .from("timeline_posts")
        .delete()
        .eq("post_id", post.post_id)
    );

    // Delete original post
    delete_operations.push(
      _supabaseClient
        .from("timeline_posts")
        .delete()
        .eq("post_id", post_id),
    );

    await Promise.all(delete_operations);

    return {
      "message": "Post deleted successfully",
      "status": "success",
      "status_code": 200,
      "data": null,
    };
  } catch (error) {
    return {
      "message": "Error deleting post",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }
};

// ============================================================ Authentication Functions

// creates a new user row record - used when signing up
const create_user_account_record = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
) => {
  /*
    body preview
    {
        "request_type": "create_user_account_record",
        "account_login_password": string *hashed,
        "last_time_online_timestamp": timestamp,
        "current_device_ip_address": string,
        "email_address_lowercase": string,
        "current_build_version": string,
        "username_searchable": string,
        "current_os_platform": string,
        "notification_token": string,
        "date_of_birth": timestamp,
        "physical_address": string,
        "currency_symbol": string,
        "referral_code": string,
        "email_address": string,
        "country_code": string,
        "phone_number": string,
        "account_type": string,
        "first_name": string,
        "last_name": string,
        "user_code": string,
        "username": string,
        "currency": string,
        "user_id": string,
        "country": string,
        "gender": string,
        "city": string,
    }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // encrypts the user's account login password
  const encrypted_password = await encrypt(
    _body["account_login_password"],
    `${Deno.env.get("ACCOUNT_LOGIN_ENCRYPTION_KEY_BASE_64")}`,
  );

  // creates the user's account row
  await _supabaseClient.from("users").insert({
    "current_device_ip_address": _body["current_device_ip_address"],
    "email_address_lowercase": _body["email_address_lowercase"],
    "number_of_savings_deposits_ever_made_to_nas_accounts": 0,
    "current_build_version": _body["current_build_version"],
    "username_searchable": _body["username_searchable"],
    "current_os_platform": _body["current_os_platform"],
    "current_activity_level_completion_percentage": 0,
    "number_of_contacts_uploaded_with_jayben_accs": 0,
    "notification_token": _body["notification_token"],
    "physical_address": _body["physical_address"],
    "account_login_password": encrypted_password,
    "total_amount_ever_saved_in_nas_accounts": 0,
    "currency_symbol": _body["currency_symbol"],
    "timeline_privacy_setting": "All contacts",
    "number_of_wallet_deposits_ever_made": 0,
    "referral_code": _body["referral_code"],
    "email_address": _body["email_address"],
    "date_of_birth": _body["date_of_birth"],
    "total_number_of_contacts_uploaded": 0,
    "country_code": _body["country_code"],
    "phone_number": _body["phone_number"],
    "account_type": _body["account_type"],
    "blocked_peoples_user_details": null,
    "daily_user_minutes_spent_in_app": 0,
    "daily_minutes_spent_in_timeline": 0,
    "first_name": _body["first_name"],
    "account_kyc_is_verified": false,
    "nas_deposits_are_allowed": true,
    "total_amount_ever_deposted": 0,
    "withdrawals_are_allowed": true,
    "last_name": _body["last_name"],
    "user_code": _body["user_code"],
    "username": _body["username"],
    "currency": _body["currency"],
    "deposits_are_allowed": true,
    "is_currently_online": true,
    "black_listed_user_ids": [],
    "account_is_on_hold": false,
    "country": _body["country"],
    "user_monthly_metrics": {},
    "show_update_alert": false,
    "account_is_banned": false,
    "gender": _body["gender"],
    "user_total_metrics": {},
    "user_daily_metrics": {},
    "current_device_id": "",
    "profile_image_url": "",
    "city": _body["city"],
    "activity_level": 1,
    "user_id": user_id,
    "pin_code": "",
    "balance": 0,
    "points": 0,
  });

  return {
    "message": "successfully created a new user account",
    "status": "success",
    "status_code": 200,
    "data": null,
  };

  // "user_monthly_metrics"
  // "user_daily_metrics"
  // "user_total_metrics"
};

// checks if the email address already exists
const check_if_account_email_address_exists = async (
  _supabaseClient: any,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "check_if_account_email_address_exists",
      "email_address": string
    }
  */

  // checks if the email address already exists
  const res = await _supabaseClient.from("users").select().eq(
    "email_address_lowercase",
    _body["email_address"].toString().toLowerCase(),
  );

  if (res["data"].length != 0) {
    return {
      "message": "email address already exists",
      "status": "success",
      "status_code": 200,
      "data": {
        "email_address": _body["email_address"],
        "exists": true,
      },
    };
  } else {
    return {
      "message": "email address does not exist",
      "status": "success",
      "status_code": 200,
      "data": {
        "email_address": _body["email_address"],
        "exists": false,
      },
    };
  }
};

// checks if the username already exists
const check_if_account_username_exists = async (
  _supabaseClient: any,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "check_if_account_username_exists",
      "username": string
    }
  */

  console.log(
    "The username given is: ",
    _body["username"].toString().toLowerCase(),
  );

  try {
    // checks if the email address already exists
    const { data, error } = await _supabaseClient.from("users").select()
      .eq(
        "username_searchable",
        _body["username"].toString().toLowerCase(),
      );

    console.log("This is the result broo", data);

    console.log("If there is an error, its:", error);

    if (data.length != 0) {
      return {
        "message": "username already exists",
        "status": "success",
        "status_code": 200,
        "data": {
          "username": _body["username"],
          "exists": true,
        },
      };
    } else {
      return {
        "message": "username does not exist",
        "status": "success",
        "status_code": 200,
        "data": {
          "username": _body["username"],
          "exists": false,
        },
      };
    }
  } catch (e) {
    console.log(e);
  }
};

// checks if the phone number already exists
const check_if_account_phone_number_exists = async (
  _supabaseClient: any,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "check_if_account_phone_number_exists",
      "phone_number": string
    }
  */

  // checks if the email address already exists
  const res = await _supabaseClient.from("users").select().eq(
    "phone_number",
    _body["phone_number"],
  );

  if (res["data"].length != 0) {
    return {
      "message": "phone number already exists",
      "status": "success",
      "status_code": 200,
      "data": {
        "phone_number": _body["phone_number"],
        "exists": true,
      },
    };
  } else {
    return {
      "message": "phone number does not exist",
      "status": "success",
      "status_code": 200,
      "data": {
        "phone_number": _body["phone_number"],
        "exists": false,
      },
    };
  }
};

// checks if the referral code already exists
const check_if_referral_code_exists = async (
  _supabase: any,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "check_if_referral_code_exists",
      "referral_code": string
    }
  */

  // checks if the gets a list of accounts that have this re already exists
  const accs_with_this_referral_code = await _supabase.from("users")
    .select()
    .eq("referral_code", _body["referral_code"].toString().toLowerCase());

  if (accs_with_this_referral_code["data"].length == 0) {
    return {
      "message": "referral code does not exist",
      "status": "success",
      "status_code": 200,
      "data": {
        "referral_code": _body["referral_code"],
        "exists": false,
      },
    };
  } else {
    return {
      "message": "referral code already exists",
      "status": "success",
      "status_code": 200,
      "data": {
        "referral_code": _body["referral_code"],
        "exists": true,
      },
    };
  }
};

const get_users_email_address = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_users_email_address",
    }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  } else {
    // gets the user's row records
    const users = await _supabaseClient.from("users")
      .select()
      .eq("user_id", user_id);

    return {
      "message": "Email address found",
      "status": "success",
      "status_code": 200,
      "data": {
        "email_address": users["data"][0]["email_address"],
      },
    };
  }
};

// ============================================================ Referrals Functions

const get_my_referral_commissions = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
  body preview
  {
    "request_type": "get_my_referral_commissions",
    "get_number_of_people_user_referred": bool,
    "number_of_rows_to_query": string,
  }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // gets the user's referral commissions rows
  const my_referral_commissions = await _supabaseClient.from(
    "referral_commission_transactions",
  ).select().eq("user_id", user_id).order("created_at", {
    ascending: false,
  });

  if (_body["get_number_of_people_user_referred"]) {
    const user_account = await _supabaseClient.from("users").select().eq(
      "user_id",
      user_id,
    );

    const users_referral_code = user_account["data"][0].referral_code;

    const people_user_has_referred = await _supabaseClient.from("users")
      .select().eq("referred_by", users_referral_code);

    return {
      "data": {
        "comission_transactions_count": my_referral_commissions["data"].length,
        "people_user_has_referred": people_user_has_referred["data"],
        "referral_commissions": my_referral_commissions["data"],
        "people_user_has_referred_count":
          people_user_has_referred["data"].length,
      },
      "message": "Referral commissions found",
      "status": "success",
      "status_code": 200,
    };
  } else {
    return {
      "data": {
        "comission_transactions_count": my_referral_commissions["data"].length,
        "referral_commissions": my_referral_commissions["data"],
        "people_user_has_referred_count": null,
        "people_user_has_referred": null,
      },
      "message": "Referral commissions found",
      "status": "success",
      "status_code": 200,
    };
  }
};

// ============================================================ NFC Functions Functions

// creates a database record of the tag being registered
const register_nfc_tag = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
      body preview
      {
        "request_type": "register_nfc_tag",
        "decrypted_pin_code": string,
        "tag_serial_number": string,
      }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // gets the user's account details
  const user_result = await _supabaseClient
    .from("users")
    .select()
    .eq("user_id", user_id)
    .single();

  const user = user_result.data;

  // encrypts the tag's pin code
  const encrypted_pin_code = await _encrypt_tag_pin_code(
    _supabaseClient,
    _body.decrypted_pin_code,
  );

  // creates the tag record
  await _supabaseClient.from("nfc_tags").insert({
    "tag_name": `${user.first_name} ${user.last_name}`,
    "complete_transactions_to_wallet_balance": true,
    "owner_details": {
      "profile_image_url": user.profile_image_url,
      "email_address": user.email_address,
      "first_name": user.first_name,
      "last_name": user.last_name,
      "currency": user.currency,
      "country": user.country,
      "gender": user.gender,
      "user_id": user_id,
      "city": user.city,
    },
    "tag_serial_number": _body.tag_serial_number,
    "pin_code": encrypted_pin_code,
    "last_used_timestamp": null,
    "number_of_transactions": 0,
    "user_code": user.user_code,
    "currency": user.currency,
    "country": user.country,
    "gps_location": null,
    "pin_tries_left": 3,
    "user_id": user_id,
    "is_frozen": false,
    "is_active": true,
    "city": user.city,
    "balance": 0,
  });

  return {
    "message": "Tag registered successfully",
    "status": "success",
    "status_code": 200,
    "data": null,
  };
};

const _encrypt_tag_pin_code = async (
  _supabaseClient: any,
  _decrypted_pin_code: any,
): Promise<any> => {
  /*
      body preview
      {
        "pin_code": string
      }
  */

  // encrypts the tag pin code
  const encrypted_pin_code = await encrypt(
    _decrypted_pin_code,
    `${Deno.env.get("ACCOUNT_LOGIN_ENCRYPTION_KEY_BASE_64")}`,
  );

  return encrypted_pin_code;
};

const _decrypt_tag_pin_code = async (
  _supabaseClient: any,
  _encrypted_pin_code: any,
): Promise<any> => {
  /*
      body preview
      {
        "pin_code": string
      }
  */

  // encrypts the tag pin code
  const decrypted_pin_code = await decrypt(
    _encrypted_pin_code,
    `${Deno.env.get("ACCOUNT_LOGIN_ENCRYPTION_KEY_BASE_64")}`,
  );

  return decrypted_pin_code;
};

// gets all registered tags for a user
const get_my_registered_tags = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
      body preview
      {
        "request_type": "get_my_registered_tags",
        "get_tag_transactions_also": boolean
      }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // gets the user's registered nfc tags
  const registered_tags = await _supabaseClient
    .from("nfc_tags")
    .select()
    .eq("is_active", true)
    .eq("user_id", user_id)
    .order("created_at", { ascending: false });

  if (_body["get_tag_transactions_also"]) {
    const tags_transactions = await _get_all_tags_transactions(
      _supabaseClient,
      registered_tags.data,
    );

    return {
      "message": "Tags retrieved successfully",
      "status": "success",
      "status_code": 200,
      "data": {
        "transactions": tags_transactions,
        "tags": registered_tags.data,
      },
    };
  } else {
    return {
      "message": "Tags retrieved successfully",
      "status": "success",
      "status_code": 200,
      "data": {
        "tags": registered_tags.data,
        "transactions": null,
      },
    };
  }
};

// gets transactions for all tags
const _get_all_tags_transactions = async (
  _supabaseClient: any,
  tags: any[],
): Promise<any[]> => {
  const operations = tags.map((tag) =>
    _supabaseClient
      .from("nfc_tag_transactions")
      .select()
      .eq("tag_id", tag.tag_id)
      .order("created_at", { ascending: false })
  );

  return await Promise.all(operations);
};

// gets transactions for a single tag
const get_single_tag_transactions = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
      body preview
      {
        "request_type": "get_single_tag_transactions",
        "tag_id": string
      }
    */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // gets the transactions for a specific nfc tag
  const result = await _supabaseClient
    .from("nfc_tag_transactions")
    .select()
    .eq("user_id", user_id)
    .eq("tag_id", _body.tag_id)
    .order("created_at", { ascending: false });

  return {
    "message": "Tag transactions retrieved successfully",
    "status": "success",
    "status_code": 200,
    "data": result.data,
  };
};

// checks if user has any registered tags
const check_if_user_has_tags_registered = async (
  _supabaseClient: any,
  _req: Request,
): Promise<any> => {
  /*
      body preview
      {
        "request_type": "check_if_user_has_tags_registered"
      }
    */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  const results = await _supabaseClient
    .from("nfc_tags")
    .select()
    .eq("user_id", user_id)
    .eq("is_active", true);

  return {
    "message": "Check completed successfully",
    "status": "success",
    "status_code": 200,
    "data": {
      "has_tags": results.data.length > 0,
    },
  };
};

// checks if a tag has already been registered
const check_if_tag_exists = async (
  _supabaseClient: any,
  _body: any,
): Promise<any> => {
  /*
      body preview
      {
        "request_type": "check_if_tag_exists",
        "tag_id": string
      }
    */

  const results = await _supabaseClient
    .from("nfc_tags")
    .select()
    .eq("tag_serial_number", _body.tag_serial_number);

  return {
    "message": "Check completed successfully",
    "status": "success",
    "status_code": 200,
    "data": {
      "exists": results.data.length > 0,
    },
  };
};

// ============================================================ KYC Functions

const get_my_kyc_verification_records = async (
  _supabaseClient: any,
  _body: any,
  _req: Request,
): Promise<any> => {
  /*
  body preview
  {
    "request_type": "get_my_kyc_verification_records",
    "number_of_rows_to_query": string,
    "get_number_of_people"
  }
  */

  const user_id = await get_auth_user_id(_req, _supabaseClient);

  if (user_id == null) {
    return {
      "message": "Please login first",
      "status": "failed",
      "status_code": 400,
      "data": null,
    };
  }

  // gets the user's referral commissions rows
  const my_referral_commissions = await _supabaseClient.from(
    "referral_commission_transactions",
  ).select().eq("user_id", user_id).order("created_at", {
    ascending: false,
  });

  return {
    "message": "Referral commissions found",
    "status": "success",
    "status_code": 200,
    "data": {
      "referral_commissions": my_referral_commissions["data"],
      "count": my_referral_commissions["data"].length,
    },
  };
};

// ============================================================ QR Code Scanner Functions

// ============================================================ Authentication Functions

const get_limited_user_row_from_usercode = async (
  _supabaseClient: any,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_limited_user_row_from_usercode",
      "user_code": string
    }
  */

  // gets the merchant's row records
  const res = await _supabaseClient.from("users").select().eq(
    "user_code",
    _body["user_code"].toLowerCase(),
  );

  if (res["data"].length != 0) {
    const account_map = res["data"][0];

    return {
      "code": 200,
      "staus": "success",
      "message": "query successful",
      "data": {
        "account_kyc_is_verified": account_map["account_kyc_is_verified"],
        "account_is_on_hold": account_map["account_is_on_hold"],
        "currency_symbol": account_map["currency_symbol"],
        "first_name": account_map["first_name"],
        "last_name": account_map["last_name"],
        "user_code": account_map["user_code"],
        "currency": account_map["currency"],
        "country": account_map["country"],
        "user_id": account_map["user_id"],
      },
    };
  } else {
    return {
      "message": "no record found, please use try another user code",
      "staus": "failed",
      "code": 400,
      "data": {},
    };
  }
};

const get_limited_user_row_from_userid = async (
  _supabaseClient: any,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "get_limited_user_row_from_userid",
      "user_id": string
    }
  */

  // gets the merchant's row records
  const res = await _supabaseClient.from("users").select().eq(
    "user_id",
    _body["user_id"],
  );

  if (res["data"].length != 0) {
    const account_map = res["data"][0];

    return {
      "code": 200,
      "staus": "success",
      "message": "query successful",
      "data": {
        "account_kyc_is_verified": account_map["account_kyc_is_verified"],
        "account_is_on_hold": account_map["account_is_on_hold"],
        "currency_symbol": account_map["currency_symbol"],
        "first_name": account_map["first_name"],
        "last_name": account_map["last_name"],
        "user_code": account_map["user_code"],
        "currency": account_map["currency"],
        "country": account_map["country"],
        "user_id": account_map["user_id"],
      },
    };
  } else {
    return {
      "message": "no record found, please use try another user code",
      "staus": "failed",
      "code": 400,
      "data": {},
    };
  }
};

// moves money from the sender to the receiver
const send_money_via_qr_code = async (
  _supabaseClient: any,
  _req: any,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "transaction_details": {
        "merchant_commission_per_transaction": double,
        "receiver_user_id": string,
        "payment_means": string,
        "amount": num/float
      },
      "request_type": "send_money_via_qr_code",
    }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the sender's user account row
  const sender_rows = await _supabaseClient.from("users").select()
    .eq(
      "user_id",
      user_id,
    );

  // gets the receiver's user account row
  const receiver_rows = await _supabaseClient.from("users").select()
    .eq(
      "user_id",
      _body["transaction_details"]["receiver_user_id"],
    );

  const amount_minus_fee = _body["transaction_details"]["amount"];

  const amount_plus_fee = amount_minus_fee +
    _body["transaction_details"]["merchant_commission_per_transaction"];

  const sender_row = sender_rows["data"][0];

  const receiver_row = receiver_rows["data"][0];

  const sender_transaction_id = crypto.randomUUID();

  const receiver_transaction_id = crypto.randomUUID();

  // converts the amount being sent to the receiver's currency
  const converted_amount = await convert_currency(_supabaseClient, {
    "from_currency": sender_row["currency"],
    "to_currency": receiver_row["currency"],
    "amount_to_convert": amount_minus_fee,
  });

  const receiver_wallet_bal_after_transaction = receiver_row["balance"] +
    converted_amount;

  const sender_wallet_bal_after_transaction = sender_row["balance"] -
    amount_plus_fee;

  // creates a revenue record
  // creates a record for the receiver
  // creates a record for the sender
  // debits the sender's balance
  // credits the receiver's number
  // sends notifications
  await Promise.all([
    _supabaseClient.from("revenue_records").insert({
      "amount":
        _body["transaction_details"]["merchant_commission_per_transaction"],
      "monetized_transaction_details": {
        "method": _body["transaction_details"]["payment_means"],
        "receiver_transaction_id": receiver_transaction_id,
        "sender_transaction_id": sender_transaction_id,
        "transaction_type": "Merchant Payment",
      },
      "currency_symbol": sender_row["currency_symbol"],
      "currency": sender_row["currency"],
      "source_user_id": user_id,
      "status": "completed",
    }),
    _supabaseClient.from("transactions").insert({
      "transaction_fee_details": {
        "transaction_fee_amount":
          _body["transaction_details"]["merchant_commission_per_transaction"],
        "transaction_total_fee_currency": receiver_row["currency"],
        "transaction_international_bank_tranfer_fee": null,
        "transcation_bank_transfer_fee_currency": null,
        "transaction_local_bank_tranfer_fee": null,
        "transaction_total_fee_percentage": null,
      },
      "p2p_sender_details": {
        "senders_wallet_balance_after_transaction":
          sender_wallet_bal_after_transaction,
        "full_names": `${sender_row["first_name"]} ${sender_row["last_name"]}`,
        "senders_wallet_balance_before_transaction": sender_row["balance"],
        "phone_number": sender_row["phone_number"],
        "user_id": user_id,
      },
      "description": `From ${sender_row["first_name"]} ${
        sender_row["last_name"]
      }`,
      "wallet_balance_details": {
        "wallet_balance_after_transaction":
          receiver_wallet_bal_after_transaction,
        "wallet_balance_before_transaction": receiver_row["balance"],
        "wallet_balances_difference": converted_amount,
      },
      "full_names": `${receiver_row["first_name"]} ${
        receiver_row["last_name"]
      }`,
      "user_is_verified": receiver_row["account_kyc_is_verified"],
      "user_id": _body["transaction_details"]["receiver_user_id"],
      "currency_symbol": receiver_row["currency_symbol"],
      "transaction_id": receiver_transaction_id,
      "currency": receiver_row["currency"],
      "country": receiver_row["country"],
      "savings_account_details": null,
      "transaction_type": "Transfer",
      "p2p_recipient_details": null,
      "sent_received": "Received",
      "method": "Wallet transfer",
      "withdrawal_details": null,
      "amount": converted_amount,
      "deposit_details": null,
      "number_of_replies": 0,
      "status": "Completed",
      "attended_to": false,
      "number_of_likes": 0,
      "number_of_views": 0,
      "is_public": false,
      "comment": "",
    }),
    _supabaseClient.from("transactions").insert({
      "p2p_recipient_details": {
        "recipient_wallet_balance_after_transaction":
          receiver_wallet_bal_after_transaction,
        "full_names": `${receiver_row["first_name"]} ${
          receiver_row["last_name"]
        }`,
        "recipient_wallet_balance_before_transaction": receiver_row["balance"],
        "user_id": _body["transaction_details"]["receiver_user_id"],
        "phone_number": receiver_row["phone_number"],
      },
      "description": `To ${receiver_row["first_name"]} ${
        receiver_row["last_name"]
      }`,
      "wallet_balance_details": {
        "wallet_balance_after_transaction": sender_wallet_bal_after_transaction,
        "wallet_balance_before_transaction": sender_row["balance"],
        "wallet_balances_difference": amount_plus_fee,
      },
      "full_names": `${sender_row["first_name"]} ${sender_row["last_name"]}`,
      "user_is_verified": sender_row["account_kyc_is_verified"],
      "currency_symbol": sender_row["currency_symbol"],
      "transaction_id": sender_transaction_id,
      "currency": sender_row["currency"],
      "country": sender_row["country"],
      "savings_account_details": null,
      "transaction_fee_details": null,
      "transaction_type": "Transfer",
      "method": "Wallet transfer",
      "withdrawal_details": null,
      "p2p_sender_details": null,
      "amount": amount_minus_fee,
      "deposit_details": null,
      "sent_received": "Sent",
      "number_of_replies": 0,
      "status": "Completed",
      "number_of_views": 0,
      "number_of_likes": 0,
      "attended_to": false,
      "is_public": false,
      "user_id": user_id,
      "comment": "",
    }),
    _supabaseClient.from("users").update({
      "balance": receiver_wallet_bal_after_transaction,
    }).eq("user_id", _body["transaction_details"]["receiver_user_id"]),
    _supabaseClient.from("users").update({
      "balance": sender_wallet_bal_after_transaction,
    }).eq("user_id", user_id),
    _supabaseClient.rpc("send_notifications_via_firebase", {
      body: `You have sent ${
        sender_row["currency_symbol"]
      }${amount_minus_fee} to ${receiver_row["first_name"]} ${
        receiver_row["last_name"]
      }`,
      notification_tokens: [
        sender_row["notification_token"],
      ],
      title: "Payment Sent ✅",
    }),
    _supabaseClient.rpc("send_notifications_via_firebase", {
      body: `You have received ${receiver_row["currency_symbol"]}${
        converted_amount.toFixed(2)
      } from ${sender_row["first_name"]} ${sender_row["last_name"]}`,
      notification_tokens: [
        receiver_row["notification_token"],
      ],
      title: "Payment Received 💰",
    }),
  ]);
};

// ============================================================ Recording Daily User Rows

const record_all_user_accounts = async (
  _supabaseClient: any,
): Promise<void> => {
  /*
        body preview - the preview is empty
        {
            "request_type": "record_all_user_accounts"
        }
    */

  // gets the user rows in batches
  const user_batches = await get_user_rows_in_batches(_supabaseClient);

  let operations_to_run = [];

  // runs for loop for each batch of contacts
  for (let i = 0; i < user_batches.length; i++) {
    operations_to_run.push(
      create_daily_copy_of_user_rows(_supabaseClient, user_batches[i]),
    );
  }

  console.log("Now calling all https functions all at once boss........");

  // runs all the operations all at once
  await Promise.all(operations_to_run);

  console.log("Finished calling all https functions all at once boss!");
};

// gets all the user rows and adds them to batches
const get_user_rows_in_batches = async (_supabaseClient: any): Promise<any> => {
  // gets all the user rows
  const user_rows = await _supabaseClient.from("users").select();

  let current_user_batch = [];

  let all_user_batches = [];

  // for each user row, it adds row to a batch
  for (let i = 0; i < user_rows["data"].length; i++) {
    // adds the current user account to the current batch
    current_user_batch.push(user_rows["data"][i]);

    // Check if the current batch size reaches 20 or it's the last contact
    if (current_user_batch.length == 20 || i == user_rows["data"].length - 1) {
      all_user_batches.push(current_user_batch);
      current_user_batch = [];
    }
  }

  return all_user_batches;
};

// receives a list of users and pastes them in a table
const create_daily_copy_of_user_rows = async (
  _supabaseClient: any,
  _user_rows: any,
): Promise<void> => {
  // stores the current batch of contacts
  const processed_user_rows = _user_rows;

  let create_copy_operations_list = [];

  // adds each processed contact a list of of contacts so that they can be checked
  // if they have already been uploaded to the database
  for (let i = 0; i < processed_user_rows.length; i++) {
    const user_row = processed_user_rows[i];

    // adds the checking operation to a list of operations that need to be run
    create_copy_operations_list.push(
      {
        "number_of_savings_deposits_ever_made_to_nas_accounts":
          user_row["number_of_savings_deposits_ever_made_to_nas_accounts"],
        "current_activity_level_completion_percentage":
          user_row["current_activity_level_completion_percentage"],
        "number_of_contacts_uploaded_with_jayben_accs":
          user_row["number_of_contacts_uploaded_with_jayben_accs"],
        "total_amount_ever_saved_in_nas_accounts":
          user_row["total_amount_ever_saved_in_nas_accounts"],
        "number_of_wallet_deposits_ever_made":
          user_row["number_of_wallet_deposits_ever_made"],
        "total_number_of_contacts_uploaded":
          user_row["total_number_of_contacts_uploaded"],
        "daily_user_minutes_spent_in_app":
          user_row["daily_user_minutes_spent_in_app"],
        "daily_minutes_spent_in_timeline":
          user_row["daily_minutes_spent_in_timeline"],
        "blocked_peoples_user_details":
          user_row["blocked_peoples_user_details"],
        "total_amount_ever_deposted": user_row["total_amount_ever_deposted"],
        "last_time_online_timestamp": user_row["last_time_online_timestamp"],
        "current_device_ip_address": user_row["current_device_ip_address"],
        "nas_deposits_are_allowed": user_row["nas_deposits_are_allowed"],
        "timeline_privacy_setting": user_row["timeline_privacy_setting"],
        "email_address_lowercase": user_row["email_address_lowercase"],
        "account_kyc_is_verified": user_row["account_kyc_is_verified"],
        "withdrawals_are_allowed": user_row["withdrawals_are_allowed"],
        "account_login_password": user_row["account_login_password"],
        "black_listed_user_ids": user_row["black_listed_user_ids"],
        "current_build_version": user_row["current_build_version"],
        "deposits_are_allowed": user_row["deposits_are_allowed"],
        "username_searchable": user_row["username_searchable"],
        "is_currently_online": user_row["is_currently_online"],
        "current_os_platform": user_row["current_os_platform"],
        "notification_token": user_row["notification_token"],
        "account_is_on_hold": user_row["account_is_on_hold"],
        "profile_image_url": user_row["profile_image_url"],
        "show_update_alert": user_row["show_update_alert"],
        "account_is_banned": user_row["account_is_banned"],
        "physical_address": user_row["physical_address"],
        "currency_symbol": user_row["currency_symbol"],
        "activity_level": user_row["activity_level"],
        "referral_code": user_row["referral_code"],
        "date_of_birth": user_row["date_of_birth"],
        "email_address": user_row["email_address"],
        "phone_number": user_row["phone_number"],
        "account_type": user_row["account_type"],
        "country_code": user_row["country_code"],
        "date_joined": user_row["created_at"],
        "first_name": user_row["first_name"],
        "last_name": user_row["last_name"],
        "user_code": user_row["user_code"],
        "pin_code": user_row["pin_code"],
        "username": user_row["username"],
        "currency": user_row["currency"],
        "country": user_row["country"],
        "balance": user_row["balance"],
        "user_id": user_row["user_id"],
        "points": user_row["points"],
        "gender": user_row["gender"],
        "city": user_row["city"],
      },
    );
  }

  console.log("Now creating supabase records of the contacts boss....");

  // creates the records all at once using the list of contact maps to create
  await _supabaseClient.from("users_history").insert(
    create_copy_operations_list,
  );

  console.log("DONE creating supabase records of the contacts boss!");
};

// ============================================================ Metric Functions

// runs an operation that creates a record of today's app metrics
const record_daily_metrics = async (supabase: any): Promise<void> => {
  /*
        body preview
        {
            "request_type": "record_daily_metrics",
        }
  */

  try {
    let total_amount_in_wallets = 0;
    let total_amount_of_deposits_ever_made = 0;
    let total_amount_deposited_today_so_far = 0;
    let total_amount_withdrawn_today_so_far = 0;
    let number_of_deposits_done_today_so_far = 0;
    let number_of_withdraws_done_today_so_far = 0;
    let total_amount_in_personal_nas_accounts = 0;
    let total_amount_of_deposits_in_last_30_days = 0;
    let total_amount_in_active_shared_nas_accounts = 0;
    let total_number_of_transactions_processed_ever = 0;
    let number_of_transfers_to_personal_nas_accounts = 0;
    let number_of_transactions_processed_today_so_far = 0;
    let total_amount_saved_in_personal_nas_accs_today_so_far = 0;
    let number_of_transfers_to_shared_nas_accounts_today_so_far = 0;
    let total_amount_transfered_to_active_shared_nas_accounts_today = 0;
    let total_amount_transfered_to_shared_nas_accounts_in_last_30_days = 0;

    const today = new Date();
    const last_month = new Date();
    const last_7_days = new Date();

    // gets a date starting today at midnight
    today.setHours(0, 0, 0, 0);

    // gets a date starting from 30 days ago
    last_month.setMonth(last_month.getMonth() - 1);

    // gets a date of 7 days back in time
    last_7_days.setDate(last_7_days.getDate() - 7);

    const results = await Promise.all([
      supabase
        .from("users")
        .select("*", { count: "exact" }),
      supabase.from("users").select().neq("balance", 0),
      supabase
        .from("no_access_savings_accounts")
        .select("*", { count: "exact" })
        .eq("is_active", true),
      supabase
        .from("transactions")
        .select("*", { count: "exact" })
        .eq("transaction_type", "Withdrawal")
        .eq("status", "Pending"),
      supabase
        .from("transactions")
        .select("*", { count: "exact" })
        .gte("created_at", today.toISOString()),
      supabase
        .from("transactions")
        .select("*", { count: "exact" }),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .gte("last_time_online_timestamp", today.toISOString()),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .gte("last_time_online_timestamp", last_month.toISOString()),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .gte("created_at", last_month.toISOString()),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .gte("created_at", today.toISOString()),
      supabase
        .from("transactions")
        .select("*", { count: "exact" })
        .gte("created_at", last_month.toISOString()),
      supabase
        .from("shared_no_access_savings_accounts")
        .select("*", { count: "exact" })
        .eq("is_active", true),
      supabase
        .from("shared_no_access_savings_accounts")
        .select("*", { count: "exact" })
        .gte("created_at", today.toISOString()),
      supabase
        .from("shared_no_access_savings_accounts")
        .select("*", { count: "exact" })
        .gte("created_at", last_month.toISOString()),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .gte("last_time_online_timestamp", last_7_days.toISOString()),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .lte("created_at", last_month.toISOString())
        .gte("last_time_online_timestamp", last_7_days.toISOString()),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .lte("created_at", last_month.toISOString())
        .gte("last_time_online_timestamp", today.toISOString()),
      supabase
        .from("users")
        .select("*", { count: "exact" })
        .lte("created_at", last_month.toISOString())
        .gte("last_time_online_timestamp", last_month.toISOString()),
    ]);

    // sums up all the user wallet bals
    for (var i = 0; i < results[1]["data"].length; i++) {
      total_amount_in_wallets += results[1]["data"][i]["balance"];
    }

    // sums up all the active Personal NAS acc bals
    for (var i = 0; i < results[2]["data"].length; i++) {
      total_amount_in_personal_nas_accounts += results[2]["data"][i]["balance"];
    }

    console.log("The transactions are: ", results[4]["data"].length);

    // sums up all the unique transactions processed today so far
    for (var i = 0; i < results[4]["data"].length; i++) {
      if (
        results[4]["data"][i]["status"] == "Completed" &&
        results[4]["data"][i]["transaction_type"] == "Withdrawal"
      ) {
        total_amount_withdrawn_today_so_far += results[4]["data"][i]["amount"];

        number_of_withdraws_done_today_so_far++;
      }

      // deals with number & amount of money to Personal & Shared NAS Accounts
      if (results[4]["data"][i]["transaction_type"] == "Savings Transfer") {
        // sums up the amount saved in personal nas accs today so far
        if (results[4]["data"][i]["method"] == "No Access Savings Account") {
          total_amount_saved_in_personal_nas_accs_today_so_far +=
            results[4]["data"][i]["amount"];

          number_of_transfers_to_personal_nas_accounts++;
        }

        // sums up the total amount transfered to shared nas accounts today
        if (
          results[4]["data"][i]["method"] == "Shared No Access Savings Account"
        ) {
          total_amount_transfered_to_active_shared_nas_accounts_today +=
            results[4]["data"][i]["amount"];

          number_of_transfers_to_shared_nas_accounts_today_so_far++;
        }
      }

      // counts number of wallet deposits today so far (mobile money & card)
      if (results[4]["data"][i]["transaction_type"] == "Deposit") {
        if (
          results[4]["data"][i]["method"] == "MTN Money" ||
          results[4]["data"][i]["method"] == "Mobile Money" ||
          results[4]["data"][i]["method"] == "Airtel Money" ||
          results[4]["data"][i]["method"] == "Zamtel Money" ||
          results[4]["data"][i]["method"] == "Credit/Debit Card"
        ) {
          total_amount_deposited_today_so_far +=
            results[4]["data"][i]["amount"];

          number_of_deposits_done_today_so_far++;
        }
      }

      number_of_transactions_processed_today_so_far++;
    }

    // sums up the amount in deposits processed ever
    for (var i = 0; i < results[5]["data"].length; i++) {
      // counts number of wallet deposits ever (mobile money & card)
      if (results[5]["data"][i]["transaction_type"] == "Deposit") {
        if (
          results[5]["data"][i]["method"] == "MTN Money" ||
          results[5]["data"][i]["method"] == "Mobile Money" ||
          results[5]["data"][i]["method"] == "Airtel Money" ||
          results[5]["data"][i]["method"] == "Zamtel Money" ||
          results[5]["data"][i]["method"] == "Credit/Debit Card"
        ) {
          total_amount_of_deposits_ever_made += results[5]["data"][i]["amount"];
        }
      }
    }

    // sums up the amount in unique transactions processed in the last 30 days
    for (var i = 0; i < results[10]["data"].length; i++) {
      // sums up the total amount of money deposited into jayben in last 30 days
      if (results[10]["data"][i]["transaction_type"] == "Deposit") {
        if (
          results[10]["data"][i]["method"] == "MTN Money" ||
          results[10]["data"][i]["method"] == "Mobile Money" ||
          results[10]["data"][i]["method"] == "Airtel Money" ||
          results[10]["data"][i]["method"] == "Zamtel Money" ||
          results[10]["data"][i]["method"] == "Credit/Debit Card"
        ) {
          total_amount_of_deposits_in_last_30_days +=
            results[10]["data"][i]["amount"];
        }
      }

      // sums up the total amount transfered to shared nas accounts today
      if (
        results[10]["data"][i]["method"] ==
          "Shared No Access Savings Account" &&
        results[10]["data"][i]["transaction_type"] == "Savings Transfer"
      ) {
        total_amount_transfered_to_shared_nas_accounts_in_last_30_days +=
          results[10]["data"][i]["amount"];
      }
    }

    // sums up the total amount in active shared nas accounts
    for (var i = 0; i < results[11]["data"].length; i++) {
      // ignores the 1 demo nas account to build user confidence
      if (
        results[11]["data"][i]["account_id"] !=
          "5eeaaad9-cc76-4d26-a1e8-ba19a142c264"
      ) {
        total_amount_in_active_shared_nas_accounts +=
          results[11]["data"][i]["balance"];
      }
    }

    const total_user_money = total_amount_in_wallets +
      total_amount_in_personal_nas_accounts +
      total_amount_in_active_shared_nas_accounts;

    // creates the day's metrics record
    await supabase.from("daily_app_metrics").insert({
      "weekly_active_users_all_users": results[14].count,
      "number_of_active_shared_nas_accounts": results[11].count,
      "number_of_shared_nas_accounts_created_today": results[12].count,
      "daily_active_users_for_users_older_than_30_days": results[16].count,
      "weekly_active_users_for_users_older_than_30_days": results[15].count,
      "monthly_active_users_for_users_older_than_30_days": results[17].count,
      "total_amount_of_deposits_ever_made": total_amount_of_deposits_ever_made,
      "number_of_shared_nas_accounts_created_in_last_30_days":
        results[13].count,
      "total_amount_of_deposits_in_last_30_days":
        total_amount_of_deposits_in_last_30_days,
      "total_amount_in_active_shared_nas_accounts":
        total_amount_in_active_shared_nas_accounts,
      "number_of_transfers_to_shared_nas_accounts_today_so_far":
        number_of_transfers_to_shared_nas_accounts_today_so_far,
      "total_amount_transfered_to_active_shared_nas_accounts_today":
        total_amount_transfered_to_active_shared_nas_accounts_today,
      "total_amount_transfered_to_shared_nas_accounts_in_last_30_days":
        total_amount_transfered_to_shared_nas_accounts_in_last_30_days,
      "number_of_transfers_to_personal_nas_accounts_today_so_far":
        number_of_transfers_to_personal_nas_accounts,
      "total_amount_transfered_to_personal_nas_accounts":
        total_amount_saved_in_personal_nas_accs_today_so_far,
      "total_amount_in_active_personal_nas_accounts":
        total_amount_in_personal_nas_accounts,
      "total_transactions_done_today_so_far":
        number_of_transactions_processed_today_so_far,
      "number_of_withdrawals_made_today_so_far":
        number_of_withdraws_done_today_so_far,
      "number_of_deposits_made_today_so_far":
        number_of_deposits_done_today_so_far,
      "total_amount_withdrawn_today_so_far":
        total_amount_withdrawn_today_so_far,
      "total_amount_deposited_today_so_far":
        total_amount_deposited_today_so_far,
      "total_current_amount_in_user_wallets": total_amount_in_wallets,
      "new_user_signups_this_month_so_far": results[8].count,
      "total_lifetime_transactions_done": results[5].count,
      "number_of_pending_withdrawals": results[3].count,
      "total_user_money_in_our_bank": total_user_money,
      "monthly_active_users_so_far": results[7].count,
      "daily_active_users_so_far": results[6].count,
      "new_user_signups_today": results[9].count,
      "daily_summary_comment": "No comment",
      "registered_users": results[0].count,
    });
  } catch (e) {
    console.log(e);
  }
};

// ============================================================ Notification Functions

const get_all_notification_tokens = async (
  _supabaseClient: any,
): Promise<any> => {
  /*
        body preview
        {
            "request_type": "get_all_notification_tokens",
        }
    */

  // creates a new row in supabase
  const user_rows = await _supabaseClient.from("users").select();

  let notification_tokens = [];

  // puts all the notification tokens in the array notification_tokens
  for (let i = 0; i < user_rows["data"].length; i++) {
    notification_tokens.push(user_rows["data"][i]["notification_token"]);
  }

  console.log("The number of tokens obtained is: ", notification_tokens.length);

  return notification_tokens;
};

// ============================================================ Database Backup functions

// copies all the tables and returns them as a list/array of jsons
const create_database_backups = async (_supabaseClient: any): Promise<any> => {
  /*
        body preview
        {
            "request_type": "create_database_backups",
        }
    */

  const results = await Promise.all([
    _supabaseClient.from("account_kyc_verification_requests").select().order(
      "created_at",
      { ascending: false },
    ),
    _supabaseClient.from("contact_records").select().order("created_at", {
      ascending: false,
    }),
    _supabaseClient.from("daily_app_metrics").select().order("created_at", {
      ascending: false,
    }),
    _supabaseClient.from("no_access_savings_accounts").select().order(
      "created_at",
      { ascending: false },
    ),
    _supabaseClient.from("no_access_savings_accounts_transactions").select()
      .order("created_at", { ascending: false }),
    _supabaseClient.from("referral_commission_transactions").select().order(
      "created_at",
      { ascending: false },
    ),
    _supabaseClient.from("shared_no_access_savings_accounts").select().order(
      "created_at",
      { ascending: false },
    ),
    _supabaseClient.from("shared_no_access_savings_accounts_transactions")
      .select().order("created_at", { ascending: false }),
    _supabaseClient.from("transactions").select().order("created_at", {
      ascending: false,
    }),
    _supabaseClient.from("users").select().order("created_at", {
      ascending: false,
    }),
    _supabaseClient.from("ussd_shortcut_run_sessions").select().order(
      "created_at",
      { ascending: false },
    ),
    _supabaseClient.from("ussd_shortcuts").select().order("created_at", {
      ascending: false,
    }),
  ]);

  return results;
};

// ============================================================ Timeline functions

// shares the transactions with the user's contacts according their privacy settings
const add_post_to_contacts = async (
  supabase: any,
  body: any,
): Promise<void> => {
  /*
        body preview
        {
            "request_type": "add_post_to_contacts",
            "transaction_id": string,
            "media_details": json[],
            "user_id": string,
        }
    */

  // gets the user's account row
  const user_row = await supabase.from("users").select().eq(
    "user_id",
    body.user_id,
  );

  // stores the user's current timeline privacy setting
  const current_timeline_privacy_setting =
    user_row["data"][0]["timeline_privacy_setting"];

  let results = <any> [];

  // only if the user chooses a privacy option that isn't nobody
  if (current_timeline_privacy_setting != "Nobody") {
    if (current_timeline_privacy_setting == "All contacts") {
      // gets all the tables all at once
      results = await Promise.all([
        supabase.from("users").select().eq("user_id", body.user_id).then(
          (result: any) => result,
        ),
        supabase.from("transactions").select().eq(
          "transaction_id",
          body.transaction_id,
        ).then((result: any) => result),
        supabase.from("contact_records").select().eq(
          "uploaders_user_id",
          body.user_id,
        ).eq("is_jayben_user", true).then((result: any) => result),
      ]);
    } else if (current_timeline_privacy_setting == "All contacts except") {
      results = await Promise.all([
        supabase.from("users").select().eq("user_id", body.user_id).then(
          (result: any) => result,
        ),
        supabase.from("transactions").select().eq(
          "transaction_id",
          body.transaction_id,
        ).then((result: any) => result),
        supabase.from("contact_records").select().eq(
          "uploaders_user_id",
          body.user_id,
        ).eq("is_jayben_user", true).eq("include_to_all_contacts_except", true)
          .then((result: any) => result),
      ]);
    } else if (current_timeline_privacy_setting == "Only share with") {
      results = await Promise.all([
        supabase.from("users").select().eq("user_id", body.user_id).then(
          (result: any) => result,
        ),
        supabase.from("transactions").select().eq(
          "transaction_id",
          body.transaction_id,
        ).then((result: any) => result),
        supabase.from("contact_records").select().eq(
          "uploaders_user_id",
          body.user_id,
        ).eq("is_jayben_user", true).eq("include_to_only_share_with", true)
          .then((result: any) => result),
      ]);
    }

    // gets the uploader's account row
    const post_owner_row = results[0];

    // gets the transaction row to share with contacts
    const transaction_row = results[1];

    // gets the user's contacts that have jayben accounts
    const contacts_with_jayben_accounts_rows = results[2];

    const transaction = transaction_row["data"][0];

    console.log(`The transaction details are`, transaction);

    console.log(
      `The number of contacts to create posts for are `,
      contacts_with_jayben_accounts_rows["data"].length,
    );

    // stores all the post creation operations for each contact
    let post_creation_operations = [];

    // stores the original post's id
    const original_post_id = crypto.randomUUID();

    // for each contact, it adds an operation to create a post to each timeline
    for (
      let i = 0;
      i < contacts_with_jayben_accounts_rows["data"].length;
      i++
    ) {
      post_creation_operations.push(
        supabase.from("timeline_posts").insert({
          "user_id": contacts_with_jayben_accounts_rows["data"][i][
            "contacts_jayben_user_id"
          ],
          "post_owner_details": post_owner_row["data"][0],
          "post_type": body.media_details[0]["post_type"],
          "post_caption": transaction["comment"],
          "transaction_id": body.transaction_id,
          "original_post_id": original_post_id,
          "media_details": body.media_details,
          "post_owner_user_id": body.user_id,
          "transaction_details": transaction,
          "number_of_comments": 0,
          "number_of_replies": 0,
          "number_of_views": 0,
          "number_of_likes": 0,
          "is_published": true,
          "is_liked": false,
          "is_seen": false,
        }),
      );
    }

    // FOR POST OWNER - contains a post creation operation for the post owner
    // so that they can see their own post in their timeline and
    // be able to delete it in the future whenever we add that feature
    post_creation_operations.push(
      supabase.from("timeline_posts").insert({
        "post_owner_details": post_owner_row["data"][0],
        "post_type": body.media_details[0]["post_type"],
        "post_caption": transaction["comment"],
        "transaction_id": body.transaction_id,
        "original_post_id": original_post_id,
        "media_details": body.media_details,
        "post_owner_user_id": body.user_id,
        "transaction_details": transaction,
        "post_id": original_post_id,
        "number_of_comments": 0,
        "user_id": body.user_id,
        "number_of_replies": 0,
        "is_published": true,
        "number_of_views": 0,
        "number_of_likes": 0,
        "is_liked": false,
        "is_seen": false,
      }),
    );

    console.log("The operations to be run are: ", post_creation_operations);

    console.log(
      "Now running all post creation operations at once boss........",
    );

    // runs all the post creation operations at once
    await Promise.all(post_creation_operations);

    console.log("Finished running all post creation operations at once boss!");
  }
};

// ============================================================ Savings functions

const create_shared_no_access_savings_account = async (
  _supabase: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
        _body preview
        {
            "number_of_days": int,
            "account_name": string,
            "request_type": "create_shared_no_access_savings_account",
        }
  */

  const user_id = await get_auth_user_id(_req, _supabase);

  const user_account_row = await _supabase.from("users").select().eq(
    "user_id",
    user_id,
  );

  const user = user_account_row["data"][0];

  const expiration_date = new Date();

  expiration_date.setDate(
    expiration_date.getDate() + parseInt(_body.number_of_days),
  );

  // number of minutes until account expires
  const number_of_minutes_left = parseInt(_body.number_of_days) * 24 * 60;

  // creates a new row in the shared no access account table
  await _supabase.from("shared_no_access_savings_accounts").insert({
    account_holder_notification_token: user.notification_token,
    expiration_date_and_time: expiration_date.toISOString(),
    currency_symbol: user.currency == "ZMW" ? "K" : "",
    total_minutes_for_account: number_of_minutes_left,
    total_days_for_account: _body.number_of_days,
    last_deposit_date: new Date().toISOString(),
    user_ids_of_the_account_owners: [user_id],
    user_ids_able_to_view_accounts: [user_id],
    account_balance_shares: [{
      date_user_joined_account: new Date().toISOString(),
      names: `${user.first_name} ${user.last_name}`,
      notification_token: user.notification_token,
      profile_image_url: user.profile_image_url,
      user_is_kyc_verified: user.account_kyc_is_verified,
      currency_symbol: user.currency_symbol,
      date_user_last_deposited: null,
      number_of_deposits_made: 0,
      currency: user.currency,
      country: user.country,
      user_id: user_id,
      balance: 0,
    }],
    number_of_minutes_left: number_of_minutes_left,
    account_holder_details: {
      profile_image_url: user.profile_image_url,
      Username: user.username_searchable,
      user_is_verified: user.account_kyc_is_verified,
      first_name: user.first_name,
      last_name: user.last_name,
      user_id: user_id,
    },
    number_of_withdrawals_made_from_account: 0,
    account_type: "shared no access account",
    hide_account_balance_from_viewers: true,
    number_of_deposits_made_to_account: 0,
    account_name: _body.account_name,
    account_id: crypto.randomUUID(),
    currency: user.currency,
    country: user.country,
    number_of_members: 1,
    account_join_url: "",
    is_deleted: false,
    user_id: user_id,
    city: user.city,
    is_active: true,
    balance: 0,
  });

  return {
    message: "Shared no access account created successfully",
    status: "success",
    status_code: 200,
    data: [],
  };
};

// adds money to a shared nas account & creates a timeline post record with or without media
const add_money_to_shared_nas_account = async (
  _supabase: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
          _body preview
          {
              "comment": string,
              "account_id": string,
              "post_is_public": bool,
              "media_details": json[],
              "amount": double or float,
              "request_type": "add_money_to_shared_nas_account",
          }
  */

  const appwide_admin_settings = await _supabase.from("appwide_admin_settings")
    .select()
    .eq("record_name", "--- Timeline Settings ---");

  const default_timeline_privacy_setting = appwide_admin_settings["data"][0][
    "default_privacy_post_to_timeline_setting"
  ];

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabase);

  // gets the user's account row
  const user_row = await _supabase.from("users").select().eq(
    "user_id",
    user_id,
  );

  // stores the user row's data
  const user_row_data = user_row["data"][0];

  const transaction_id = crypto.randomUUID();

  // gets the NAS account row
  const account_row = await _supabase.from("shared_no_access_savings_accounts")
    .select().eq("account_id", _body["account_id"]);

  // stores the account row's data
  const account_row_data = account_row["data"][0];

  // calcs the user's wallet balance after sending the money
  const wallet_bal_after_transaction =
    parseFloat(user_row_data["balance"].toString()) - _body["amount"];

  // calcs the account's balance after sending the money
  const savings_acc_bal_after_transaction =
    parseFloat(account_row_data["balance"].toString()) +
    _body["amount"];

  // calcs the number of days left for the account to mature
  const days_left =
    parseFloat(account_row_data["number_of_minutes_left"].toString()) /
    60 /
    24;

  // gets a new list of the account's balance shares
  const new_account_bal_share_list = await updateSharedNasAccBalRecord({
    "account_row": account_row_data,
    "user_row": user_row_data,
    ..._body,
  });

  // checks if the user has enough money in their wallet to send
  if (parseFloat(user_row_data["balance"]) >= parseFloat(_body["amount"])) {
    await Promise.all([
      _supabase.from("transactions").insert({
        user_id: user_id,
        number_of_views: 0,
        number_of_likes: 0,
        attended_to: false,
        status: "Completed",
        currency_symbol: "K",
        number_of_replies: 0,
        sent_received: "Sent",
        deposit_details: null,
        amount: _body["amount"],
        user_is_verified: false,
        withdrawal_details: null,
        p2p_sender_details: null,
        comment: _body["comment"],
        p2p_recipient_details: null,
        transaction_fee_details: null,
        transaction_id: transaction_id,
        country: user_row_data["country"],
        is_public: _body["post_is_public"],
        currency: user_row_data["currency"],
        transaction_type: "Savings Transfer",
        method: "Shared No Access Savings Account",
        description: `To ${account_row_data["account_name"]}`,
        full_names: `${user_row_data["first_name"]} ${
          user_row_data["last_name"]
        }`,
        wallet_balance_details: {
          transaction_fee_amount: null,
          wallet_balances_difference: _body["amount"],
          wallet_balance_after_transaction: wallet_bal_after_transaction,
          wallet_balance_before_transaction: parseFloat(
            user_row_data["balance"].toString(),
          ),
        },
        savings_account_details: {
          savings_account_days_left: days_left,
          savings_account_balance_after_deposit:
            savings_acc_bal_after_transaction,
          savings_account_id: _body["account_id"],
          savings_account_name: account_row_data["account_name"],
          savings_account_type: account_row_data["account_type"],
          savings_account_balance_before_deposit: account_row_data["balance"],
        },
      }),
      _supabase.from("shared_no_access_savings_accounts").update({
        last_deposit_date: new Date().toISOString(),
        account_balance_shares: new_account_bal_share_list,
      }).eq("account_id", _body["account_id"]),
      _supabase.from("shared_no_access_savings_accounts_transactions").insert({
        full_names: `${user_row_data["first_name"]} ${
          user_row_data["last_name"]
        }`,
        savings_account_balance_details: {
          savings_account_balance_after_deposit:
            savings_acc_bal_after_transaction,
          savings_account_balance_before_deposit: account_row_data["balance"],
          savings_account_balances_difference: _body["amount"],
        },
        wallet_balance_details: {
          wallet_balance_after_transaction: wallet_bal_after_transaction,
          wallet_balance_before_transaction: user_row_data["balance"],
          wallet_balances_difference: _body["amount"],
          transaction_fee_amount: null,
        },
        account_holder_details: {
          user_is_verified: user_row_data["account_kyc_is_verified"],
          notification_token: user_row_data["notification_token"],
          profile_image_url: user_row_data["profile_image_url"],
          first_name: user_row_data["first_name"],
          last_name: user_row_data["last_name"],
          user_id: user_id,
        },
        savings_account_name: account_row_data["account_name"],
        savings_account_type: account_row_data["account_type"],
        savings_account_id: _body["account_id"],
        currency: account_row_data["currency"],
        country: account_row_data["country"],
        transaction_id: transaction_id,
        transaction_type: "Deposit",
        method: "Savings Transfer",
        description: "From wallet",
        amount: _body["amount"],
        currency_symbol: "K",
        status: "Completed",
        attended_to: false,
        user_id: user_id,
      }),
      _supabase.rpc("increase_shared_no_access_account_number_of_deposits", {
        row_id: _body["account_id"],
      }),
      _supabase.rpc("increase_shared_no_access_account_balance", {
        row_id: _body["account_id"],
        x: _body["amount"],
      }),
      _supabase.from("users").update({
        balance: wallet_bal_after_transaction,
      }).eq("user_id", user_id),
      sendNasMembersNotifications(
        _supabase,
        _body,
        account_row_data["account_balance_shares"],
      ),
    ]);
  } else {
    return {
      "message": "Insufficient funds in wallet",
      "status": "failed",
      "status_code": 400,
      "data": [],
    };
  }
};

async function sendNasMembersNotifications(
  _supabaseClient: any,
  _body: any,
  _list_of_account_members: any,
): Promise<void> {
  if (!_list_of_account_members || _list_of_account_members.length == 0) {
    return;
  }

  let list_of_notif_tokens: string[] = [];

  // adds each member's notif token to list_of_notif_tokens
  for (let i = 0; i < _list_of_account_members.length; i++) {
    if (_list_of_account_members[i].notification_token) {
      list_of_notif_tokens.push(_list_of_account_members[i].notification_token);
    }
  }

  // sends notifications to all the shared nas acc members
  await _supabaseClient.rpc("send_notifications_via_firebase", {
    body:
      `${_body.user_row.first_name} ${_body.user_row.last_name} has just deposited ` +
      `${_body.account_row.currency_symbol} ${_body.amount} to the group savings acc: ${_body.account_row.account_name}.`,
    notification_tokens: list_of_notif_tokens,
    title: "New deposit received 💰",
  });
}

async function updateSharedNasAccBalRecord(
  _transferInfo: any,
): Promise<any[]> {
  // gets a list of all the existing acc bal shares
  const existingListOfAccountBalShares: Array<any> =
    _transferInfo["account_row"]["account_balance_shares"];

  // gets the user's existing acc bal share map's index
  const index: number = existingListOfAccountBalShares.findIndex((map) =>
    map["user_id"] == _transferInfo["user_row"]["user_id"]
  );

  // gets the user's existing acc bal share map
  const existingAccountBalShareMap = existingListOfAccountBalShares[index];

  // removes the user's existing acc bal share map from the list
  existingListOfAccountBalShares.splice(index, 1);

  // user's number of times they have deposited to the account
  const newNumOfDeposits: number =
    existingAccountBalShareMap["number_of_deposits_made"] + 1;

  // the user's new acc bal share
  const newAccBalShare: number =
    parseFloat(existingAccountBalShareMap["balance"].toString()) +
    _transferInfo["amount"];

  // the user's updated acc bal share map
  const newAccountBalShareMap = {
    "date_user_joined_account":
      existingAccountBalShareMap["date_user_joined_account"],
    "user_is_kyc_verified":
      _transferInfo["user_row"]["account_kyc_is_verified"],
    "notification_token": _transferInfo["user_row"]["notification_token"],
    "profile_image_url": _transferInfo["user_row"]["profile_image_url"],
    "currency_symbol": _transferInfo["account_row"]["currency_symbol"],
    "date_user_last_deposited": new Date().toISOString(),
    "currency": _transferInfo["account_row"]["currency"],
    "country": _transferInfo["account_row"]["country"],
    "user_id": _transferInfo["user_row"]["user_id"],
    "names": existingAccountBalShareMap["names"],
    "number_of_deposits_made": newNumOfDeposits,
    "balance": newAccBalShare,
  };

  return [...existingListOfAccountBalShares, newAccountBalShareMap];
}

const get_my_shared_nas_account_transactions = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    _body preview
    {
      "request_type": "get_my_shared_nas_account_transactions",
      "savings_account_id": string
    }
  */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets a record of the savings account
  const accounts = await _supabaseClient
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("account_id", _body["savings_account_id"])
    .order("created_at", { ascending: false });

  const user_ids_able_to_view_accounts =
    accounts["data"][0]["user_ids_able_to_view_accounts"];

  if (user_ids_able_to_view_accounts.includes(user_id)) {
    // gets the account's transactions ONLY if user is part of the account
    const account_transactions = await _supabaseClient
      .from("shared_no_access_savings_accounts_transactions")
      .select()
      .eq("savings_account_id", _body["savings_account_id"])
      .order("created_at", { ascending: false });

    return {
      "data": account_transactions["data"],
      "message": "success",
      "status": "success",
      "status_code": 200,
    };
  } else {
    return {
      "message": "Denied! User not part of this account",
      "status": "failed",
      "status_code": 400,
      "data": [],
    };
  }
};

const search_username_in_db = async (
  _supabase: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    _body preview
    {
      "request_type": "search_username_in_db",
      "username": string
    }
  */

  const user_id = await get_auth_user_id(_req, _supabase);

  if (user_id != null) {
    const username_search_results = await _supabase
      .from("users")
      .select()
      .ilike("username_searchable", `%${_body.username.toLowerCase()}%`);

    return {
      "data": username_search_results,
      "message": "success",
      "status": "success",
      "status_code": 200,
    };
  } else {
    return {
      "message": "Unauthorized access",
      "status": "failed",
      "status_code": 401,
      "data": [],
    };
  }
};

const add_person_to_nas_account = async (
  _supabase: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
  _body preview
    {
      "user_id_for_person_joining": user_id_for_person_joining,
      "request_type": "add_person_to_nas_account",
      "account_id": string,
    }
  */

  const person_joining_user_row = await _supabase.from("users").select().eq(
    "user_id",
    _body["user_id_for_person_joining"],
  );

  const person_joining_user_map = person_joining_user_row["data"][0];

  // gets the account row
  const account_row = await _supabase
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("account_id", _body.account_id);

  const account_map = account_row.data[0];

  const my_user_id = await get_auth_user_id(_req, _supabase);

  // if user is not part of the shared nas account
  if (
    account_map.user_ids_able_to_view_accounts
      .includes(my_user_id) == false
  ) {
    return {
      message: `Permission denied. Not part of savings account`,
      status: "failed",
      status_code: 400,
    };
  }

  // if friend that is already added to shared nas account
  if (
    account_map.user_ids_able_to_view_accounts
      .includes(person_joining_user_map.user_id)
  ) {
    return {
      message:
        `${person_joining_user_map.first_name} ${person_joining_user_map.last_name} is already part of the account`,
      status: "failed",
      status_code: 400,
    };
  } else {
    // calculates the new number of members
    const num_of_members = account_map.number_of_members + 1;

    // updates the shared nas account row
    await _supabase.from("shared_no_access_savings_accounts").update({
      account_balance_shares: [
        {
          names:
            `${person_joining_user_map.first_name} ${person_joining_user_map.last_name}`,
          user_is_kyc_verified: person_joining_user_map.account_kyc_is_verified,
          notification_token: person_joining_user_map.notification_token,
          profile_image_url: person_joining_user_map.profile_image_url,
          currency_symbol: person_joining_user_map.currency_symbol,
          date_user_joined_account: new Date().toISOString(),
          currency: person_joining_user_map.currency,
          country: person_joining_user_map.country,
          user_id: person_joining_user_map.user_id,
          date_user_last_deposited: null,
          number_of_deposits_made: 0,
          balance: 0,
        },
        ...account_map.account_balance_shares,
      ],
      user_ids_able_to_view_accounts: [
        ...account_map.user_ids_able_to_view_accounts,
        person_joining_user_map.user_id,
      ],
      number_of_members: num_of_members,
    }).eq("account_id", _body.account_id);

    // sends notification to the added user
    await _supabase.rpc("send_notifications_via_firebase", {
      body: `You have been added to a Group NAS account 😎`,
      notification_tokens: [person_joining_user_map.notification_token],
      title: "You have been added 💪",
    });

    return {
      message:
        `${person_joining_user_map.first_name} ${person_joining_user_map.last_name} ` +
        `has been added successfully`,
      status: "success",
      status_code: 200,
    };
  }
};

const join_shared_nas_account = async (
  _supabase: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    _body preview
    {
      "request_type": "join_shared_nas_account",
      "account_id": string
    }
  */

  const user_id = await get_auth_user_id(_req, _supabase);

  if (user_id == null) {
    return {
      message: "Unauthorized access. Login to join account",
      status: "failed",
      status_code: 401,
    };
  }

  // gets the account row
  const account_row = await _supabase
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("account_id", _body.account_id);

  const user_row = await _supabase.from("users").select().eq(
    "user_id",
    user_id,
  );

  const user_map = user_row["data"][0];

  const account_map = account_row["data"][0];

  // calculates the new number of members
  const num_of_members = account_map.number_of_members + 1;

  // if friend is already added to shared nas account
  if (account_map.user_ids_able_to_view_accounts.includes(user_id)) {
    return {
      message: "You are already part of the account",
      status: "failed",
      status_code: 400,
    };
  }

  // updates the shared nas account row
  await _supabase.from("shared_no_access_savings_accounts").update({
    account_balance_shares: [
      {
        user_is_kyc_verified: user_map.account_kyc_is_verified,
        names: `${user_map.first_name} ${user_map.last_name}`,
        date_user_joined_account: new Date().toISOString(),
        notification_token: user_map.notification_token,
        profile_image_url: user_map.profile_image_url,
        currency_symbol: user_map.currency_symbol,
        date_user_last_deposited: null,
        currency: user_map.currency,
        number_of_deposits_made: 0,
        country: user_map.country,
        user_id: user_id,
        balance: 0,
      },
      ...account_map.account_balance_shares,
    ],
    user_ids_able_to_view_accounts: [
      ...account_map.user_ids_able_to_view_accounts,
      user_id,
    ],
    number_of_members: num_of_members,
  }).eq("account_id", _body.account_id);

  return {
    message: "Successfully joined account",
    status: "success",
    status_code: 200,
  };
};

const extend_shared_nas_account_days = async (
  _supabase: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    _body preview
    {
      "request_type": "extend_shared_nas_account_days",
      "days_to_extend": int,
      "account_id": string
    }
  */

  const user_id = await get_auth_user_id(_req, _supabase);

  // gets the account row
  const account_row = await _supabase
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("account_id", _body["account_id"]);

  const account_info = account_row["data"][0];

  const account_members_user_ids =
    account_info["user_ids_able_to_view_accounts"];

  // only the account members can extend the account
  if (account_members_user_ids.includes(user_id)) {
    const days_to_extend = _body["days_to_extend"];

    const days_to_extend_by_in_minutes = parseFloat(days_to_extend.toString()) *
      24 * 60;

    // calculates the new number of minutes left
    const number_of_minutes_left = account_info["number_of_minutes_left"] +
      days_to_extend_by_in_minutes;

    // calcs the new total number of days
    const total_number_of_days =
      parseInt(account_info["total_days_for_account"].toString()) +
      parseInt(days_to_extend.toString());

    // converts days to minutes
    const total_minutes_for_account = total_number_of_days * 24 * 60;

    // holds the current expiration date
    const expiration_date = new Date(account_info["expiration_date_and_time"]);

    // holds the new expiration date (current expiration date + number of days to extend)
    const new_expiration_date = new Date(
      expiration_date.getTime() + days_to_extend * 24 * 60 * 60 * 1000,
    );

    // updates the shared nas account row
    await _supabase
      .from("shared_no_access_savings_accounts")
      .update({
        expiration_date_and_time: new_expiration_date.toISOString(),
        total_minutes_for_account: total_minutes_for_account,
        number_of_minutes_left: number_of_minutes_left,
        total_days_for_account: total_number_of_days,
      })
      .eq("account_id", account_info["account_id"]);

    // calcs the current days left before the extension
    const current_days_left =
      parseInt(account_info["number_of_minutes_left"].toString()) / (24 * 60);

    // creates a record showing that the user had made an extension
    await _supabase
      .from("nas_account_extensions")
      .insert({
        minutes_left_before_extension: account_info["number_of_minutes_left"],
        total_days_before_extension: account_info["total_days_for_account"],
        minutes_left_after_extension: number_of_minutes_left,
        total_days_after_extension: total_number_of_days,
        days_left_before_extension: current_days_left,
        account_map_before_extension: account_info,
        account_type: account_info["account_type"],
        account_name: account_info["account_name"],
        account_balance: account_info["balance"],
        account_id: account_info["account_id"],
        days_extended_by: days_to_extend,
        user_id: user_id, // Get user_id from request
      });

    return {
      message: "Successfully extended account",
      status: "success",
      status_code: 200,
      data: [],
    };
  } else {
    return {
      message: "Unauthorized access",
      status: "failed",
      status_code: 401,
      data: [],
    };
  }
};

const donate_to_shared_nas_account = async (
  _supabase: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
    body preview
    {
      "request_type": "donate_to_shared_nas_account",
      "account_id": string,
      "amount": double or float,
    }
  */

  const user_id = await get_auth_user_id(_req, _supabase);

  const account_info = await _supabase.from("shared_no_access_savings_accounts")
    .select()
    .eq("account_id", _body["account_id"]);

  const account_map = account_info["data"][0];

  // only the account members can donate
  if (user_id == null) {
    return {
      "message": "Unauthorized access",
      "status": "failed",
      "status_code": 401,
      "data": [],
    };
  } else {
    // gets the donor user's account row
    const user_row = await _supabase.from("users").select().eq(
      "user_id",
      user_id,
    );

    const user_map = user_row["data"][0];

    const transaction_id = crypto.randomUUID();

    // calculates balances
    const wallet_bal_after_transaction = user_map["balance"] - _body["amount"];
    const savings_acc_bal_after_transaction = account_map["balance"] +
      _body["amount"];
    const days_left = account_map["number_of_minutes_left"] / 60 / 24;

    // only proceed if user has sufficient balance
    if (user_map["balance"] >= _body["amount"]) {
      await Promise.all([
        _supabase.from("transactions").insert({
          comment: "",
          user_id: user_id,
          is_public: false,
          number_of_views: 0,
          number_of_likes: 0,
          attended_to: false,
          status: "Completed",
          currency_symbol: "K",
          number_of_replies: 0,
          sent_received: "Sent",
          deposit_details: null,
          amount: _body["amount"],
          withdrawal_details: null,
          p2p_sender_details: null,
          p2p_recipient_details: null,
          country: user_map["country"],
          transaction_fee_details: null,
          currency: user_map["currency"],
          transaction_id: transaction_id,
          transaction_type: "Savings Transfer",
          method: "Shared No Access Savings Account",
          description: `To ${account_map["account_name"]}`,
          user_is_verified: user_map["account_kyc_is_verified"],
          full_names: `${user_map["first_name"]} ${user_map["last_name"]}`,
          wallet_balance_details: {
            wallet_balances_difference: _body["amount"],
            wallet_balance_before_transaction: user_map["balance"],
            wallet_balance_after_transaction: wallet_bal_after_transaction,
          },
          savings_account_details: {
            savings_account_days_left: days_left,
            savings_account_id: _body["account_id"],
            savings_account_name: account_map["account_name"],
            savings_account_type: account_map["account_type"],
            savings_account_balance_before_deposit: account_map["balance"],
            savings_account_balance_after_deposit:
              savings_acc_bal_after_transaction,
          },
        }),
        _supabase.from("shared_no_access_savings_accounts_transactions").insert(
          {
            savings_account_balance_details: {
              savings_account_balance_after_deposit:
                savings_acc_bal_after_transaction,
              savings_account_balance_before_deposit: account_map["balance"],
              savings_account_balances_difference: _body["amount"],
            },
            wallet_balance_details: {
              wallet_balance_after_transaction: wallet_bal_after_transaction,
              wallet_balance_before_transaction: user_map["balance"],
              wallet_balances_difference: _body["amount"],
            },
            full_names: `${user_map["first_name"]} ${user_map["last_name"]}`,
            currency_symbol: user_map["currency"] == "ZMW" ? "K" : "",
            savings_account_name: account_map["account_name"],
            savings_account_type: account_map["account_type"],
            account_holder_details: {
              notification_token: user_map["notification_token"],
              profile_image_url: user_map["profile_image_url"],
              user_is_verified: user_map["account_kyc_is_verified"],
              first_name: user_map["first_name"],
              last_name: user_map["last_name"],
              user_id: user_id,
            },
            savings_account_id: _body["account_id"],
            transaction_id: transaction_id,
            currency: user_map["currency"],
            country: user_map["country"],
            transaction_type: "Deposit",
            method: "Savings Transfer",
            description: "From wallet",
            amount: _body["amount"],
            status: "Completed",
            attended_to: false,
            user_id: user_id,
          },
        ),
        _supabase.rpc("increase_shared_no_access_account_number_of_deposits", {
          row_id: _body["account_id"],
        }),
        _supabase.rpc("increase_shared_no_access_account_balance", {
          row_id: _body["account_id"],
          x: _body["amount"],
        }),
        _supabase.from("users").update({
          balance: wallet_bal_after_transaction,
        }).eq("user_id", user_id),
        update_owner_shared_nas_acc_bal_record({
          account_map: account_map,
          user_map: user_map,
          ..._body,
        }, _supabase),
      ]);
    } else {
      return {
        message: "Insufficient balance",
        status: "failed",
        status_code: 400,
        data: [],
      };
    }

    return {
      "message": "Successfully donated",
      "status": "success",
      "status_code": 200,
      "data": [],
    };
  }
};

// REDO THIS FUNCTION AND MAKE IT SIMPLER
// updates the user's account balance record within the NAS account row
async function update_owner_shared_nas_acc_bal_record(
  _transferInfo: any,
  _supabase: any,
): Promise<void> {
  /*
    _transferInfo Preview:
    {
      "request_type": "donate_to_shared_nas_account",
      "amount": double or float,
      "account_id": stirng,
      "account_map": map,
      "user_map": map,
    }
  */

  // gets a list of all the existing acc bal shares
  const existingListOfAccountBalShares: Array<any> =
    _transferInfo["account_map"]["account_balance_shares"];

  // gets the owner's existing acc bal share map's index
  const index: number = existingListOfAccountBalShares.findIndex(
    (map: any) => map["user_id"] == _transferInfo["account_map"]["user_id"],
  );

  // gets owner's the existing acc bal share map
  const existingAccountBalShareMap = existingListOfAccountBalShares[index];

  // removes the owner's existing acc bal share map from list
  existingListOfAccountBalShares.splice(index, 1);

  // owner's number of times they have deposited to the account
  const newNumOfDeposits: number =
    existingAccountBalShareMap["number_of_deposits_made"] + 1;

  // the owner's new acc bal share
  const newAccBalShare: number =
    parseFloat(existingAccountBalShareMap["balance"].toString()) +
    _transferInfo["amount"];

  // the owner's updated acc bal share map
  const newAccountBalShareMap = {
    date_user_joined_account:
      existingAccountBalShareMap["date_user_joined_account"],
    date_user_last_deposited:
      existingAccountBalShareMap["date_user_last_deposited"],
    user_is_kyc_verified: existingAccountBalShareMap["user_is_kyc_verified"],
    notification_token: existingAccountBalShareMap["notification_token"],
    profile_image_url: existingAccountBalShareMap["profile_image_url"],
    currency_symbol: existingAccountBalShareMap["currency_symbol"],
    currency: existingAccountBalShareMap["currency"],
    country: existingAccountBalShareMap["country"],
    user_id: existingAccountBalShareMap["user_id"],
    names: existingAccountBalShareMap["names"],
    number_of_deposits_made: newNumOfDeposits,
    balance: newAccBalShare,
  };

  // updates the NAS account's row
  await _supabase.from("shared_no_access_savings_accounts").update({
    last_deposit_date: new Date().toISOString(),
    account_balance_shares: [
      ...existingListOfAccountBalShares,
      newAccountBalShareMap,
    ],
  }).eq("account_id", _transferInfo["account_id"]);

  // sends notifications to all the members in the shared nas account
  await send_notifications_to_all_nas_members(
    _supabase,
    {
      donor_notification_token: _transferInfo["user_map"]["notification_token"],
      currency_symbol: _transferInfo["account_map"]["currency_symbol"],
      account_name: _transferInfo["account_map"]["account_name"],
      donor_first_name: _transferInfo["user_map"]["first_name"],
      donor_last_name: _transferInfo["user_map"]["last_name"],
      account_id: _transferInfo["account_id"],
      amount: _transferInfo["amount"],
    },
  );
}

// sends notifications to all the members in the shared nas account
const send_notifications_to_all_nas_members = async (
  _supabaseClient: any,
  _body: any,
): Promise<void> => {
  // get's the shared nas account row
  const results = await _supabaseClient
    .from("shared_no_access_savings_accounts")
    .select()
    .eq("account_id", _body["account_id"]);

  if (results["data"].length == 0) return;

  // stores list of shared nas acc members
  const members = results["data"][0]["account_balance_shares"];

  const list_of_notif_tokens: string[] = [];

  // adds each member's notif token to list_of_notif_tokens
  for (let i = 0; i < members.length; i++) {
    if (members[i]["notification_token"]) {
      list_of_notif_tokens.push(members[i]["notification_token"]);
    }
  }

  // 1). sends notifications to all the other shared nas acc members
  // 2). sends a notification to the donor
  await Promise.all([
    _supabaseClient.rpc("send_notifications_via_firebase", {
      body:
        `${_body["donor_first_name"]} ${
          _body["donor_last_name"]
        } has just donated ${_body["currency_symbol"]} ${_body["amount"]} ` +
        `to the Group NAS acc: ${_body["account_name"]}.`,
      notification_tokens: list_of_notif_tokens,
      title: "New deposit received 💰",
    }),
    _supabaseClient.rpc("send_notifications_via_firebase", {
      body:
        `You have just donated ${_body["currency_symbol"]} ${
          _body["amount"]
        } ` +
        `to the Group NAS acc: ${_body["account_name"]}.`,
      notification_tokens: [_body["donor_notification_token"]],
      title: "Donation Successful",
    }),
  ]);
};

// ============================================================ Contact Functions

// when a new user joins jayben and they are already part of someone's uploaded
// contacts, this function marks their contact as a user of jayben in their contact record
const mark_contact_as_existing_jayben_user = async (
  _supabase: any,
  _body: any,
): Promise<void> => {
  /*
        body preview
        {
            "request_type": "mark_contact_as_existing_jayben_user",
            "user_id": string,
        }
    */

  // gets the user's jayben account row
  const users_jayben_account_row = await _supabase.from("users").select().eq(
    "user_id",
    _body.user_id,
  );

  // stores the user's supabase account row
  const user_row = users_jayben_account_row["data"][0];

  // gets a list of rows that have this phone number from contact records
  const contacts_with_phone_number = await _supabase.from("contact_records")
    .select().eq("contacts_phone_number", user_row["phone_number"]).eq(
      "is_jayben_user",
      false,
    );

  let update_contact_records_operations = [];

  for (let i = 0; i < contacts_with_phone_number["data"].length; i++) {
    update_contact_records_operations.push(
      _supabase.from("contact_records").update({
        "contacts_country_code": `+${user_row["country_code"]}`,
        "date_joined_jayben": new Date().toISOString(),
        "contacts_jayben_account_details": user_row,
        "contacts_jayben_user_id": _body.user_id,
        "is_jayben_user": true,
      }).eq("contact_id", contacts_with_phone_number["data"][i]["contact_id"]),
    );
  }

  // runs all the operations all at once
  await Promise.all(update_contact_records_operations);
};

// 1). Processed contacts to a workable format
// 2). Checks which contacts haven't yet been uploaded
// 3). Check if contacts that havent been uploaded belong to existing users
// 4). Creates rows for each contact that hasn't been uploaded yet
const initiate_contacts_upload = async (
  _supabase: any,
  _req_body: any,
): Promise<void> => {
  /*
        body preview
        {
            "phone_number_to_verify_if_jayben_user": null,
            "request_type": "initiate_contacts_upload",
            "type_of_operation": string,
            "raw_contacts": json[],
            "user_id": string,
        }
    */

  // formats the raw_contacts to a decent and usable format
  // and then returns a list of processed contacts batches
  // of 100 contacts per batch that can be worked on batch by batch
  // so that the server doesnt get overwhelmed & overloaded
  const processed_contacts_batches = await process_contacts_to_suitable_format(
    _req_body,
  );

  let operations_to_run = [];

  // runs for loop for each batch of contacts
  for (let i = 0; i < processed_contacts_batches.length; i++) {
    console.log(`Adding the function number ${i + 1}...`);

    operations_to_run.push(
      check_if_contact_already_exists_and_create_contact_record(_supabase, {
        batched_contacts: processed_contacts_batches[i],
        user_id: _req_body.user_id,
      }),
    );

    console.log(`Done adding the function number ${i + 1}`);
  }

  console.log("Now calling all https functions all at once boss........");

  // runs all the operations all at once
  await Promise.all(operations_to_run);

  console.log("Finished calling all https functions all at once boss!");
};

// converts raw_contacts to a formatted & clean format
const process_contacts_to_suitable_format = async (
  _req_body: any,
): Promise<any> => {
  const raw_contacts = _req_body.raw_contacts;

  let current_contacts_batch = [];

  let contact_batches = [];

  for (let i = 0; i < raw_contacts.length; i++) {
    const contact = raw_contacts[i];

    if (contact.phones.length != 0) {
      const specialCharsRegex = /[!@#$%^&*()_\-=\[\]{};':"\\|,.<>\/?]+/g;

      const raw_phone_number = contact.phones[0].value
        .replace(specialCharsRegex, "")
        .replace("+26", "")
        .replace(/\s/g, "")
        .replace("(", "")
        .replace(")", "")
        .replace("-", "")
        .replace("#", "");

      let is_invalid_phone_number = false;

      let final_phone_number = "";

      let country_code = "";

      if (raw_phone_number.length == 10) {
        final_phone_number = `+26${raw_phone_number}`;
        country_code = "+260";
      } else if (raw_phone_number.length == 9) {
        final_phone_number = `+260${raw_phone_number}`;
        country_code = "+260";
      } else if (raw_phone_number.length > 10) {
        final_phone_number = raw_phone_number;
      } else if (raw_phone_number.length < 9) {
        is_invalid_phone_number = true;
      }

      // adds contact to current batch
      current_contacts_batch.push(
        {
          "is_invalid_phone_number": is_invalid_phone_number,
          "display_name": contact.displayName,
          "phone_number": final_phone_number,
          "country_code": country_code,
        },
      );

      // Check if the current batch size reaches 100 or it's the last contact
      if (current_contacts_batch.length == 20 || i == raw_contacts.length - 1) {
        contact_batches.push(current_contacts_batch);
        current_contacts_batch = [];
        // Clear the batch for the next set of contacts
      }
    }
  }

  return contact_batches;
};

// 1). Processed contacts to a workable format
// 2). Checks which contacts haven't yet been uploaded
// 3). Check if contacts that havent been uploaded belong to existing users
// 4). Creates rows for each contact that hasn't been uploaded yet
const check_if_contact_already_exists_and_create_contact_record = async (
  _supabase: any,
  _body: any,
): Promise<void> => {
  /*
        body preview
        {
            "batched_contacts": json[],
            "user_id": string,
        }
    */

  // stores the current batch of contacts
  const processed_contacts = _body.batched_contacts;

  let check_if_already_uploaded_operations = [];

  // adds each processed contact a list of of contacts so that they can be checked
  // if they have already been uploaded to the database
  for (let h = 0; h < processed_contacts.length; h++) {
    // adds the checking operation to a list of operations that need to be run
    check_if_already_uploaded_operations.push(
      _supabase.from("contact_records").select().eq(
        "uploaders_user_id",
        _body.user_id,
      ).eq("contacts_phone_number", processed_contacts[h].phone_number).then(
        (result: any) => result,
      ),
    );
  }

  // runs the promise operations that check if contacts have already been uploaded
  const results = await Promise.all(check_if_already_uploaded_operations);

  let check_if_contact_is_jayben_user = [];

  let list_of_contacts_to_create = [];

  for (let i = 0; i < results.length; i++) {
    // if contact has NOT been uploaded yet
    if (results[i]["data"]?.length == 0) {
      // adds contact to list where it gets checked
      // to see if contact is existing jayben user
      check_if_contact_is_jayben_user.push(
        _supabase.from("users").select().eq(
          "phone_number",
          processed_contacts[i].phone_number,
        ).then((result: any) => result),
      );

      // keeps track of which contacts are
      // not already uploaded to the database
      // and need to be created
      list_of_contacts_to_create.push(
        processed_contacts[i],
      );
    } else {
    }
  }

  // runs a check to see if contacts are already jayben users
  const results_2 = await Promise.all(check_if_contact_is_jayben_user);

  // list of all the contact maps to create
  let row_data_for_contacts_to_create = [];

  for (let j = 0; j < results_2.length; j++) {
    // ONLY IF PHONE NUMBER IS NOT EMPTY
    if (list_of_contacts_to_create[j].phone_number != "") {
      // if the contact is NOT existing jayben user
      if (results_2[j]["data"].length == 0) {
        // stores the contact's display name
        const display_name =
          list_of_contacts_to_create[j].display_name == null ||
            list_of_contacts_to_create[j].display_name == ""
            ? list_of_contacts_to_create[j].phone_number
            : list_of_contacts_to_create[j].display_name;

        // adds contact's map to list of maps to create
        row_data_for_contacts_to_create.push(
          {
            "contacts_phone_number_with_country_code":
              list_of_contacts_to_create[j].phone_number,
            "contacts_country_code": list_of_contacts_to_create[j].country_code,
            "contacts_phone_number": list_of_contacts_to_create[j].phone_number,
            "contacts_jayben_account_details": null,
            "include_to_all_contacts_except": false,
            "contacts_display_name": display_name,
            "include_to_only_share_with": false,
            "uploaders_user_id": _body.user_id,
            "contacts_jayben_user_id": null,
            "date_joined_jayben": null,
            "is_jayben_user": false,
          },
        );
      } else {
        // if the contact is ALREADY an existing jayben user

        // stores the contact's display name
        const display_name =
          list_of_contacts_to_create[j].display_name == null ||
            list_of_contacts_to_create[j].display_name == ""
            ? `${results_2[j]["data"][0]["first_name"]} ${
              results_2[j]["data"][0]["last_name"]
            }`
            : list_of_contacts_to_create[j].display_name;

        // and only if the number isn't empty
        // adds contact's map to list of maps to create
        row_data_for_contacts_to_create.push(
          {
            "contacts_phone_number_with_country_code":
              list_of_contacts_to_create[j].phone_number,
            "contacts_country_code": list_of_contacts_to_create[j].country_code,
            "contacts_phone_number": list_of_contacts_to_create[j].phone_number,
            "contacts_jayben_user_id": results_2[j]["data"][0]["user_id"],
            "date_joined_jayben": results_2[j]["data"][0]["created_at"],
            "contacts_jayben_account_details": results_2[j]["data"][0],
            "include_to_all_contacts_except": false,
            "contacts_display_name": display_name,
            "include_to_only_share_with": false,
            "uploaders_user_id": _body.user_id,
            "is_jayben_user": true,
          },
        );
      }
    }
  }

  console.log("Now creating supabase records of the contacts boss....");

  // creates the records all at once using the list of contact maps to create
  await _supabase.from("contact_records").insert(
    row_data_for_contacts_to_create,
  );

  console.log("DONE creating supabase records of the contacts boss!");
};

// ============================================================ Fraud Check functions

const scan_all_user_accounts_for_fraud_at_once = async (
  _supabase: any,
): Promise<void> => {
  // gets the user rows in batches
  const user_batches = await get_user_rows_in_batches_to_scan(_supabase);

  let http_functions_to_call = [];

  // runs for loop for each batch of contacts
  for (let i = 0; i < user_batches.length; i++) {
    http_functions_to_call.push(
      fetch(
        new Request(
          "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
          {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${Deno.env.get("SUPABASE_ANON_KEY")}`,
              "content-type": "application/json",
            },
            body: JSON.stringify({
              "request_type": "run_each_user_through_fraud_check_algo",
              user_rows: user_batches[i],
            }),
          },
        ),
      ),
    );
  }

  console.log("Now calling all https functions all at once boss........");

  // runs all the operations all at once
  await Promise.all(http_functions_to_call);
};

const get_user_rows_in_batches_to_scan = async (
  _supabase: any,
): Promise<any> => {
  // gets all the user rows
  const user_rows = await _supabase.from("users").select();

  let current_user_batch = [];

  let all_user_batches = [];

  // for each user row, it adds row to a batch
  for (let i = 0; i < user_rows["data"].length; i++) {
    // adds the current user account to the current batch
    current_user_batch.push(user_rows["data"][i]);

    // Check if the current batch size reaches 20 or it's the last contact
    if (current_user_batch.length == 20 || i == user_rows["data"].length - 1) {
      all_user_batches.push(current_user_batch);
      current_user_batch = [];
    }
  }

  return all_user_batches;
};

// receives a list of users and scans them for fraud
const run_each_user_through_fraud_check_algo = async (
  body: any,
): Promise<void> => {
  /*
        body preview
        {
            "request_type": "run_each_user_through_fraud_check_algo",
            "user_rows": json[],
        }
    */

  // stores the current batch of contacts
  const processed_user_rows = body.user_rows;

  let create_copy_operations_list = [];

  // adds each processed contact a list of of contacts so that they can be checked
  // if they have already been uploaded to the database
  for (let i = 0; i < processed_user_rows.length; i++) {
    const user_row = processed_user_rows[i];

    // adds the checking operation to a list of operations that need to be run
    create_copy_operations_list.push(
      fetch(
        new Request(
          "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/check_for_fraudulent_transactions",
          {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${Deno.env.get("SUPABASE_ANON_KEY")}`,
              "content-type": "application/json",
            },
            body: JSON.stringify({
              user_id: user_row["user_id"],
            }),
          },
        ),
      ),
    );
  }

  console.log("Now creating supabase records of the contacts boss....");

  // calls a fraud checks at once
  await Promise.all(create_copy_operations_list);

  console.log("DONE creating supabase records of the contacts boss!");
};
