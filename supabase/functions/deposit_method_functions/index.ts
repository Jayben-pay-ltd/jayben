// deno-lint-ignore-file
// deno-lint-ignore-file no-explicit-any require-await
import { axiod } from "https://deno.land/x/axiod/mod.ts";
import { RSA } from "https://deno.land/x/god_crypto@v1.4.11/mod.ts";
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { Jwt } from "https://deno.land/x/hono@v3.8.0-rc.2/utils/jwt/index.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7&no-check";

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
    {
      global: { headers: { Authorization: req.headers.get("Authorization")! } },
      auth: {
        detectSessionInUrl: false,
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );

  let data_to_return_in_response: any = "Done boss!";

  try {
    switch (body.request_type) {
      case "zambia_broad_pay_init_mobile_money_ussd":
        data_to_return_in_response =
          await zambia_broad_pay_init_mobile_money_ussd(
            supabaseClient,
            req,
            body,
          );
        break;

      case "zambia_broad_pay_get_checkout_link":
        data_to_return_in_response = zambia_broad_pay_get_checkout_link(
          supabaseClient,
          req,
          body,
        );
        break;

      case "zambia_broad_pay_webhook":
        data_to_return_in_response = await zambia_broad_pay_webhook(
          supabaseClient,
          req,
          body,
        );
        break;

      case "check_if_checkout_payment_is_completed":
        await check_if_checkout_payment_is_completed(supabaseClient, req, body);
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
): Promise<string> => {
  const token = _req.headers.get("Authorization")!.replace("Bearer ", "");

  const { data } = await _supabaseClient.auth.getUser(token);

  const user = data.user;

  return user.uid;
};

//  =================================================== Zambia Deposit Methods

const zambia_broad_pay_init_mobile_money_ussd = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
) => {
  /*
      body preview
      {
        "request_type": "zambia_broad_pay_init_mobile_money_ussd",
        "deposit_details": {
            "phone_number": "0977980371",
            "amount": num/float
        },
      }
    */

  const deposit_id = crypto.randomUUID();

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the user's account row
  const res = await _supabaseClient.from("users").select().eq(
    "user_id",
    user_id,
  );

  const user_row = res["data"][0];

  // send a firebase notification to the user telling them deposit is initated
  await _supabaseClient.rpc("send_notifications_via_firebase", {
    title: `Deposit Initiated`,
    body:
      "Deposit has been initiated. You will receive a USSD popup asking you to confirm your Mobile money PIN.",
    notif_tokens: [user_row["notification_token"]],
  });

  // gets the broadpay keys
  const appwide_settings_res = await _supabaseClient.from(
    "appwide_admin_settings_private",
  )
    .select()
    .eq("record_name", "---- Zambia BroadPay ----")
    .order("created_at", { ascending: false });

  const depo_url =
    appwide_settings_res["data"][0]["record_contents"]["collect_payment_url"];

  const webhook_url =
    appwide_settings_res["data"][0]["record_contents"]["webhook_url"];

  const secret_key =
    appwide_settings_res["data"][0]["record_contents"]["secret_key"];

  const public_key =
    appwide_settings_res["data"][0]["record_contents"]["public_key"];

  const charge_me = appwide_settings_res["data"][0]["record_contents"][
    "charge_jayben_deposit_fee"
  ];

  //   initializes a mobile money deposit request
  const data = await axiod.post(depo_url, {
    payload: Jwt.sign(
      JSON.stringify({
        "customerFirstName": `${user_row["first_name"]} ${
          user_row["last_name"]
        }`,
        "customerLastName": `${user_row["user_id"]}`,
        "wallet": _body.deposit_details.PhoneNumber,
        "customerPhone": user_row["phone_number"],
        "amount": _body.deposit_details.Amount,
        "customerEmail": user_row["currency"],
        "transactionReference": deposit_id,
        "currency": user_row["currency"],
        "merchantPublicKey": public_key,
        "transactionName": user_id,
        "webhookUrl": webhook_url,
        "chargeMe": charge_me,
      }),
      secret_key,
    ),
  });

  console.log("BBBBBB");

  //  creates a deposit request row
  await _supabaseClient.from("deposit_requests").insert({
    "deposit_method": "zambia mobile money via broadpay zambia",
    "additional_details": {
      "merchant_reference": data.data.transactionReference,
      "request_message": data.data.message,
      "reference": data.data.reference,
    },
    "notification_token": user_row["notification_token"],
    "phone_number": _body.deposit_details.phone_number,
    "transaction_name": "jayben deposit to wallet",
    "currency_symbol": user_row["currency_symbol"],
    "amount": _body.deposit_details.amount,
    "first_name": user_row["first_name"],
    "last_name": user_row["last_name"],
    "reference": data.data.reference,
    "currency": user_row["currency"],
    "country": user_row["country"],
    "completion_timestamp": null,
    "deposit_status": "pending",
    "email": user_row["email"],
    "checkout_link_url": null,
    "deposit_id": deposit_id,
    "error_message": null,
    "user_id": user_id,
  });
};

// gets a checkout link from broadpay and returns it
const zambia_broad_pay_get_checkout_link = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
      body preview
      {
        "request_type": "zambia_broad_pay_get_checkout_link",
        "amount: float/num
      }
    */

  const deposit_id = crypto.randomUUID();

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the user's account row
  const res = await _supabaseClient.from("users").select().eq(
    "user_id",
    user_id,
  );

  const user_row = res["data"][0];

  //   creates a new deposit request row
  await _supabaseClient.from("deposit_requests").insert({
    "deposit_method": "zambia checkout link via broadpay zambia",
    "additional_details": {
      "merchant_reference": null,
      "request_message": null,
      "reference": null,
    },
    "notification_token": user_row["notification_token"],
    "transaction_name": "jayben deposit to wallet",
    "currency_symbol": user_row["currency_symbol"],
    "phone_number": user_row["phone_number"],
    "first_name": user_row["first_name"],
    "last_name": user_row["last_name"],
    "currency": user_row["currency"],
    "country": user_row["country"],
    "completion_timestamp": null,
    "deposit_status": "pending",
    "email": user_row["email"],
    "checkout_link_url": null,
    "deposit_id": deposit_id,
    "amount": _body.amount,
    "error_message": null,
    "user_id": user_id,
    "reference": null,
  });

  // gets the broadpay keys
  const appwide_settings_res = await _supabaseClient.from(
    "appwide_admin_settings_private",
  )
    .select()
    .eq("record_name", "---- Zambia BroadPay ----")
    .order("created_at", { ascending: false });

  const checkout_url =
    appwide_settings_res["data"][0]["record_contents"]["get_checkout_link_url"];

  const public_key =
    appwide_settings_res["data"][0]["record_contents"]["public_key"];

  let generated_checkout_url: any = "";

  // generates the checkout link
  axiod({
    method: "post",
    url: checkout_url,
    data: {
      "customerFirstName": user_row["first_name"],
      "customerPhone": user_row["phone_number"],
      "customerLastName": user_row["last_name"],
      "customerEmail": user_row["email"],
      "transactionReference": deposit_id,
      "currency": user_row["currency"],
      "merchantPublicKey": public_key,
      "transactionName": user_id,
      "amount": _body.amount,
    },
  }).then(async function (response) {
    console.log(response.data);

    if (
      response.data.message === "" && !response.data.isError &&
      response.data.paymentUrl !== ""
    ) {
      // updates the deposit request with the checkout link
      await _supabaseClient.from("deposit_requests").update({
        "checkout_link_url": response.data.paymentUrl,
        "additional_details": {
          "reference": response.data.reference,
          "merchant_reference": null,
          "request_message": null,
        },
        "reference": response.data.reference,
      }).eq("deposit_id", deposit_id);

      generated_checkout_url = response.data.paymentUrl;
    }
  }).catch(async function (error) {
    console.log(error);

    // marks the deposit request as failed
    await _supabaseClient.from("deposit_requests").update({
      "error_message": "There was an error generating checkout link",
      "completion_timestamp": new Date().toISOString(),
      "transaction_status": "failed",
    }).eq("deposit_id", deposit_id);
  });

  return {
    "checkout_link_url": generated_checkout_url,
    "deposit_id": deposit_id,
  };
};

// checks if an existing checkout deposit link request is completed or not
const check_if_checkout_payment_is_completed = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<any> => {
  /*
      body preview
      {
        "request_type": "check_if_checkout_payment_is_completed",
        "deposit_id: string
      }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the deposit request
  const deposit_reqs = await _supabaseClient.from("deposit_requests").select()
    .eq("deposit_id", _body["deposit_id"]).eq("user_id", user_id);

  return deposit_reqs["data"][0]["transaction_status"] == "successful";
};

const zambia_broad_pay_webhook = async (
  _supabaseClient: any,
  _req: Request,
  _body: any,
): Promise<JSON> => {
  /*
      body preview
      {
        "request_type": "zambia_broad_pay_webhook",
      }
    */

  // gets the user's id from the request
  const user_id = await get_auth_user_id(_req, _supabaseClient);

  // gets the user's account row
  const res = await _supabaseClient.from("users").select().eq(
    "user_id",
    user_id,
  );

  return res["data"][0];
};

//  ===================================================
