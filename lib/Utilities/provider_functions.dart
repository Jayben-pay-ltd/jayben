// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, unnecessary_string_interpolations
// import 'dart:html';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart';
import 'package:jayben/Home/elements/deposit_money/elements/card_payments_deposit_webview.dart';
import 'package:jayben/Home/elements/nfc/tap_to_pay_page.dart';
import 'package:jayben/Home/elements/withdraw_money/withdraw_money_confirmation_page.dart';
import 'package:jayben/Home/elements/messages/elements/send_media_message.dart';
import 'package:jayben/Home/elements/qr_scanner/scan_confirmation_page.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:jayben/Home/elements/attach_media/attach_media.dart';
import 'package:jayben/Home/elements/nfc/components/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jayben/Auth/elements/update_app_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:video_compress/video_compress.dart';
import '../Auth/elements/six_digit_pin_page.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:video_player/video_player.dart';
import 'package:country_data/country_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jayben/Home/home_page.dart';
import "package:http/http.dart" as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../Auth/pre_login.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
// FirebaseFirestore _fire = FirebaseFirestore.instance;
SupabaseClient supabase = Supabase.instance.client;
// FirebaseAuth _auth = FirebaseAuth.instance;
final AudioPlayer player = AudioPlayer();
Uuid id = const Uuid();

// converted to RLS
class UserProviderFunctions extends ChangeNotifier {
  List<String> upvoted_feedback_submissions = [];
  String current_contact_type = "Calls/Text";
  double? total_amount_ever_deposited;
  double? total_amount_ever_withdrawn;
  List<dynamic>? feedback_submissions;
  List<String> loading_upvotes = [];
  double? total_amount_ever_saved;
  int? number_of_days_as_a_user;
  double upload_progress = 0.0;
  int? number_of_transactions;
  bool is_loading = false;

  // ================= getters

  bool returnIsLoading() => is_loading;
  double returnUploadProgress() => upload_progress;
  List<String> returnUpvotedFeedbackSubmissions() =>
      upvoted_feedback_submissions;
  List<String> returnLoadingUpvoted() => loading_upvotes;
  int? returnNumOfDaysAsAUser() => number_of_days_as_a_user;
  String returnCurrentContactType() => current_contact_type;
  int? returnNumOfTotalTransactions() => number_of_transactions;
  double? returnTotalAmountEverSaved() => total_amount_ever_saved;
  List<dynamic>? returnFeedbackSubmissions() => feedback_submissions;
  double? returnTotalAmountEverDeposited() => total_amount_ever_deposited;
  double? returnTotalAmountEverWithdrawn() => total_amount_ever_withdrawn;

  // ================= setters

  void toggleIsLoading() {
    is_loading = !is_loading;
    boxPut("isLoading", is_loading);
    notifyListeners();
  }

  // stops & starts a loading indicator when upvoting feedback submissions
  void toggleLoadingUpvotes(String submission_id) {
    if (!loading_upvotes.contains(submission_id)) {
      loading_upvotes.add(submission_id);
    } else {
      loading_upvotes.removeWhere((element) => element == submission_id);
    }

    notifyListeners();
  }

  void changeCurrentContactType(String contact_type) {
    current_contact_type = contact_type;
    notifyListeners();
  }

  // gets user's account achievements
  Future<void> getUserAchievements() async {
    // gets a list of all this user's transactions
    Map<String, dynamic> res = await callGeneralFunction(
      "get_all_users_transactions",
      {},
    );

    List<dynamic> transactions = res["data"]["data"];

    double temp_total_amount_ever_withdrawn = 0.0;
    double temp_total_amount_ever_deposited = 0.0;
    double temp_total_amount_ever_saved = 0.0;
    int temp_number_of_transactions = 0;

    for (var i = 0; i < transactions.length; i++) {
      // for all deposits to jayben wallet, except savings transfers to jayben wallets
      if (transactions[i]["transaction_type"] == "Deposit") {
        if (transactions[i]["transaction_type"] !=
            "From Group No Access Savings") {
          temp_total_amount_ever_deposited += transactions[i]["amount"];
        }
      }

      // sums up all withdrawal transactions
      if (transactions[i]["transaction_type"] == "Withdrawal") {
        temp_total_amount_ever_withdrawn += transactions[i]["amount"];
      }

      // sums up all transfers to savings
      if (transactions[i]["transaction_type"] == "Savings Transfer") {
        if (transactions[i]["sent_received"] == "Sent") {
          temp_total_amount_ever_saved += transactions[i]["amount"];
        }
      }

      temp_number_of_transactions++;
    }

    // Define two DateTime variables
    DateTime startDate = DateTime.parse(box("created_at"));
    DateTime endDate = DateTime.now();

    // Calculate the difference between the two dates
    Duration difference = endDate.difference(startDate);

    // Get the number of days from the duration
    int numberOfDays = difference.inDays;

    total_amount_ever_withdrawn = temp_total_amount_ever_withdrawn;
    total_amount_ever_deposited = temp_total_amount_ever_deposited;
    total_amount_ever_saved = temp_total_amount_ever_saved;
    number_of_transactions = temp_number_of_transactions;
    number_of_days_as_a_user = numberOfDays;

    notifyListeners();
  }

  // updates the user's new profile image
  Future<String?> updateProfileImage(File? image) async {
    if (image == null) return null;

    UploadTask? task = uploadImageToFirebase(
        'UserProfileImages/${basename(image.path)}', image);
    //task to upload the image

    if (task == null) return null;

    task.snapshotEvents.listen((event) {
      upload_progress =
          event.bytesTransferred.toDouble() / event.totalBytes.toDouble() * 100;
      notifyListeners();
    }).onError((_) {});

    final snapshot = await task.whenComplete(() {});
    //returns a snapshot when upload is complete

    final imageUrl = await snapshot.ref.getDownloadURL();
    //gets the image url

    // saves the profile image url locally
    boxPut("profile_image_url", imageUrl);

    notifyListeners();

    // 1). updates the image url in user's document & nas accounts
    // 3). precaches the image
    await Future.wait([
      callGeneralFunction("update_profile_image_url", {
        "profile_image_url": imageUrl,
      }),
      cacheImage(imageUrl),
    ]);

    return imageUrl;
  }

  // gets a list of all active submissions
  Future<void> getFeedbackSubmissions() async {
    Map<String, dynamic> res =
        await callGeneralFunction("get_feedback_submissions", {});

    List<dynamic> feedback_submissions = res["data"];

    if (feedback_submissions.isEmpty) return;

    for (var i = 0; i < feedback_submissions.length; i++) {
      // if the user has already upvoted the submission
      if (feedback_submissions[i]["users_who_upvoted"]
          .any((user) => user['user_id'] == box("user_id"))) {
        upvoted_feedback_submissions
            .add(feedback_submissions[i]["submission_id"]);
      }
    }

    notifyListeners();
  }

  // creates a submission row in supabase
  Future<void> submitFeedback(String text, String type) async {
    Map<String, dynamic> res =
        await callGeneralFunction("create_a_feedback_submission", {
      "users_who_upvoted": [
        {
          "current_platform_os": Platform.isAndroid ? "Android" : "iOS",
          "current_build_version": box("current_build_version"),
          "date_upvoted": DateTime.now().toIso8601String(),
          "profile_image_url": box("profile_image_url"),
          "first_name": box("first_name"),
          "last_name": box("last_name"),
          "user_id": box("user_id"),
        }
      ],
      "creator_platform_os": Platform.isAndroid ? "Android" : "iOS",
      "creator_current_build_version": box("current_build_version"),
      "creator_details": {
        "profile_image_url": box("profile_image_url"),
        "first_name": box("first_name"),
        "last_name": box("last_name"),
        "user_id": box("user_id"),
      },
      "user_id": box("user_id"),
      "submission_type": type,
      "submission_text": text,
    });

    print(res["data"]);
  }

  // submits an upvote to an existing feedback submission
  Future<void> upvoteFeedbackSubmission(String submission_id) async {
    Map<String, dynamic> res =
        await callGeneralFunction("upvote_an_existing_feedback_submission", {
      "submission_id": submission_id,
    });

    print(res["data"]);
  }
}

// converted to RLS
class HomeProviderFunctions extends ChangeNotifier {
  // Stream<QuerySnapshot<Object>?>? initiatedPaymentsStream;
  // QuerySnapshot<Object?>? homeTimeLimitedTransactionsQS;
  List<dynamic>? top_20_shared_nas_accounts;
  List<dynamic>? my_shared_nas_accounts;
  bool show_back_to_top_button = false;
  String currentHomeState = "Wallet";
  double total_savings_balance = 0.0;
  int current_home_body_index = 0;
  List<dynamic>? homeTransactions;
  List<dynamic>? allTransactions;
  String profile_image_url = "";
  bool isLoading = false;

  // ============== returners

  bool returnIsLoading() => isLoading;
  String returnCurrentHomeState() => currentHomeState;
  String returnProfileImageUrl() => profile_image_url;
  List<dynamic>? returnAllTransactions() => allTransactions;
  List<dynamic>? returnHomeTransactions() => homeTransactions;
  bool returnShowBackToTopButton() => show_back_to_top_button;
  int returnCurrentHomeBodyIndex() => current_home_body_index;
  double returnTotalSavingsBalance() => total_savings_balance;
  // QuerySnapshot<Object?>? returnHomeTimeLimitedTransactionsQS() =>
  //     homeTimeLimitedTransactionsQS;
  // Stream<QuerySnapshot<Object>?>? returnInitiatedPaymentsStream() =>
  // initiatedPaymentsStream;
  List<dynamic>? returnMySharedNasAccounts() => my_shared_nas_accounts;
  List<dynamic>? returnTop20SharedNasAccounts() => top_20_shared_nas_accounts;

  // ============== getters

  void clearAllVariables() {
    isLoading = false;
    allTransactions = null;
    homeTransactions = null;
    currentHomeState = "Wallet";
    total_savings_balance = 0.0;
    my_shared_nas_accounts = null;
    // initiatedPaymentsStream = null;
    top_20_shared_nas_accounts = null;
    // homeTimeLimitedTransactionsQS = null;
    boxDelete("Balance");
    boxDelete("Points");

    notifyListeners();
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void changeCurrentHomeBodyIndex(int index) {
    current_home_body_index = index;
    notifyListeners();
  }

  void toggleShowBackToTopButton(bool state) {
    show_back_to_top_button = state;
    notifyListeners();
  }

  // gets the initiated payments
  // stream that show on the home page
  void getInitiatedPaymentsStream() {
    // initiatedPaymentsStream = _fire
    //     .collection("Initiated Payments")
    //     .where("UserID", isEqualTo: box("user_id"))
    //     .where("Status", isEqualTo: "Pending")
    //     .orderBy("DateCreated", descending: true)
    //     .snapshots();
  }

  // loads previously loaded transactions to the UI
  // to save time from the home page loading each time
  void loadPreviousHomeTransactions() {
    if (box("home_transactions") == null) return;

    homeTransactions = box("home_transactions");
    notifyListeners();
  }

  void updateProfilePhotoLocally(String image_url) {
    profile_image_url = image_url;
    notifyListeners();
  }

  // adds 1 minute to the user's total time spent
  Future<void> updateTimeSpentInTimeline() async {
    // only if the home page is set to timeline
    if (current_home_body_index == 0) return;

    // updates the user's row
    await supabase
        .rpc("increase_daily_user_minutes_spent_in_timeline", params: {
      "row_id": box("user_id"),
      "x": 1,
    });
  }

  // updates the user's current device id & ip address
  Future<void> updateDeviceIDAndIPAddress(
    BuildContext context,
    Map<String, dynamic>? user_data_res,
  ) async {
    if (box("user_id") == null) return;

    Map<String, dynamic>? res = user_data_res;

    if (user_data_res == null) {
      res = await callGeneralFunction("get_user_account", {
        "get_app_wide_settings": true,
      });
    }

    if (res == null) return;

    Map user_row = res["data"]["data"]["user_data"];

    // if no user has been returned
    if (user_row.isEmpty) return;

    // gets the current device's ip address
    // dynamic ip_address = await ipAddress.getIpAddress();

    final ip_address = await Ipify.ipv4();

    String? device_id;

    try {
      device_id = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      print('Failed to get deviceId.');
    }

    // if no ip address has been recorded in the user's account
    if (user_row["current_device_ip_address"] == "" ||
        user_row["current_device_id"] == "") {
      // updates the ip address field
      Map<String, dynamic> response =
          await callGeneralFunction("update_device_id_and_ip_address", {
        "new_device_ip_address": ip_address,
        "new_device_id": device_id,
      });
    }

    // if the user is logged in on another device
    if (user_row["current_device_id"] != device_id) {
      // await _auth.signOut();

      if (box("user_id") == null) return;

      changePage(context, const PreLoginPage(), type: "pr");

      await supabase.auth.signOut();

      boxClear();

      showSnackBar(context, "You have been Logged Out By Another Device",
          color: Colors.grey[700]!);
    }
  }

  // Checks if user is on latest build version and dismisses update reminders
  Future<void> checkAppVersion(
    BuildContext context,
    Map<String, dynamic> res,
  ) async {
    if (box("user_id") == null) return;

    if (res == null) return;

    Map user_map = res["data"]["data"]["user_data"];

    Map app_wide_settings =
        res["data"]["data"]["app_wide_settings"]["record_contents"];

    if (user_map == null) return;

    // if no reminders are present
    if (!user_map["show_update_alert"]) return;

    // if user is on latest build version, dismiss update reminders
    if (user_map["current_build_version"] ==
        app_wide_settings["current_most_recent_client_app_build_version"]) {
      // dismisses the update reminder in user"s row
      await callGeneralFunction("update_show_update_alert", {
        "new_value": false,
      });

      return;
    }

    // routes user to update app page
    changePage(context, const UpdateAppPage(), type: "pr");
  }

  // Upates build version, last seen and platform
  Future<void> updateUserLastSeen() async {
    if (box("user_id") == null) return;

    // updates the user's row
    FunctionResponse? res = await supabase
        .rpc("increase_daily_user_minutes_spent_in_app_version_2", params: {
      "last_seen_timestamp": DateTime.now().toIso8601String(),
      "platform_os": Platform.isAndroid ? "Android" : "iOS",
      "build_version": box("current_build_version"),
      "row_id": box("user_id"),
      "x": 1,
    });

    Map<String, dynamic>? response;

    if (res != null) {
      response = res.data as Map<String, dynamic>;
    }
  }

  // 1). Gets normal treasnactions
  // 2). Gets time limited transactions
  // 3). Gets initiated payments stream
  Future<void> getHomeTransactions() async {
    if (box("user_id") == null) return;

    loadPreviousHomeTransactions();

    // gets home transactions
    Map<String, dynamic> res = await callGeneralFunction(
      "get_users_home_page_transactions",
      {},
    );

    homeTransactions = res["data"]["data"];

    // gets home time limited transactions
    // homeTimeLimitedTransactionsQS = await _fire
    //     .collection("Time Limited Transactions")
    //     .where("UserID", isEqualTo: box("user_id"))
    //     .where("NumberOfDaysLeft", isGreaterThan: 0)
    //     .orderBy("NumberOfDaysLeft", descending: false)
    //     .get();

    // this ensures the deposit button shows on home page
    // if (homeTimeLimitedTransactionsQS!.docs.isEmpty) {
    //   homeTimeLimitedTransactionsQS = null;
    // }

    if (homeTransactions!.isEmpty) {
      homeTransactions = null;
    }

    // saves the transactions locally to speed up load times
    boxPut("home_transactions", homeTransactions);

    notifyListeners();

    await updatePlatformLastSeenAndBuildVersion();
  }

  // 1). Updates the last seen active
  // 2). CurrentPlatform & CurrentBuildversion
  Future<void> updatePlatformLastSeenAndBuildVersion() async {
    if (box("user_id") == null) return;

    // updates the user's account record
    await callGeneralFunction("update_last_time_seen_and_build_version", {
      "last_time_online_timestamp": DateTime.now().toIso8601String(),
      "current_os_platform": Platform.isAndroid ? "Android" : "iOS",
      "current_build_version": box("current_build_version"),
    });
  }

  // gets all transactions for the All transactions page
  Future<void> getAllTransactions() async {
    Map<String, dynamic> res = await callGeneralFunction(
      "get_all_users_transactions",
      {},
    );

    allTransactions = res["data"]["data"];

    // gets home time limited transactions
    // homeTimeLimitedTransactionsQS = await _fire
    //     .collection("Time Limited Transactions")
    //     .where("UserID", isEqualTo: box("user_id"))
    //     .where("NumberOfDaysLeft", isGreaterThan: 0)
    //     .orderBy("NumberOfDaysLeft", descending: true)
    //     .get();

    notifyListeners();
  }

  // 1). gets user's details & admin's settings
  // 2). saves the details & settings locally in device
  // 3). precaches the user's profile image locally
  Future<void> loadDetailsToHive(BuildContext context) async {
    // gets this user's account record row
    Map<String, dynamic> res = await callGeneralFunction("get_user_account", {
      "get_app_wide_settings": true,
    });

    Map user_map = res["data"]["data"]["user_data"];
    Map app_settings =
        res["data"]["data"]["app_wide_settings"]["record_contents"];

    if (user_map == null) return;

    boxPut("nas_deposits_are_allowed", user_map["nas_deposits_are_allowed"]);
    boxPut("current_app_build_version", user_map["current_build_version"]);
    boxPut("account_kyc_is_verified", user_map["account_kyc_is_verified"]);
    boxPut("email_address_lowercase", user_map["email_address_lowercase"]);
    boxPut("username_searchable", user_map["username_searchable"]);
    boxPut("notification_token", user_map["notification_token"]);
    boxPut("account_is_on_hold", user_map["account_is_on_hold"]);
    boxPut("profile_image_url", user_map["profile_image_url"]);
    boxPut("balance", user_map["balance"].toStringAsFixed(2));
    boxPut("currency_symbol", user_map["currency_symbol"]);
    boxPut("email", user_map["email_address_lowercase"]);
    boxPut("referral_code", user_map["referral_code"]);
    boxPut("country_code", user_map["country_code"]);
    boxPut("account_type", user_map["account_type"]);
    boxPut("phone_number", user_map["phone_number"]);
    boxPut("address", user_map["physical_address"]);
    boxPut("first_name", user_map["first_name"]);
    boxPut("created_at", user_map["created_at"]);
    boxPut("user_code", user_map["user_code"]);
    boxPut("last_name", user_map["last_name"]);
    boxPut("currency", user_map["currency"]);
    boxPut("username", user_map["username"]);
    boxPut('pin_code', user_map["pin_code"]);
    boxPut("user_id", user_map["user_id"]);
    boxPut("country", user_map["country"]);
    boxPut("points", user_map["points"]);
    boxPut("gender", user_map["gender"]);
    boxPut("city", user_map["city"]);
    boxPut("user_map", user_map);

    // =========== Saves admin settings to Hive

    boxPut("merchant_commission_per_transaction",
        app_settings["merchant_commission_per_transaction"]);
    boxPut("enable_card_payments_for_deposits",
        app_settings["enable_card_payments_for_deposits"]);
    boxPut("enable_instant_payments_for_deposits",
        app_settings["enable_instant_payments_for_deposits"]);
    boxPut("jayben_secondary_customer_support_hotline",
        app_settings["jayben_secondary_customer_support_hotline"]);
    boxPut("default_transaction_visibility",
        app_settings["default_transaction_visibility"]);
    boxPut("admin_users_that_can_see_secret_dashboard",
        app_settings["admin_users_that_can_see_secret_dashboard"]);
    boxPut("maximum_number_of_savings_accounts_per_person",
        app_settings["maximum_number_of_savings_accounts_per_person"]);
    boxPut("airtime_purchase_minimum_amount",
        app_settings["airtime_purchase_minimum_amount"]);
    boxPut("enable_saving_with_friends",
        app_settings["enable_saving_with_friends"]);
    boxPut("number_of_user_points_given_per_transaction",
        app_settings["number_of_user_points_given_per_transaction"]);
    boxPut(
        "cash_value_per_user_point", app_settings["cash_value_per_user_point"]);
    boxPut("agent_payments_withdraw_fee_percent",
        app_settings["agent_payments_withdraw_fee_percent"]);
    boxPut("jayben_primary_customer_support_email_address",
        app_settings["jayben_primary_customer_support_email_address"]);
    boxPut("customer_support_whatsapp_phone_number",
        app_settings["customer_support_whatsapp_phone_number"]);
    boxPut("intl_wire_transfer_withdraw_fee_in_usd",
        app_settings["intl_wire_transfer_withdraw_fee_in_usd"]);
    boxPut("general_withdraw_amount_limit",
        app_settings["general_withdraw_amount_limit"]);
    boxPut("transaction_fee_percentage_to_merchants",
        app_settings["transaction_fee_percentage_to_merchants"]);
    boxPut("minimum_savings_deposit_amount",
        app_settings["minimum_savings_deposit_amount"].toString());
    boxPut("jayben_primary_customer_support_hotline",
        app_settings["jayben_primary_customer_support_hotline"]);
    boxPut("send_merchant_transaction_smses",
        app_settings["send_merchant_transaction_smses"]);
    boxPut("user_referral_commission_percentage",
        app_settings["user_referral_commission_percentage"]);
    boxPut("local_wire_transfer_withdraw_fee_in_usd",
        app_settings["local_wire_transfer_withdraw_fee_in_usd"]);
    boxPut("show_app_wide_top_20_nas_accounts",
        app_settings["show_app_wide_top_20_nas_accounts"]);
    boxPut("enable_timeline_feed", app_settings["enable_timeline_feed"]);

    // precaches user's profileimage
    await cacheImage(box("profile_image_url"));

    profile_image_url = user_map["profile_image_url"];

    notifyListeners();

    await updateDeviceIDAndIPAddress(context, res);

    await checkAppVersion(context, res);
  }

  Future<void> initDynamicLinks() async {
    // https://jayben.page.link

    // Get any initial links
    // final PendingDynamicLinkData? initialLink =
    //     await FirebaseDynamicLinks.instance.getInitialLink();

    // if (initialLink != null) {
    //   final Uri deepLink = initialLink.link;
    //   // Example of using the dynamic link to push the user to a different screen
    // }
  }

  // 1). updates user's notification token
  // 2). updates user's personal NAS acc notif tokens (firebase)
  // 3). updates user's personal NAS acc notif tokens (supabase)
  // 4). updates user's shared NAS acc notif tokens (supabase)
  Future<void> updateNotificationToken() async {
    if (box("user_id") == null) return;

    String? token;

    // gets valid notification token
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }

    // saves token to hive
    boxPut("notification_token", token);

    if (box("user_map") != null) {
      if (box("user_map")["notification_token"] == token) return;
    }

    // updates token in user's account document
    await callGeneralFunction("update_user_notification_token", {
      "notification_token": token,
    });
  }

  // ======== Home state functions

  void changeHomeState(String newState) {
    currentHomeState = newState;
    notifyListeners();
  }

  // ======== Home Savings functions

  // 1). Gets no access accounts (firebase & supabase)
  // 2). Adds the totals of all accounts into one value
  Future<void> getHomeSavingsAccounts() async {
    // gets the top 20 & user's savings accounts
    Map<String, dynamic> res = await callGeneralFunction(
      "get_home_saving_accounts",
      {},
    );

    top_20_shared_nas_accounts = res["data"]["data"]["top_20_nas_accounts"];
    my_shared_nas_accounts = res["data"]["data"]["shared_nas_acocounts"];

    double temp_balance = 0.0;

    // adds the balance totals of supabase shared no access accounts
    if (my_shared_nas_accounts!.isNotEmpty) {
      for (var acc2 in my_shared_nas_accounts!) {
        temp_balance += acc2["balance"];
      }
    }

    // updates savings total balance
    total_savings_balance = temp_balance;

    notifyListeners();
  }
}

// converted to RLS
class DepositProviderFunctions extends ChangeNotifier {
  String phone_number_string = box("phone_number") == null
      ? ""
      : "${box("phone_number").replaceAll("+26", "")}";
  String selected_deposit_method = "";
  Timer? delete_character_timer;
  int current_page_index = 0;
  String amount_string = "";
  bool isLoading = false;

  // ========== getters

  bool returnIsLoading() => isLoading;
  String returnAmountString() => amount_string;
  int returnCurrentPageIndex() => current_page_index;
  String returnPhoneNumberString() => phone_number_string;
  Timer? returnDeleteCharacterTimer() => delete_character_timer;
  String returnSelectedDepositMethod() => selected_deposit_method;

  // ========== getters

  void clearAllVariables() {
    isLoading = false;
    notifyListeners();
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void clearStrings() {
    selected_deposit_method = box("enable_instant_payments_for_deposits")
        ? "Via Mobile Money"
        : "Via Mobile Money";
    // "Via Jayben Agent";
    phone_number_string = box("phone_number").replaceAll("+26", "");
    current_page_index = 0;
    amount_string = "";
  }

  void ChooseMethod(String method) {
    selected_deposit_method = method;
    notifyListeners();
  }

  // adds characters to the current display string
  void addCharacter(String char) {
    if (current_page_index == 1) {
      if (char == ".") return;

      if (phone_number_string.length == 10) return;

      phone_number_string += char;
    } else {
      if (amount_string.contains(".") && char == ".") return;

      if (amount_string.isEmpty && char == "0") return;

      if (amount_string.length == 10) return;

      amount_string += char;
    }

    notifyListeners();
  }

  // removes characters to the current display string
  void removeCharacter(String char) {
    if (phone_number_string.isEmpty || amount_string.isEmpty) return;

    if (current_page_index == 1) {
      phone_number_string =
          phone_number_string.substring(0, phone_number_string.length - 1);
    } else {
      amount_string = amount_string.substring(0, amount_string.length - 1);
    }

    notifyListeners();
  }

  // changes the page that is showing
  void changePageIndex(int index) {
    current_page_index = index;
    notifyListeners();
  }

  // stops the deletion of the text
  void cancelDeleteCharTimer() {
    if (delete_character_timer == null) return;

    delete_character_timer!.cancel();

    notifyListeners();
  }

  // starts deleting the text character by character
  Future<void> startCharacterDeletion(String text) async {
    delete_character_timer =
        Timer.periodic(const Duration(milliseconds: 110), (timer) async {
      if (text == "clear") {
        Vibrate.feedback(FeedbackType.light);

        removeCharacter(text);
      }
    });
  }

  Future<void> prepareDeposit(BuildContext context) async {
    if (isLoading) return;

    if (phone_number_string.length < 10) {
      showSnackBar(context, 'Enter a 10 digit phone number');

      return;
    }

    if (phone_number_string[0] != "0" ||
        ["7", "9"].contains(phone_number_string[1]) == false ||
        ["5", "6", "7"].contains(phone_number_string[2]) == false) {
      showSnackBar(context, 'Enter a valid Zambian phone number');

      return;
    }

    double amount = double.parse(amount_string.replaceAll('-', ''));

    String phoneNumber = phone_number_string.trim();

    showSnackBar(context,
        'Deposit is being processed, you will receive a USSD request in a moment.',
        duration: 10, color: Colors.grey[700]!);

    changePage(context, const HomePage(), type: "pr");

    // sends a USSD push notification to the user
    await initiateDeposit(phoneNumber, amount);
    // where they enter their momo PIN and deposit cash
  }

  Future<void> prepareCardDeposit(BuildContext context) async {
    if (isLoading) return;

    toggleIsLoading();

    // gets the deposit link
    List<String> results = await getDepositLink(double.parse(amount_string));

    toggleIsLoading();

    if (results.isEmpty) {
      goBack(context);
      goBack(context);
      goBack(context);

      showSnackBar(context, "An error occurred, please try again later");
      return;
    }

    changePage(
      context,
      DepositWebviewPage(
        deposit_id: results[1],
        deposit_link: results[0],
      ),
    );
  }

  // sends a USSD prompt to the client's entered phone number
  Future<void> initiateDeposit(String phoneNumber, double amount) async {
    FunctionResponse res = await supabase.functions
        .invoke("zambia_broad_pay_init_mobile_money_ussd", body: {
      "request_type": "zambia_broad_pay_init_mobile_money_ussd",
      "deposit_details": {"phone_number": phoneNumber, "amount": amount},
    });

    print(res.data);
  }

  // gets the deposit link from the get checkout link api
  Future<List<String>> getDepositLink(double amount) async {
    try {
      // generates a checkout link
      FunctionResponse res = await supabase.functions
          .invoke("zambia_broad_pay_get_checkout_link", body: {
        "request_type": "zambia_broad_pay_get_checkout_link",
        "amount": amount
      });

      Map<String, dynamic> res_map = res.data as Map<String, dynamic>;

      String checkout_link_url = res_map["checkout_link_url"];
      String deposit_id = res_map["deposit_id"];

      // returns the checkout link & reference
      return [checkout_link_url, deposit_id];
    } catch (e) {
      print(e);
      return [];
    }
  }

  // checks if the checkout payment is complete and successful
  Future<bool> checkIfPaymentComplete(String deposit_id) async {
    FunctionResponse res = await supabase.functions.invoke(
        "check_if_checkout_payment_is_completed",
        body: {"deposit_id": deposit_id});

    return res.data.data;
  }
}

// converted to RLS
class QRScannerProviderFunctions extends ChangeNotifier {
  Timer? delete_character_timer;
  bool hasScannedQRCode = false;
  bool isTextFieldEmpty = true;

  bool isFlashActive = false;
  String amount_string = "";
  bool isLoading = false;

  // ============ returners

  bool returnIsLoading() => isLoading;
  bool returnIsFlashActive() => isFlashActive;
  String returnAmountString() => amount_string;
  bool returnHasScannedQRCode() => hasScannedQRCode;
  bool returnIsTextfieldEmpty() => isTextFieldEmpty;
  Timer? returnDeleteCharacterTimer() => delete_character_timer;

  // ============ getters

  void clearAllVariables() {
    hasScannedQRCode = false;
    isTextFieldEmpty = true;
    isFlashActive = false;
    amount_string = "";
    isLoading = false;
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void toggleFlashLight() {
    isFlashActive = !isFlashActive;
    notifyListeners();
  }

  void toggleVendorCodeTextFieldStatus(String change) {
    if (change.isEmpty) {
      isTextFieldEmpty = true;
    } else {
      isTextFieldEmpty = false;
    }

    notifyListeners();
  }

  void toggleHasScannedQRCode() {
    hasScannedQRCode = !hasScannedQRCode;
    notifyListeners();
  }

  // stops the deletion of the text
  void cancelDeleteCharTimer() {
    if (delete_character_timer == null) return;

    delete_character_timer!.cancel();

    notifyListeners();
  }

  // adds characters to the current display string
  void addCharacter(String char) {
    if (amount_string.contains(".") && char == ".") return;

    if (amount_string.isEmpty && char == "0") return;

    if (amount_string.length == 10) return;

    amount_string += char;

    notifyListeners();
  }

  // removes characters to the current display string
  void removeCharacter(String char) {
    if (amount_string.isEmpty) return;

    amount_string = amount_string.substring(0, amount_string.length - 1);

    notifyListeners();
  }

// starts deleting the text character by character
  Future<void> startCharacterDeletion(String text) async {
    delete_character_timer =
        Timer.periodic(const Duration(milliseconds: 110), (timer) async {
      if (text == "clear") {
        Vibrate.feedback(FeedbackType.light);

        removeCharacter(text);
      }
    });
  }

  // get's the receivers details using the vendor code
  Future<List<dynamic>> getReceiverDetailsFromVendorCode(
      String user_code) async {
    // vendorCode is another word UserCode
    Map<String, dynamic> res =
        await callGeneralFunction("get_limited_user_row_from_usercode", {
      "user_code": user_code,
    });

    Map merchant_map = res["data"]["data"];

    bool is_error = res["data"]["status"] == "failed";

    return !is_error ? [true, merchant_map] : [false, null];
  }

  // get's the receivers details using the user id
  Future<List<dynamic>> getReceiversDetails(String user_id) async {
    // vendorCode is another word UserCode
    Map<String, dynamic> res =
        await callGeneralFunction("get_limited_user_row_from_userid", {
      "user_id": user_id,
    });

    print(res["data"]);

    Map merchant_map = res["data"].data;

    bool is_error = res["data"].status == "failed";

    return !is_error ? [true, merchant_map] : [false, null];
  }

  Future<void> initateMerchantPayment(Map paymentInfo) async {
    Map<String, dynamic> res =
        await callGeneralFunction("send_money_via_qr_code", {
      "transaction_details": {
        "merchant_commission_per_transaction":
            double.parse(box("merchant_commission_per_transaction").toString()),
        "receiver_user_id": paymentInfo['receiver_map']["user_id"],
        "payment_means": paymentInfo["payment_means"],
        "amount": paymentInfo['amount'],
      }
    });

    print(res["data"]["data"]);
  }
}

// converted to RLS
class SavingsProviderFunctions extends ChangeNotifier {
  List<String> selected_friends_to_add_to_shared_nas_account = [];
  List<dynamic> username_search_results = [];
  int current_savings_filter_index = 0;
  Timer? delete_character_timer;
  bool is_adding_friend = false;
  String amount_string = "";
  bool is_Loading = false;
  int current_index = 0;

  // ========== getters

  bool returnIsLoading() => is_Loading;
  int returnCurrentIndex() => current_index;
  String returnAmountString() => amount_string;
  bool returnIsAddingFriend() => is_adding_friend;
  List<String> returnSelectedFriendsToAddToSharedNasAcc() =>
      selected_friends_to_add_to_shared_nas_account;
  Timer? returnDeleteCharacterTimer() => delete_character_timer;
  int returnCurrentSavingsFilterIndex() => current_savings_filter_index;
  List<dynamic> returnUsernameSearchResults() => username_search_results;

  // ============== setters

  void changeSavingsFilterIndex(int index) {
    current_savings_filter_index = index;
    notifyListeners();
  }

  void clearAllVariables() {
    is_Loading = false;
    notifyListeners();
  }

  void toggleIsLoading() {
    is_Loading = !is_Loading;
    notifyListeners();
  }

  void toggleIsAddingFriend() {
    is_adding_friend = !is_adding_friend;
    notifyListeners();
  }

  void clearStrings() {
    amount_string = "";
  }

  void resetUsernameSearchResults() {
    selected_friends_to_add_to_shared_nas_account.clear();
    username_search_results.clear();
  }

  void updateCurrentIndex(int index) {
    current_index = index;
    notifyListeners();
  }

  // adds characters to the current display string
  void addCharacter(String char) {
    if (amount_string.contains(".") && char == ".") return;

    if (amount_string.isEmpty && char == "0") return;

    if (amount_string.length == 10) return;

    amount_string += char;

    notifyListeners();
  }

  // removes last character from the current display string
  void removeCharacter(String char) {
    if (amount_string.isEmpty) return;

    amount_string = amount_string.substring(0, amount_string.length - 1);

    notifyListeners();
  }

  // stops the deletion of the text
  void cancelDeleteCharTimer() {
    if (delete_character_timer == null) return;

    delete_character_timer!.cancel();

    notifyListeners();
  }

  // starts deleting the text character by character
  Future<void> startCharacterDeletion(String text) async {
    delete_character_timer =
        Timer.periodic(const Duration(milliseconds: 110), (timer) async {
      if (text == "clear") {
        Vibrate.feedback(FeedbackType.light);

        removeCharacter(text);
      }
    });
  }

  // gets a shared nas account's transactions
  Future<List<dynamic>> getSharedNasAccTranxs(String account_id) async {
    Map<String, dynamic> res =
        await callGeneralFunction("get_my_shared_nas_account_transactions", {
      "savings_account_id": account_id,
    });

    List<dynamic> transactions = res["data"].data.data;

    print(transactions);

    return transactions;
  }

  // for moving money from wallet to savings
  Future<bool> addMoneyToNasAccount(
    double amount,
    String account_id,
  ) async {
    Map<String, dynamic> res = await callGeneralFunction(
      "add_money_to_shared_nas_account",
      {
        "request_type": "add_money_to_shared_nas_account",
        "account_id": account_id,
        "post_is_public": false,
        "media_details": [],
        "amount": amount,
        "comment": "",
      },
    );

    List<dynamic> response = res["data"].data.data;

    return response.isEmpty;
  }

  // 1). transfers money to a nas acc
  // 2). Creates a text only timeline post
  Future<bool> saveMoneyToSharedNasAccWithTextOnlyPost(
      Map transfer_info) async {
    // gets the public supabase keys document
    // DocumentSnapshot supabase_keys = await _fire
    //     .collection("Admin")
    //     .doc("Legal")
    //     .collection("Supabase")
    //     .doc("keys")
    //     .get();

    // calls API that moves cash from wallet to savings
    // var res = await http.post(
    //   Uri.parse(
    //       "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions"),
    //   headers: {
    //     "Authorization": "Bearer ${supabase_keys.get("anon_key")}",
    //     "Content-type": "application/json",
    //   },
    //   body: json.encode(
    //     {
    //       "post_is_public": box("default_transaction_visibility") == "Public",
    //       "full_names": "${box("first_name")} ${box("last_name")}",
    //       "account_id": transfer_info["account_id"],
    //       "request_type": "add_money_nas_account",
    //       "comment": transfer_info['comment'],
    //       "amount": transfer_info["amount"],
    //       "currency": box("currency"),
    //       "user_id": box("user_id"),
    //       "country": box("country"),
    //       "media_details": [
    //         {
    //           "media_caption": "",
    //           "thumbnail_url": "",
    //           "post_type": "text",
    //           "aspect_ratio": "",
    //           "media_type": "",
    //           "media_url": "",
    //         }
    //       ],
    //     },
    //   ),
    // );

    // print(res.body);

    // return res.body == '{"data":"success"}';

    return true;
  }

  // creates a no access account row
  Future<bool> createSharedNoAccessAccount(Map account_info) async {
    Map<String, dynamic> res = await callGeneralFunction(
      "create_shared_no_access_savings_account",
      {
        "request_type": "create_shared_no_access_savings_account",
        "account_name": account_info["account_name"],
        "number_of_days": 1,
      },
    );

    return res["data"]["status"] == "success";
  }

  // gets a list of user rows that have the username
  Future<List<dynamic>> searchUsernameInDB(String username) async {
    Map<String, dynamic> res = await callGeneralFunction(
        "search_username_in_db",
        {"request_type": "search_username_in_db", "username": username});

    List<dynamic> username_search_results = res["data"].data.data;

    return username_search_results;
  }

  // adds a new user to a shared NAS
  Future<bool> addPersonToSharedNasAccount(Map account_info) async {
    Map<String, dynamic> res =
        await callGeneralFunction("add_person_to_nas_account", {
      "user_id_for_person_joining": account_info["user_map"]["user_id"],
      "account_id": account_info["account_map"]["account_id"],
      "request_type": "add_person_to_nas_account",
    });

    String response = res["data"].data.status;

    return response == "success";
  }

  // joins a user to a shared NAS via link
  Future<bool> joinSharedNasAccount(String account_id) async {
    Map<String, dynamic> res =
        await callGeneralFunction("join_shared_nas_account", {
      "request_type": "join_shared_nas_account",
      "account_id": account_id,
    });

    String response = res["data"].data.status;

    return response == "success";
  }

  // 1). Calculates number of minutes to extend account
  // 2). Updates the shared nas account's details (new number of minutes & the name)
  Future<bool> extendExistingSharedNasAccDaysLeft(
      String account_id, int days_to_extend) async {
    Map<String, dynamic> res = await callGeneralFunction(
      "extend_shared_nas_account_days",
      {
        "request_type": "extend_shared_nas_account_days",
        "days_to_extend": days_to_extend,
        "account_id": account_id,
      },
    );

    Map response = res["data"]["data"];

    return response.isEmpty;
  }

  // 1). Calculates number of minutes to extend account
  // 2). Updates the shared nas account's details (new number of minutes & the name)
  Future<bool> updateExistingSharedNasAccName(
      Map account_info, Map changes_info) async {
    // updates the shared nas account row
    Map<String, dynamic> res = await callGeneralFunction(
      "update_nas_account_name",
      {
        "new_account_name": changes_info["new_account_name"],
        "request_type": "update_nas_account_name",
        "account_id": account_info["account_id"],
      },
    );

    return res["data"]["status"] == "success";
  }

  // =================== Join Shared NAS account functions

  // gets the account's row and returns it as Map
  Future<Map> getSharedNasAccountDetails(String account_id) async {
    List<dynamic> account = await supabase
        .from("shared_no_access_savings_accounts")
        .select()
        .eq("account_id", account_id);

    return account.isEmpty ? null : account[0];
  }

  // generates a link for joining shared NAS accounts
  Future<String> generateSharedNasJoinLink(String account_id) async {
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   link: Uri.parse('https://jayben.page.link?id=$account_id'),
    //   androidParameters: const AndroidParameters(
    //     packageName: 'com.jayben.app',
    //     minimumVersion: 1,
    //   ),
    //   uriPrefix: 'https://jayben.page.link',
    //   iosParameters: const IOSParameters(
    //     bundleId: "com.jayben.ios.app",
    //     appStoreId: "1626899274",
    //   ),
    // );

    // // gets a scrambled short link
    // final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
    //     shortLinkType: ShortDynamicLinkType.unguessable, parameters);

    // return dynamicLink.shortUrl.toString();

    return "";
  }

  // =================== Donate to Shared NAS account functions

  // generates a link for donating to shared NAS accounts
  Future<String> generateSharedNasDonationLink(String account_id) async {
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   link: Uri.parse('https://jayben.page.link?id=${account_id}_donation'),
    //   androidParameters: const AndroidParameters(
    //     packageName: 'com.jayben.app',
    //     minimumVersion: 1,
    //   ),
    //   uriPrefix: 'https://jayben.page.link',
    //   iosParameters: const IOSParameters(
    //     bundleId: "com.jayben.ios.app",
    //     appStoreId: "1626899274",
    //   ),
    // );

    // // gets a scrambled short link
    // final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
    //     shortLinkType: ShortDynamicLinkType.unguessable, parameters);

    // print(dynamicLink.shortUrl.toString());

    // return dynamicLink.shortUrl.toString();

    return "";
  }

  // donates money to an active shared nas account
  Future<bool> donateToSharedNasAccount(Map transfer_info) async {
    Map<String, dynamic> res = await callGeneralFunction(
      "donate_to_shared_nas_account",
      {
        "request_type": "donate_to_shared_nas_account",
        "account_id": transfer_info["account_id"],
        "amount": transfer_info["amount"],
      },
    );

    String response = res["data"].data.status;

    return response == "success";
  }
}

// converted to RLS
class AuthProviderFunctions extends ChangeNotifier {
  CountdownTimerController? countdownController;
  bool show_login_password = false;
  final picker = ImagePicker();
  String verificationId = "";
  String jayben_email = "";
  String buildVersion = "";
  PackageInfo? packageInfo;
  File? profileImageFile;
  XFile? pickedPhotoFile;
  bool isLoading = false;
  bool timeUp = false;
  String tos = "";

  // ============ Returners

  String returnTOS() => tos;
  bool returnIsTimeUp() => timeUp;
  bool returnIsLoading() => isLoading;
  String returnJaybenEmail() => jayben_email;
  String returnBuildVersion() => buildVersion;
  File? returnProfileImageFile() => profileImageFile;
  bool returnShowLoginPassword() => show_login_password;
  CountdownTimerController? returnCountdownController() => countdownController;

  // ============ Getters

  void toggleShowLoginPassword() {
    show_login_password = !show_login_password;
    notifyListeners();
  }

  clearAllVariables() {
    tos = "";
    timeUp = false;
    isLoading = false;
    buildVersion = "";
    verificationId = "";
    countdownController;
    pickedPhotoFile = null;
    profileImageFile = null;
    show_login_password = false;
  }

  void stopLoading() {
    isLoading = false;
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  /*
  HOW AUTH FLOW WORKS
    LOGIN:
    1). User enters their phone number
    2). App checks if user's number exists in the database
    3). If number exists, app sends OTPIN to number and routes user to the Enter OTPIN page
    4). User enters OTPIN and gets routed to home page

    SIGNUP: 
    1). User has to enter their account details first (ie: name, address, birthday etc)
    2). User is then routed to the enter number page where they enter their number
    3). User is then routed to the enter OTPIN page to enter the pin
    4). User is then routed to the enter a EnterUsernameProfileImageReferralCodePage
  */

  resetCountDown() {
    timeUp = false;
    notifyListeners();
  }

  Future<void> getBuildVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    buildVersion = packageInfo!.version;

    boxPut("current_build_version", packageInfo!.version);

    notifyListeners();
  }

  // deletes the user's account & auth record
  Future<bool> deleteAccount(String reason) async {
    Map<String, dynamic> res =
        await callGeneralFunction("delete_user_account", {
      "deletion_reason": reason,
    });

    return res["data"].status == "success";
  }

  // checks if user has money somewhere in their account
  Future<bool> checkIfUserHasMoneyInSystemBeforeAccountDeletion() async {
    Map<String, dynamic> res = await callGeneralFunction(
        "check_if_user_has_money_in_system_before_deletion", {});

    return res["data"]["status"] == "success";
  }

  // changes the email address used for the account
  Future<String> changeAccountEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    String message = "Email has been changed successfully";

    try {
      // makes sure the user also knows the passowrd
      // final userCredential =
      //     await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: box("email_address_lowercase").toString(),
      //   password: password,
      // );

      // final user = userCredential.user;

      // // updates the email in their auth record
      // await user?.updateEmail(email).then((value) => message = "success");

      // // updates the user's email in their user document
      // await _fire.collection("Users").doc(box("user_id")).update({
      //   "Email_lowercase": email.toLowerCase(),
      //   "PreviousEmailAddress": box("email_address_lowercase"),
      //   "Email": email,
      // });

      // await _auth.signOut();

      changePage(context, const PreLoginPage(), type: "pr");

      boxDelete("is_logged_in");

      boxDelete("user_id");

      showSnackBar(
        context,
        "Email has been changed successfully! "
        "Please log in again using new email",
        color: Colors.grey[700]!,
      );
    } catch (e) {
      message = e.toString().split("]")[1];
    }

    return message;
  }

  // updates the user's current device ip address
  Future<bool> updateDeviceIDAndIPAddress() async {
    // dynamic ip_address = await ipAddress.getIpAddress();

    final ip_address = await Ipify.ipv4();

    String? device_id;

    try {
      device_id = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      print('Failed to get deviceId.');
    }

    Map<String, dynamic> res =
        await callGeneralFunction("update_device_id_and_ip_address", {
      "new_device_ip_address": ip_address,
      "new_device_id": device_id,
    });

    return res["data"]["status"] == "success";
  }

  // checks if the number user entered exists in DB
  Future<bool> checkIfPhoneNumberAlreadyExists(String? phoneNumber) async {
    Map<String, dynamic> res =
        await callGeneralFunction("check_if_account_phone_number_exists", {
      "phone_number": phoneNumber!.trim(),
    });

    return !res["data"]["data"]["exists"];
  }

  // checks if auth account exists for AUTH
  Future<bool> checkIfEmailExists(String? email) async {
    Map<String, dynamic> res =
        await callGeneralFunction("check_if_account_email_address_exists", {
      "email_address": email!.trim().toLowerCase(),
    });

    return res["data"]["data"]["exists"];
  }

  // checks if the username has already been used
  Future<bool?> checkIfUsernameExists(String? username) async {
    Map<String, dynamic> res =
        await callGeneralFunction("check_if_account_username_exists", {
      "username": username!.toLowerCase(),
    });

    if (res == null || res.isEmpty) {
      return null;
    }

    return !res["data"]["data"]["exists"];
  }

  // checks if the referral code entered is valid
  Future<bool> checkIfReferralCodeIsValid(String referralCode) async {
    Map<String, dynamic> res =
        await callGeneralFunction("check_if_referral_code_exists", {
      "referral_code": referralCode,
    });

    return res["data"]["data"]["exists"];
  }

  // opens gallery for user to pick a photo
  // then routes the user to the create post page
  Future<void> getProfileImage() async {
    pickedPhotoFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedPhotoFile != null) {
      profileImageFile = File(pickedPhotoFile!.path);
      notifyListeners();
    }
  }

  // uploads profile image to firebase
  // and gets the url of the photo from DB
  Future<String> uploadProfileImage() async {
    if (profileImageFile == null) return "";

    final imageName = basename(profileImageFile!.path);
    //this gets the filename excluding the path...

    final destination = 'UserProfileImages/$imageName';
    //this defines where the image is stored on the server

    UploadTask? task = uploadFileToFirebase(destination, profileImageFile!);
    //task to upload the image

    if (task == null) return "";

    final snapshot = await task.whenComplete(() {});
    //returns a snapshot when upload is complete

    return await snapshot.ref.getDownloadURL();
    //gets the image url
  }

  // uploads the profileImage to firebase
  static UploadTask? uploadFileToFirebase(String destination, File image) {
    //function to upload the images... with a destination and an image to be uploaded
    try {
      final ref = FirebaseStorage.instance.ref(
          destination); //this defines the place where the images are to be stored

      return ref.putFile(
          image); //this is function to run the action of uploading the images
    } on FirebaseException catch (_) {
      return null;
    }
  }

  Future<void> signInWithEmailAndPassword(context, Map login_info) async {
    // 1).
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        password: login_info["password"],
        email: login_info["email"].toString().trim().toLowerCase(),
      );

      if (res.user == null) return;

      boxPut("session", res.session!.toJson());

      boxPut("user_id", res.user!.id);
    } on AuthException catch (error) {
      if (error.message == "Invalid login credentials") {
        showSnackBar(context, "Invalid email or password.");
      }
    } catch (error) {
      showSnackBar(context, "Unexpected auth error occurred");
    }

    // listens to when the user logs in again HOPEFULLY
    supabase.auth.onAuthStateChange.listen((AuthState data) async {
      if (data.event != AuthChangeEvent.signedIn) return;

      boxPut("is_logged_in", "true");

      // 2).
      changePage(context, const HomePage(), type: "pr");

      await updateDeviceIDAndIPAddress();
    });
  }

  // 1). Signs the user up and gets a user_id
  // 2). Creates the user's account row in supabase
  // 3). Routes the user to the nav bar page (home page)
  Future<void> createUserWithEmailAndPassword(
      BuildContext context, Map user_info) async {
    String user_id = "";

    // 1).
    try {
      // creates a supabase auth profile
      final AuthResponse res = await supabase.auth.signUp(
        email: user_info["email"].toString().trim().toLowerCase(),
        data: {
          "first_name": user_info["first_name"],
          "last_name": user_info["last_name"]
        },
        password: user_info["password"],
      );

      if (res.user == null) return;

      // stores the session info locally
      // boxPut("session", res.session!.toJson());

      user_id = res.user!.id;

      // if (res.user!.id != null) {
      // stores the user's user_id locally
      // boxPut("user_id", user_id);

      // // marks the account as logged in
      // boxPut("is_logged_in", "true");

      // // 2).
      // await createUserAccount(context, {"user_id": user_id, ...user_info});

      // showSnackBar(context, "Account has been created successfully",
      //     color: Colors.green);

      // // 3).
      // changePage(context, const HomePage(), type: "pr");
      // }
    } on AuthException catch (error) {
      if (error.message == "User already registered") {
        showSnackBar(context,
            "Email address has already been used by another account. Please use a different email");
      }
    } catch (_) {
      showSnackBar(context, "Unexpected auth error occurred");
    }

    // listens for sign up actions
    supabase.auth.onAuthStateChange.listen((AuthState data) async {
      if (data.event != AuthChangeEvent.signedIn) return;

      // stores the user's user_id locally
      boxPut("user_id", user_id);

      // marks the account as logged in
      boxPut("is_logged_in", "true");

      // 2).
      await createUserAccount(context, {"user_id": user_id, ...user_info});

      isLoading = false;

      notifyListeners();

      showSnackBar(context, "Account has been created successfully",
          color: Colors.green);

      // 3).
      changePage(context, const HomePage(), type: "pr");
    });
  }

  // uploads the profile image
  Future<void> createUserAccount(BuildContext context, Map userInfo) async {
    // gets user's notification token
    String? notif_token;

    if (Platform.isIOS) {
      notif_token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      notif_token = await FirebaseMessaging.instance.getToken();
    }

    // gets curreny details using country ISO code
    List<String> currency_details =
        await getCurrencyDetails(userInfo["selected_country_iso_code"]);

    // gets the device's ip address
    final ip_address = await Ipify.ipv4();

    // creates the user's account row
    Map<String, dynamic> res =
        await callGeneralFunction("create_user_account_record", {
      "user_code": ["Agent"].contains(box("account_type"))
          ? null
          : box("user_id").substring(box("user_id").length - 6).toLowerCase(),
      "email_address_lowercase": userInfo["email"].toString().toLowerCase(),
      "username_searchable": userInfo["username"].toString().toLowerCase(),
      "referral_code": userInfo['referral_code'].toString().toLowerCase(),
      "last_time_online_timestamp": DateTime.now().toIso8601String(),
      "current_os_platform": Platform.isAndroid ? "Android" : "iOS",
      "account_login_password": userInfo["password"],
      'date_of_birth': userInfo["date_of_birth"],
      "country_code": userInfo["country_code"],
      'phone_number': userInfo["phone_number"],
      "account_type": userInfo["account_type"],
      'country': userInfo["selected_country"],
      "current_device_ip_address": ip_address,
      "physical_address": userInfo["address"],
      "currency_symbol": currency_details[0],
      "current_build_version": buildVersion,
      'first_name': userInfo["first_name"],
      "email_address": userInfo["email"],
      'last_name': userInfo["last_name"],
      "notification_token": notif_token,
      'username': userInfo["username"],
      "currency": currency_details[1],
      'gender': userInfo["gender"],
      'city': userInfo["city"],
    });

    String status = res["data"]["status"];

    String message = res["data"]["message"];

    showSnackBar(
      context,
      message,
      color: status == "success" ? Colors.green : Colors.red,
    );
  }

  // gets the current device's information
  Future<String> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');

      return androidInfo.model;
    }

    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    print('Running on ${iosInfo.utsname.machine}');

    return iosInfo.utsname.machine;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // creates a 6 digit pin
  Future<void> createSixDigitPin(String decrypted_pin) async {
    // encrypts the 6 digit pin and returns a string
    // String? encrypted_pin = await encryptPin(decrypted_pin);

    // await _fire.collection("Users").doc(box("user_id")).update({
    //   "PIN": encrypted_pin,
    // });
  }

  // gifts the new user a new account that also shows them how no access accounts work
  Future<void> createNoFreeAccessAccount(Map account_info) async {
    // DocumentSnapshot admin_doc =
    //     await _fire.collection("Admin").doc("Legal").get();

    // if (admin_doc.get("NewUserNoAccessAccountAmount") == 0) return;

    // DateTime expiration_date = DateTime.now().add(Duration(
    //     minutes: admin_doc.get("NewUserNoAccessAccountDurationInMinutes")));
    // // date the account will expire

    // int number_of_minutes_left =
    //     admin_doc.get("NewUserNoAccessAccountDurationInMinutes");

    String? notif_token;

    if (Platform.isIOS) {
      notif_token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      notif_token = await FirebaseMessaging.instance.getToken();
    }

    // creates a new row
    // await supabase.from("no_access_savings_accounts").insert({
    //   "currency_symbol": account_info["currency"] == "ZMW" ? "K" : "",
    //   "expiration_date_and_time": expiration_date.toIso8601String(),
    //   "account_holder_details": {
    //     "profile_image_url": account_info["profile_image_url"],
    //     "first_name": account_info["first_name"],
    //     "last_name": account_info["first_name"],
    //     "Username": account_info["username"],
    //     "user_is_verified": false,
    //     "user_id": box("user_id"),
    //   },
    //   "balance": admin_doc.get("NewUserNoAccessAccountAmount"),
    //   "last_deposit_date": DateTime.now().toIso8601String(),
    //   "total_minutes_for_account": number_of_minutes_left,
    //   "account_holder_notification_token": notif_token,
    //   "number_of_minutes_left": number_of_minutes_left,
    //   "number_of_withdrawals_made_from_account": 0,
    //   "account_name": "A welcome gift to you 🎁",
    //   "number_of_deposits_made_to_account": 1,
    //   "currency": account_info["currency"],
    //   "account_type": "no access account",
    //   "total_days_for_account": "0.0833",
    //   "country": account_info["country"],
    //   "city": account_info["city"],
    //   "user_id": box("user_id"),
    //   "account_id": id.v4(),
    //   "is_deleted": false,
    //   "is_active": true,
    // });
  }

  // gets currency details
  Future<List<String>> getCurrencyDetails(String countryISOCode) async {
    Country country = CountryData().getCountryById(countryId: countryISOCode)!;

    List<String> currencyDetails = [];

    if (country.currency.contains(",")) {
      var currencySplit = country.currency.split(",");
      var currencyCodeSpit = country.currencyCode.split(",");
      currencyDetails.addAll([currencySplit[0], currencyCodeSpit[0]]);
    } else {
      currencyDetails.addAll([country.currency, country.currencyCode]);
    }

    if (countryISOCode == "ZM") {
      currencyDetails.clear();
      currencyDetails.addAll(["K", "ZMW"]);
    }

    return currencyDetails;
  }
  // returns a currency, and currency symbol

  // sends a reset password link to the email entered
  Future forgotPassword(String email) async {
    // try {
    //   await _auth.sendPasswordResetEmail(email: email.trim());
    // } on FirebaseAuthException catch (e) {
    //   return e.code;
    // }
  }

  // checks if the pin entered by user is correct
  Future<bool> checkIfPINCorrect(String entered_pin) async {
    Map<String, dynamic> res =
        await callGeneralFunction("check_if_pin_is_correct", {
      "entered_pin": entered_pin,
    });

    return res["data"]["status"] == "success";
  }

  // changes user's current pin
  Future<bool> changePIN(String new_pin_code, String old_pin_code) async {
    Map<String, dynamic> res = await callGeneralFunction("change_pin_code", {
      "old_pin_code": old_pin_code,
      "new_pin_code": new_pin_code,
    });

    return res["data"]["status"] == "success";
  }

  Future<bool> resetPIN(String any_previous_pin_code_used) async {
    Map<String, dynamic> res = await callGeneralFunction("reset_pin_code", {
      "any_previous_pin_code_used": any_previous_pin_code_used,
    });

    return res["data"].data.status == "success";
  }

  Future<String> getResetEmail() async {
    Map<String, dynamic> res = await callGeneralFunction("get_reset_email", {});

    return res["data"]["data"]["email"];
  }

  // gets the app's contact us info
  Future<void> getContactUsDetails() async {
    // gets this user's account record row
    Map<String, dynamic> res =
        await callGeneralFunction("get_contact_us_details", {});

    Map app_settings = res["data"]["data"];

    boxPut("currency", app_settings["currency"]);
    boxPut("jayben_secondary_customer_support_hotline",
        app_settings["jayben_secondary_customer_support_hotline"]);
    boxPut("agent_payments_withdraw_fee_percent",
        app_settings["agent_payments_withdraw_fee_percent"]);
    boxPut("jayben_primary_customer_support_email_address",
        app_settings["jayben_primary_customer_support_email_address"]);
    boxPut("customer_support_whatsapp_phone_number",
        app_settings["customer_support_whatsapp_phone_number"]);
    boxPut("intl_wire_transfer_withdraw_fee_in_usd",
        app_settings["intl_wire_transfer_withdraw_fee_in_usd"]);
    boxPut("general_withdraw_amount_limit",
        app_settings["general_withdraw_amount_limit"]);
    boxPut("transaction_fee_percentage_to_merchants",
        app_settings["transaction_fee_percentage_to_merchants"]);
    boxPut("minimum_savings_deposit_amount",
        app_settings["minimum_savings_deposit_amount"].toString());
    boxPut("jayben_primary_customer_support_hotline",
        app_settings["jayben_primary_customer_support_hotline"]);
    boxPut("user_referral_commission_percentage",
        app_settings["user_referral_commission_percentage"]);
    boxPut("local_wire_transfer_withdraw_fee_in_usd",
        app_settings["local_wire_transfer_withdraw_fee_in_usd"]);

    notifyListeners();
  }

  // converts a regular email to a reducted version
  Future<void> processResetEmail() async {
    // DocumentSnapshot ds =
    //     await _fire.collection("Users").doc(box("user_id")).get();

    // var emailPrefix = ds.get("Email").split("@");

    // if (emailPrefix.length > 1 && emailPrefix != null) {
    //   String lastLetter = emailPrefix[0].substring(emailPrefix[0].length - 1);

    //   boxPut("obscured_email",
    //       "${emailPrefix[0][0].toString().toUpperCase()}****${lastLetter.toString().toLowerCase()}@${emailPrefix[1]}");
    // }
    // returns an email eg J****a@gmail.com for Justinkaunda@gmail.com
  }

  // gets terms anf conditions
  Future<void> getTOS() async {
    Map<String, dynamic> res =
        await callGeneralFunction("get_terms_of_service", {});

    tos = res["data"]["data"]["terms_of_service"];

    jayben_email = res["data"]["data"]["jayben_primary_customer_support_email"];

    notifyListeners();
  }

  // routes user according to their login status
  Future<void> splashScreenNav(
    BuildContext context,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 1300),
      () async {
        if (box("is_logged_in") == null) {
          changePage(context, const PreLoginPage(), type: "pr");

          return;
        }

        changePage(
            context,
            box("enable_six_digit_pin") == null
                ? HomePage()
                : box("enable_six_digit_pin") && box("pin_code") != ""
                    ? const PasscodePage()
                    : HomePage(),
            type: "pr");
      },
    );
  }
}

class PaymentProviderFunctions extends ChangeNotifier {
  List<dynamic> username_search_results = [];
  List<String> paymentRequestsLoading = [];
  Timer? delete_character_timer;
  String amount_string = "";
  bool isLoading = false;

  // ============ returners

  bool returnIsLoading() => isLoading;
  String returnAmountString() => amount_string;
  Timer? returnDeleteCharacterTimer() => delete_character_timer;
  List<String> returnPaymentRequestsLoading() => paymentRequestsLoading;
  List<dynamic> returnUsernameSearchResults() => username_search_results;

  // ============ getters

  void clearAllVariables() {
    isLoading = false;
    paymentRequestsLoading.clear;
    notifyListeners();
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    print(isLoading);
    notifyListeners();
  }

  // adds or removes paymentIDs from paymentRequestsLoading list
  // is used to change what initiated payment tile is currently loading
  void updatePaymentRequestList(String paymentID) {
    if (paymentRequestsLoading.contains(paymentID)) {
      paymentRequestsLoading.add(paymentID);
    } else {
      paymentRequestsLoading.removeWhere((element) => element == paymentID);
    }

    notifyListeners();
  }

  void clearStrings() {
    amount_string = "";
  }

  void resetUsernameSearchResults() {
    username_search_results.clear();
  }

  // adds characters to the current display string
  void addCharacter(String char) {
    if (amount_string.contains(".") && char == ".") return;

    if (amount_string.isEmpty && char == "0") return;

    if (amount_string.length == 10) return;

    amount_string += char;

    notifyListeners();
  }

  // removes last character from the current display string
  void removeCharacter(String char) {
    if (amount_string.isEmpty) return;

    amount_string = amount_string.substring(0, amount_string.length - 1);

    notifyListeners();
  }

  // stops the deletion of the text
  void cancelDeleteCharTimer() {
    if (delete_character_timer == null) return;

    delete_character_timer!.cancel();

    notifyListeners();
  }

  // starts deleting the text character by character
  Future<void> startCharacterDeletion(String text) async {
    delete_character_timer =
        Timer.periodic(const Duration(milliseconds: 110), (timer) async {
      if (text == "clear") {
        Vibrate.feedback(FeedbackType.light);

        removeCharacter(text);
      }
    });
  }

  // gets a list of user rows that have the username
  Future<List<dynamic>> searchUsername(String username) async {
    Map<String, dynamic> res = await callGeneralFunction("search_username", {
      "username": username,
    });

    username_search_results = res["data"]["data"]["data"];

    notifyListeners();

    return username_search_results;
  }

  // transfers money to a non merchant Jayben user
  Future<bool> sendMoneyP2P(Map paymentInfo) async {
    Map<String, dynamic> res = await callGeneralFunction(
      "send_money_p2p",
      {
        "post_is_public": box("default_transaction_visibility") == "Public",
        "receiver_user_id": paymentInfo['receiver_user_id'],
        "comment": paymentInfo['comment'],
        "amount": paymentInfo["amount"],
        "method": "Wallet transfer",
        "currency": box("currency"),
        "user_id": box("user_id"),
        "country": box("country"),
        "media_details": [
          {
            "media_caption": "",
            "thumbnail_url": "",
            "post_type": "text",
            "aspect_ratio": "",
            "media_type": "",
            "media_url": "",
          }
        ],
      },
    );

    return res["data"]["status"] == "success";
  }

  List<String> computeDates(int daysLeft) {
    String creationDateFormatted =
        DateFormat('MMM dd yyyy').format(DateTime.now());
    // used to skip transactions that are created on the same date as the server date

    DateTime expirationDate = DateTime.now().add(Duration(days: daysLeft));
    // date the transaction will expire

    String expirationDateFormatted =
        DateFormat('MMM dd yyyy').format(expirationDate);

    return [creationDateFormatted, expirationDateFormatted];
  }

  // ============ QR Code scanner payment functions
}

// converted to RLS
class GiftProviderFunctions extends ChangeNotifier {
  bool is_loading = false;

  // ========================
}

// converted to RLS
class AirtimeProviderFunctions extends ChangeNotifier {
  String phone_number_string = box("phone_number") == null
      ? ""
      : "${box("phone_number").replaceAll("+26", "")}";
  String payment_method = "Pay With Wallet";
  Timer? delete_character_timer;
  int current_page_index = 0;
  String amount_string = "";
  bool isLoading = false;

  // ========== variables

  bool returnIsLoading() => isLoading;
  String returnAmountString() => amount_string;
  String returnPaymentMethod() => payment_method;
  int returnCurrentPageIndex() => current_page_index;
  String returnPhoneNumberString() => phone_number_string;
  Timer? returnDeleteCharacterTimer() => delete_character_timer;

  // ========= setters

  void clearAllVariables() {
    isLoading = false;
    notifyListeners();
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void clearStrings() {
    phone_number_string = box("phone_number").replaceAll("+26", "");
    payment_method = "Pay With Wallet";
    current_page_index = 0;
    amount_string = "";
  }

  void ChooseMethod(String method) {
    payment_method = method;
    notifyListeners();
  }

  // adds characters to the current display string
  void addCharacter(String char) {
    if (char == ".") return;

    if (current_page_index == 1) {
      if (phone_number_string.length == 10) return;

      phone_number_string += char;
    } else {
      if (amount_string.contains(".") && char == ".") return;

      if (amount_string.isEmpty && char == "0") return;

      if (amount_string.length == 10) return;

      amount_string += char;
    }

    notifyListeners();
  }

  // removes characters to the current display string
  void removeCharacter(String char) {
    if (phone_number_string.isEmpty || amount_string.isEmpty) return;

    if (current_page_index == 1) {
      phone_number_string =
          phone_number_string.substring(0, phone_number_string.length - 1);
    } else {
      amount_string = amount_string.substring(0, amount_string.length - 1);
    }

    notifyListeners();
  }

  void changePageIndex(int index) {
    current_page_index = index;
    notifyListeners();
  }

  // stops the deletion of the text
  void cancelDeleteCharTimer() {
    if (delete_character_timer == null) return;

    delete_character_timer!.cancel();

    notifyListeners();
  }

  // starts deleting the text character by character
  Future<void> startCharacterDeletion(String text) async {
    delete_character_timer =
        Timer.periodic(const Duration(milliseconds: 110), (timer) async {
      if (text == "clear") {
        Vibrate.feedback(FeedbackType.light);

        removeCharacter(text);
      }
    });
  }

  Future<bool> payWithWallet(BuildContext context) async {
    if (isLoading) return false;

    if (phone_number_string.length < 10) {
      showSnackBar(context, 'Enter a 10 digit phone number');

      return false;
    }

    if (phone_number_string[0] != "0" ||
        ["7", "9"].contains(phone_number_string[1]) == false ||
        ["5", "6", "7"].contains(phone_number_string[2]) == false) {
      showSnackBar(context, 'Enter a valid Zambian phone number');

      return false;
    }

    double amount_to_buy = double.parse(amount_string.replaceAll('-', ''));

    String phone_number = phone_number_string.trim();

    showSnackBar(
      context,
      "Airtime purchase is being processed. Please wait.",
      color: Colors.grey[800]!,
    );

    // routes user back to the home page
    changePage(context, const HomePage(), type: "pr");

    // submits a request to purchase airtime
    return await buyAirtime(amount_to_buy, phone_number, "cash");
  }

  Future<bool> payWithPoints(BuildContext context) async {
    if (isLoading) return false;

    if (phone_number_string.length < 10) {
      showSnackBar(context, 'Enter a 10 digit phone number');

      return false;
    }

    if (phone_number_string[0] != "0" ||
        ["7", "9"].contains(phone_number_string[1]) == false ||
        ["5", "6", "7"].contains(phone_number_string[2]) == false) {
      showSnackBar(context, 'Enter a valid Zambian phone number');

      return false;
    }

    String phone_number = phone_number_string.trim();

    double amount_to_buy = double.parse(amount_string);

    showSnackBar(context, "Airtime purchase is being processed. Please wait.",
        color: Colors.grey[800]!);

    // routes user back to the home page
    changePage(context, const HomePage(), type: "pr");

    // submits a request to purchase airtime
    return await buyAirtime(amount_to_buy, phone_number, "points");
  }

  // creates a reques to purchase airtime
  Future<bool> buyAirtime(double amount_to_purchase, String phone_number,
      String method_of_purchase) async {
    Map<String, dynamic> res = await callGeneralFunction("purchase_airtime", {
      "method_of_purchase": method_of_purchase,
      "amount": amount_to_purchase,
      "phone_number": phone_number,
      "currency": box("currency"),
      "post_is_public": false,
      "media_details": [
        {
          "media_caption": null,
          "thumbnail_url": null,
          "aspect_ratio": null,
          "media_type": null,
          "post_type": null,
          "media_url": null
        }
      ],
      "comment": null,
    });

    return res["data"]["status"] == "success";
  }
}

// converted to RLS
class WithdrawProviderFunctions extends ChangeNotifier {
  String phone_number_string = box("phone_number") == null
      ? ""
      : "${box("phone_number").replaceAll("+26", "")}";
  Timer? delete_character_timer;
  int current_page_index = 0;
  String amount_string = "";
  bool isLoading = false;
  // ========== variables

  bool returnIsLoading() => isLoading;
  String returnAmountString() => amount_string;
  int returnCurrentPageIndex() => current_page_index;
  String returnPhoneNumberString() => phone_number_string;
  Timer? returnDeleteCharacterTimer() => delete_character_timer;

  // ============= getters

  void clearAllVariables() {
    isLoading = false;
    notifyListeners();
  }

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void clearStrings() {
    phone_number_string = box("phone_number").replaceAll("+26", "");
    current_page_index = 0;
    amount_string = "";
  }

  // adds characters to the current display string
  void addCharacter(String char) {
    if (current_page_index == 1) {
      if (char == ".") return;

      if (phone_number_string.length == 10) return;

      phone_number_string += char;
    } else {
      if (amount_string.contains(".") && char == ".") return;

      if (amount_string.isEmpty && char == "0") return;

      if (amount_string.length == 10) return;

      amount_string += char;
    }

    notifyListeners();
  }

  // removes last character from the current display string
  void removeCharacter(String char) {
    if (phone_number_string.isEmpty || amount_string.isEmpty) return;

    if (current_page_index == 1) {
      phone_number_string =
          phone_number_string.substring(0, phone_number_string.length - 1);
    } else {
      amount_string = amount_string.substring(0, amount_string.length - 1);
    }

    notifyListeners();
  }

  void changePageIndex(int index) {
    current_page_index = index;
    notifyListeners();
  }

  // stops the deletion of the text
  void cancelDeleteCharTimer() {
    if (delete_character_timer == null) return;

    delete_character_timer!.cancel();

    notifyListeners();
  }

  // starts deleting the text character by character
  Future<void> startCharacterDeletion(String text) async {
    delete_character_timer =
        Timer.periodic(const Duration(milliseconds: 110), (timer) async {
      if (text == "clear") {
        Vibrate.feedback(FeedbackType.light);

        removeCharacter(text);
      }
    });
  }

  // makes sure the phone number that is entered is formatted
  Future<void> prepareWithdrawal(BuildContext context, Map map) async {
    if (isLoading) return;

    if (phone_number_string.length < 10) {
      showSnackBar(context, 'Enter a 10 digit phone number');

      return;
    }

    if (phone_number_string[0] != "0" ||
        ["7", "9"].contains(phone_number_string[1]) == false ||
        ["5", "6", "7"].contains(phone_number_string[2]) == false) {
      showSnackBar(context, 'Enter a valid Zambian phone number');

      return;
    }

    String payment_method = "";

    if (phone_number_string[2] == "5") {
      payment_method = "Zamtel Money";
    } else if (phone_number_string[2] == "6") {
      payment_method = "MTN Money";
    } else if (phone_number_string[2] == "7") {
      payment_method = "Airtel Money";
    }

    changePage(
      context,
      WithdrawMoneyConfirmationPage(
        paymentInfo: {
          "phoneNumber": phone_number_string,
          "paymentMethod": payment_method,
          ...map,
        },
      ),
    );
  }

  // submits a withdrawal request
  Future<bool> submitWithdrawal(Map paymentInfo) async {
    double transaction_fee_amount =
        double.parse(paymentInfo['amountPlusFee'].toString()) -
            double.parse(paymentInfo['amountBeforeFee'].toString());

    // Submit withdrawal using general function
    Map<String, dynamic> res = await callGeneralFunction(
      "submit_mobile_money_withdrawal",
      {
        "amount_to_withdraw_minus_fee": paymentInfo['amountBeforeFee'],
        "amount_to_withdraw_plus_fee": paymentInfo['amountPlusFee'],
        "transaction_fee_amount": transaction_fee_amount,
        "transaction_fee_currency": box("currency"),
        "phone_number": paymentInfo['phoneNumber'],
        "method": paymentInfo['paymentMethod'],
        "reference": paymentInfo['reference'],
      },
    );

    return res["data"].data.status == "success";
  }
}

// converted to RLS
class ReferralProviderFunctions extends ChangeNotifier {
  List<dynamic>? referral_commissions;
  int? number_of_people_referred;
  bool is_loading = false;
  int current_index = 0;

  // ==================== getters

  bool returnIsLoading() => is_loading;
  int returnCurrentIndex() => current_index;
  int? returnNumberOfPeopleReferred() => number_of_people_referred;
  List<dynamic>? returnReferralCommissions() => referral_commissions;

  // ==================== setters

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  void changeIndex(int index) {
    current_index = index;
    notifyListeners();
  }

  // gets a snapshot of all referral commissions & number of people referred
  Future<bool> getMyReferralCommissions() async {
    Map<String, dynamic> res = await callGeneralFunction(
      "get_my_referral_commissions",
      {
        "get_number_of_people_user_referred": true,
        "number_of_rows_to_query": "all",
      },
    );

    List<dynamic>? commissions_rows =
        res["data"]["data"]["referral_commissions"];

    List<dynamic>? people_invited_rows =
        res["data"]["data"]["people_user_has_referred"];

    referral_commissions = commissions_rows;

    number_of_people_referred =
        res["data"]["data"]["people_user_has_referred_count"] ?? 0;

    notifyListeners();

    return res["data"]["status"] == "success";
  }

  // opens the message app and gets ready to send sms
  Future<void> addFriend(String phone_number) async {
    // String? result = await sendSMS(message: "Test", recipients: [phone_number]);

    // print(result);
  }

  // generates a link for joining shared NAS accounts
  Future<String> generateAppDownloadLink() async {
    // final DynamicLinkParameters parameters = DynamicLinkParameters(
    //   link: Uri.parse('https://jayben.page.link?${box("user_id")}'),
    //   androidParameters: const AndroidParameters(
    //     packageName: 'com.jayben.app',
    //     minimumVersion: 1,
    //   ),
    //   uriPrefix: 'https://jayben.page.link',
    //   iosParameters: const IOSParameters(
    //     bundleId: "com.jayben.ios.app",
    //     appStoreId: "1626899274",
    //   ),
    // );

    // // gets a scrambled short link
    // final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
    //     shortLinkType: ShortDynamicLinkType.unguessable, parameters);

    // return dynamicLink.shortUrl.toString();

    return "";
  }
}

// converted to RLS
class UssdProviderFunctions extends ChangeNotifier {
  List<dynamic>? list_of_shortcuts;
  bool is_loading = false;

  // ========================= getters

  bool returnIsLoading() => is_loading;
  List<dynamic>? returnListOfShorcuts() => list_of_shortcuts;

  // ========================= setters

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  // 1). creates a record of the ussd shortcut in supabase
  // 2). runs getUSSDShortcuts() to update the list of saved ussd shortcuts
  Future<void> createUSSDShortcut(String shortcut_name, String shortcut) async {
    await supabase.from("ussd_shortcuts").insert({
      "is_active": true,
      "shortcut": shortcut,
      "number_times_used": 0,
      "number_of_edits_made": 0,
      "user_id": box("user_id"),
      "country": box("country"),
      "shortcut_name": shortcut_name,
      "shortcut_creator_details": {
        "last_name": box("last_name"),
        "first_name": box("first_name"),
        "profile_image_url": box("profile_image_url"),
      }
    });

    // updates the list of shortcuts
    await getUSSDShortcuts();
  }

  // gets all the user's saved USSD shortcuts
  Future<void> getUSSDShortcuts() async {
    try {
      // gets saved list from supabase database
      list_of_shortcuts = await supabase
          .from("ussd_shortcuts")
          .select()
          .eq("is_active", true)
          .eq("user_id", box("user_id"))
          .order("created_at", ascending: false);

      // saves the list locally for when user has no internet
      boxPut("list_of_ussd_shortcuts", list_of_shortcuts);
    } catch (e) {
      if (box("list_of_ussd_shortcuts") != null) {
        // assigns the existing codes stored locally instead
        list_of_shortcuts = box("list_of_ussd_shortcuts");
      }
    }

    notifyListeners();
  }

  // runs the ussd shortcut
  Future<void> runShortcut(Map shortcut_map) async {
    // String shortcut = shortcut_map["shortcut"].replaceAll(" ", "");

    // int subscription = shortcut_map["subscription"];

    // // this code divides the list by commas
    // List<String> steps = shortcut.split(">");
    // // ex: "*117# > 1 > 2 > 6 > 1234"

    // // keeps track of all responses returned
    // List<dynamic> list_of_responses = [];

    // // dials the code
    // String? res_1 = await dialCode(steps[0], subscription);
    // // ex: dials *117#

    // if (res_1 == null) {
    //   await cancelSession();
    //   return;
    // }

    // // stores the response
    // list_of_responses.add({
    //   "description": "dial code",
    //   "step_value": steps[0],
    //   "response": res_1,
    //   "step_number": 1,
    // });

    // // excuted the steps after dialing code
    // for (var i = 0; i < steps.length - 1; i++) {
    //   if (steps[i + 1] == "pin") {
    //     String? res_2 = await sendOption(box("mobile_money_pin"));

    //     if (res_2 == null) {
    //       await cancelSession();
    //       return;
    //     }

    //     // stores the response
    //     list_of_responses.add({
    //       "description": "enter pin",
    //       "step_value": steps[i + 1],
    //       "step_number": i + 1,
    //       "response": res_2,
    //     });
    //   } else {
    //     String? res_3 = await sendOption(steps[i + 1]);

    //     if (res_3 == null) {
    //       await cancelSession();
    //       return;
    //     }

    //     // stores the response
    //     list_of_responses.add({
    //       "description": "post dial code session",
    //       "step_value": steps[i + 1],
    //       "step_number": i + 1,
    //       "response": res_3,
    //     });

    //     if (res_3.contains("Do you want to continue with last transaction")) {
    //       // this is for fnb flows...
    //       String? res_4 = await sendOption("2");

    //       if (res_4 == null) {
    //         await cancelSession();
    //         return;
    //       }

    //       // stores the response
    //       list_of_responses.add({
    //         "description": "fnb related - post dial code session",
    //         "step_value": steps[i + 1],
    //         "step_number": i + 1,
    //         "response": res_4,
    //       });
    //     }
    //   }
    // }

    // // 1). creates a row record of the session
    // // 2). increases the number of edits counter
    // // 3). updates the list of shortcuts locally
    // await Future.wait([
    //   recordSession({...shortcut_map, "list_of_responses": list_of_responses}),
    //   supabase.rpc("increase_ussd_shortcut_number_times_used",
    //       params: {"row_id": shortcut_map["shortcut_id"]}),
    //   getUSSDShortcuts(),
    // ]);
  }

  // 1). edits the shortcut's record in the database
  // 2). calls getUSSDShortcuts() to get an updated list of shortcuts
  Future<void> editShortcut(Map edit_info) async {
    await supabase.from("ussd_shortcuts").update({
      "shortcut": edit_info["shortcut"],
      "shortcut_name": edit_info["shortcut_name"],
    }).eq("shortcut_id", edit_info["shortcut_id"]);

    // 1). updates the list of shortcuts locally
    // 2). increases the number of edits counter
    await Future.wait([
      getUSSDShortcuts(),
      supabase.rpc("increase_ussd_shortcut_number_of_edits_made",
          params: {"row_id": edit_info["shortcut_id"]}),
    ]);
  }

  // 1). edits the shortcut's record in the database to inactive
  // 2). calls getUSSDShortcuts() to get an updated list of shortcuts
  Future<void> deleteShortcut(String shortcut_id) async {
    await supabase.from("ussd_shortcuts").update({
      "is_active": false,
    }).eq("shortcut_id", shortcut_id);

    await getUSSDShortcuts();
  }

  // creates a record for the ussd run session
  Future<void> recordSession(Map shortcut) async {
    await await supabase.from("ussd_shortcut_run_sessions").insert({
      "user_id": box("user_id"),
      "country": box("country"),
      "shortcut": shortcut["shortcut"],
      "shortcut_id": shortcut["shortcut_id"],
      "shortcut_name": shortcut["shortcut_name"],
      "list_of_responses": shortcut["list_of_responses"],
      "user_details": {
        "gender": box("gender"),
        "last_name": box("last_name"),
        "first_name": box("first_name"),
        "phone_number": box("phone_number"),
        "sim_number": shortcut["sim_number"],
        "carrier_name": shortcut["carrier_name"],
        "country_code": shortcut["country_code"],
        "profile_image_url": box("profile_image_url"),
        "country_prefix": shortcut["country_prefix"],
        "sim_card_slot_number": shortcut["subscription"],
        "carrier_display_name": shortcut["carrier_display_name"],
      },
    });
  }

  // starts a USSD session by dialing a code
  // Future<String?> dialCode(String dial_code, int subscription) async {
  //   return await UssdAdvanced.multisessionUssd(
  //       code: dial_code, subscriptionId: subscription);
  // }

  // sends a message in an existing USSD session
  // Future<String?> sendOption(String option) async {
  //   return await UssdAdvanced.sendMessage(option);
  // }

  // ends an existing session
  Future<void> cancelSession() async {
    // await UssdAdvanced.cancelSession();
  }
}

// converted to RLS
class KycProviderFunctions extends ChangeNotifier {
  String selected_document_type = "National ID (NRC)";
  String current_verification_status = "";
  List<dynamic>? verification_requests;
  bool is_submitting_files = false;
  int number_of_files_uploaded = 0;
  final picker = ImagePicker();
  int current_page_index = 0;
  double upload_progress = 0;
  bool is_loading = false;
  File? document_photo_2;
  File? document_photo_1;
  File? selfie_photo;

  // =========================== getters

  bool returnIsLoading() => is_loading;
  File? returnSelfiePhoto() => selfie_photo;
  double returnUploadProgress() => upload_progress;
  int returnCurrentPageIndex() => current_page_index;
  bool returnIsSubmittingFiles() => is_submitting_files;
  int returnNumberOfFileUploaded() => number_of_files_uploaded;
  String returnSelectedDocumentType() => selected_document_type;
  List<dynamic>? returnVerificationRequests() => verification_requests;
  String returnCurrentVerificationStatus() => current_verification_status;
  List<File?> returnDocumentPhotos() => [document_photo_1, document_photo_2];

  // =========================== setters

  void changeCurrentPageIndex(int index) {
    current_page_index = index;
    notifyListeners();
  }

  // makes a selected image null
  void nullifyPhotoFile(int index) {
    if (index == 3) {
      selected_document_type = "National ID (NRC)";
      number_of_files_uploaded = 0;
      current_page_index = 0;
      document_photo_2 = null;
      document_photo_1 = null;
      selfie_photo = null;
      return;
    }

    if (index == 0) {
      selfie_photo = null;
    } else if (index == 1) {
      document_photo_1 = null;
    } else if (index == 2) {
      document_photo_2 = null;
    }

    notifyListeners();
  }

  void changeDocumentType(String type) {
    selected_document_type = type;
    notifyListeners();
  }

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  void toggleIsSubmittingFile() {
    is_submitting_files = !is_submitting_files;
    notifyListeners();
  }

  // opens the gallery for the user to pick an image
  Future<void> pickPhotoFromGallery(int image_index) async {
    XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (image == null) return;

    if (image_index == 0) {
      selfie_photo = File(image.path);
    } else if (image_index == 1) {
      document_photo_1 = File(image.path);
    } else if (image_index == 2) {
      document_photo_2 = File(image.path);
    }

    notifyListeners();
  }

  // gets a list of verification requests
  Future<void> getVerficationRequests() async {
    verification_requests = await supabase
        .from("account_kyc_verification_requests")
        .select()
        .eq("user_id", box("user_id"))
        .order("created_at", ascending: false);

    if (verification_requests!.isNotEmpty) {
      current_verification_status = verification_requests![0]["status"];
    } else {
      current_verification_status = "";
    }

    notifyListeners();
  }

  // uploads and then submits the KYC photos
  Future<void> submitKycFiles() async {
    List<String>? image_urls = await uploadKycFiles();

    // creates a verification request containing the KYC photos
    await Future.wait([
      supabase.from("account_kyc_verification_requests").insert({
        "user_information": {
          "date_of_birth": box("date_of_birth"),
          "profile_image_url": box("country"),
          "physical_address": box("address"),
          "first_name": box("first_name"),
          "last_name": box("last_name"),
          "country": box("country"),
          "city": box("city"),
        },
        "identification_type": selected_document_type,
        "document_photo_2_url": image_urls![2],
        "document_photo_1_url": image_urls[1],
        "selfie_image_url": image_urls[0],
        "user_id": box("user_id"),
        "status": "Pending",
        "comment": "",
      }),
      sendVerificationNotificationToAdmins()
    ]);
  }

  // sends all app admins a verification notification alert
  Future<void> sendVerificationNotificationToAdmins() async {
    // gets the app's admin settings doc
    // DocumentSnapshot admin_doc =
    //     await _fire.collection("Admin").doc("Legal").get();

    // // stores the admin's user ids
    // List<dynamic> admin_user_ids =
    //     admin_doc.get("UsersCapableOfSeeingSecretDashboard");

    // List<String> list_notification_tokens = [];

    // for (int i = 0; i < admin_user_ids.length; i++) {
    //   // gets the current admin's account doc
    //   QuerySnapshot user_doc = await _fire
    //       .collection("Users")
    //       .where("UserID",
    //           isEqualTo:
    //               admin_doc.get("UsersCapableOfSeeingSecretDashboard")[i])
    //       .get();

    //   if (user_doc.docs.isNotEmpty) {
    //     list_notification_tokens.add(user_doc.docs[0].get("NotificationToken"));
    //   }
    // }

    // if (list_notification_tokens.isEmpty) return;

    // // sends all the app admins notifications
    // await sendNotifications({
    //   "body":
    //       "Jayben has received a new verification request. Please review it immediately.",
    //   "notification_tokens": list_notification_tokens,
    //   "title": "Verification Request Received",
    // });
  }

  // uploads the KYC photos to firebase and returns a list of urls
  Future<List<String>?> uploadKycFiles() async {
    List<File?> images = [selfie_photo, document_photo_1, document_photo_2];
    String document_photo_2_url = "";
    String document_photo_1_url = "";
    String selfie_photo_url = "";

    // uploads the images 1 by one
    for (int i = 0; i < images.length; i++) {
      if (images[i] != null) {
        //this gets the filename excluding the path
        final imageName = basename(images[i]!.path);

        //this defines where the image is stored on the server
        final destination = 'VerificationImages/$imageName';

        //task to upload the image
        UploadTask? task = uploadImageToFirebase(destination, images[i]!);

        if (task == null) return null;

        // logs the photo's upload progress
        task.snapshotEvents.listen((event) {
          upload_progress = event.bytesTransferred.toDouble() /
              event.totalBytes.toDouble() *
              100;

          print("upload progress is $upload_progress");

          notifyListeners();
        }).onError((error) {
          print("there was an error boss $error");
        });

        //returns a snapshot when upload is complete
        final snapshot = await task.whenComplete(() {});

        //gets the image url
        final imageUrl = await snapshot.ref.getDownloadURL();

        if (i == 0) {
          selfie_photo_url = imageUrl;
        } else if (i == 1) {
          document_photo_1_url = imageUrl;
        } else if (i == 2) {
          document_photo_2_url = imageUrl;
        }
      }

      // keeps track of files uploaded
      number_of_files_uploaded++;
    }

    // returns a list of the photo urls
    return [selfie_photo_url, document_photo_1_url, document_photo_2_url];
  }
}

class FeedProviderFunctions extends ChangeNotifier {
  TextEditingController comment_controller = TextEditingController();
  List<dynamic>? my_uploaded_contacts_without_jayben_accounts;
  List<dynamic>? my_uploaded_contacts_with_jayben_accs;
  List<dynamic>? selected_all_contacts_execpt;
  String? current_timeline_privacy_setting;
  List<dynamic>? selected_only_share_with;
  List<dynamic> liked_posts_post_ids = [];
  List<dynamic> my_phone_contacts = [];
  List<dynamic>? my_feed_transactions;
  List<dynamic>? feed_transactions;
  Stream<List<dynamic>?>? comments;
  int contacts_current_index = 0;
  bool hide_story_widget = false;
  bool is_loading = false;

  // ================== getters

  bool returnIsLoading() => is_loading;
  bool returnHideStoryWidget() => hide_story_widget;
  String? returnCurrentTimelinePrivacySetting() =>
      current_timeline_privacy_setting;
  List<dynamic>? returnMyContactsWithJaybenAccs() =>
      my_uploaded_contacts_with_jayben_accs;
  Stream<List<dynamic>?>? returnComments() => comments;
  List<dynamic> returnMyContacts() => my_phone_contacts;
  int returnContactsCurrentIndex() => contacts_current_index;
  List<dynamic>? returnMyFeedPosts() => my_feed_transactions;
  List<dynamic>? returnMyUploadedContactsWithoutJaybenAccs() =>
      my_uploaded_contacts_without_jayben_accounts;
  List<dynamic>? returnFeedTransactions() => feed_transactions;
  List<dynamic> returnLikedPostsPostIds() => liked_posts_post_ids;
  List<dynamic>? returnSelectedAllContactsExcept() =>
      selected_all_contacts_execpt;
  TextEditingController returnCommentController() => comment_controller;
  List<dynamic>? returnSelectedOnlyShareWith() => selected_only_share_with;

  // ================== setters

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  void toggleHideStoryWidget(bool state) {
    hide_story_widget = state;
    notifyListeners();
  }

  void changeContactsCurrentIndex(int index) {
    contacts_current_index = index;
    notifyListeners();
  }

  // adds 1 minute to the user's total time spent
  Future<void> updateTimeSpentInTimeline() async {
    // updates the user's row
    await supabase
        .rpc("increase_daily_user_minutes_spent_in_timeline", params: {
      "row_id": box("user_id"),
      "x": 1,
    });
  }

  // gets the user's posts
  Future<void> getFeedTransactions() async {
    try {
      feed_transactions = await supabase
          .from("timeline_posts")
          .select()
          .eq("user_id", box("user_id"))
          .neq("post_owner_user_id", box("user_id"))
          .order("created_at", ascending: false)
          .limit(100);
    } on Exception catch (_) {
      feed_transactions = await supabase
          .from("timeline_posts")
          .select()
          .eq("user_id", box("user_id"))
          .neq("post_owner_user_id", box("user_id"))
          .order("created_at", ascending: false);
    }

    // adds each liked post to local list of liked posts
    for (var i = 0; i < feed_transactions!.length; i++) {
      if (feed_transactions![i]["is_liked"]) {
        liked_posts_post_ids.add(feed_transactions![i]["post_id"]);
      }
    }

    notifyListeners();
  }

  // gets only the user's timeline posts they have made
  Future<void> getOnlyMyFeedTransactions() async {
    try {
      my_feed_transactions = await supabase
          .from("timeline_posts")
          .select()
          .eq("user_id", box("user_id"))
          .eq("post_owner_user_id", box("user_id"))
          .order("created_at", ascending: false)
          .limit(100);
    } on Exception catch (_) {
      my_feed_transactions = await supabase
          .from("timeline_posts")
          .select()
          .eq("user_id", box("user_id"))
          .eq("post_owner_user_id", box("user_id"))
          .order("created_at", ascending: false);
    }

    notifyListeners();
  }

  // adds the like from the user's timeline post copy
  // also adds the post_id from the local list of liked posts post ids
  Future<void> likePost(Map post_info) async {
    liked_posts_post_ids.add(post_info["post_id"]);

    notifyListeners();

    // marks post in user's timeline as liked
    await supabase
        .from("timeline_posts")
        .update({"is_liked": true, "number_of_likes": 1})
        .eq("user_id", box("user_id"))
        .eq("post_id", post_info["post_id"]);

    // gets a snapshot of the original post
    List<dynamic> original_post = await supabase
        .from("timeline_posts")
        .select()
        .eq("post_id", post_info["original_post_id"]);

    // stores the new number of the likes
    int new_like_count = original_post[0]["number_of_likes"] + 1;

    // increases like count for the original post
    await supabase.from("timeline_posts").update({
      "number_of_likes": new_like_count,
    }).eq("post_id", post_info["original_post_id"]);

    // creates a like record
    await supabase.from("liked_posts").insert({
      "profile_image_url": box("profile_image_url"),
      "post_id": post_info["original_post_id"],
      "first_name": box("first_name"),
      "last_name": box("last_name"),
      "user_id": box("user_id"),
    });
  }

  // removes the like from the user's timeline post copy
  // also removes the post_id from the local list of liked posts post ids
  Future<void> unLikePost(Map post_info) async {
    liked_posts_post_ids
        .removeWhere((element) => element == post_info["post_id"]);

    notifyListeners();

    // marks post in user's timeline not liked
    await supabase
        .from("timeline_posts")
        .update({"is_liked": false, "number_of_likes": 0})
        .eq("user_id", box("user_id"))
        .eq("post_id", post_info["post_id"]);

    // gets a snapshot of the original post
    List<dynamic> original_post = await supabase
        .from("timeline_posts")
        .select()
        .eq("post_id", post_info["original_post_id"]);

    // stores the new number of the likes
    int new_like_count = original_post[0]["number_of_likes"] - 1;

    // increases like count for the original post
    await supabase.from("timeline_posts").update({
      "number_of_likes": new_like_count,
    }).eq("post_id", post_info["original_post_id"]);

    // deletes a like record
    await supabase
        .from("liked_posts")
        .delete()
        .eq("post_id", post_info["original_post_id"])
        .eq("user_id", box("user_id"));
  }

  // blocks a person from the user's account
  Future<void> blockPerson(Map user_map) async {
    // gets a recent snapshot of the user's account row
    List<dynamic> user_row =
        await supabase.from("users").select().eq("user_id", box("user_id"));

    // adds the blocked person to the user's account
    await supabase.from("users").update({
      "blocked_peoples_user_details": [
        {
          "profile_image_url": user_map["profile_image_url"],
          "date_blocked": DateTime.now().toIso8601String(),
          "first_name": user_map["first_name"],
          "last_name": user_map["last_name"],
          "user_id": user_map["user_id"],
          "blocked_reason": "",
        },
        ...user_row[0]["blocked_peoples_user_details"],
      ]
    }).eq("user_id", box("user_id"));

    // stores the list of blocked people locally
    boxPut("blocked_peoples_user_details", [
      {
        "profile_image_url": user_map["profile_image_url"],
        "date_blocked": DateTime.now().toIso8601String(),
        "first_name": user_map["first_name"],
        "last_name": user_map["last_name"],
        "user_id": user_map["user_id"],
        "blocked_reason": "",
      },
      ...user_row[0]["blocked_peoples_user_details"],
    ]);
  }

  // creates a report record for a post
  Future<void> reportPost(Map report_map) async {
    await supabase.from("reported_posts").insert({
      "report_comment": report_map["report_info"]["report_comment"],
      "report_type": report_map["report_info"]["report_type"],
      "reporter_details": {
        "profile_image_url": box("profile_image_url"),
        "first_name": box("first_name"),
        "last_name": box("last_name"),
        "user_id": box("user_id"),
      },
      "post_id": report_map["post_info"]["post_id"],
      "admin_reviewer_details": null,
      "is_reviewed_by_admin": false,
      "admin_review_comment": "",
      "user_id": box("user_id"),
    });
  }

  // deletes an existing post from all timelines
  Future<void> deletePost(String post_id) async {
    // gets all the posts that are attached to the og post
    List<dynamic> posts_to_delete = await supabase
        .from("timeline_posts")
        .select()
        .eq("original_post_id", post_id);

    List<Future> delete_operations = [];

    // adds each post to delete operations
    for (var i = 0; i < posts_to_delete.length; i++) {
      delete_operations.add(
        supabase
            .from("timeline_posts")
            .delete()
            .eq("post_id", posts_to_delete[i]["post_id"]),
      );
    }

    // deletes the original post
    delete_operations.add(
      supabase.from("timeline_posts").delete().eq("post_id", post_id),
    );

    // runs all the delete operations
    await Future.wait(delete_operations);
  }

  // ================ timeline privacy functions

  // resets the locally stores value of the current timeline setting
  void clearCurrentTimelimePrivacySettings() {
    current_timeline_privacy_setting = null;
  }

  // gets the user's current timeline privacy setting
  Future<void> getCurrentTimelinePrivacySetting() async {
    List<dynamic> user_row =
        await supabase.from("users").select().eq("user_id", box("user_id"));

    current_timeline_privacy_setting = user_row[0]["timeline_privacy_setting"];

    notifyListeners();
  }

  // updates the user's current timeline privacy setting
  Future<void> updateCurrentTimelinePrivacySetting(String setting) async {
    await supabase.from("users").update(
        {"timeline_privacy_setting": setting}).eq("user_id", box("user_id"));
  }

  // gets the selected all_contacts_except contacts
  void getSelectedAllContactsExcept() {
    selected_all_contacts_execpt = my_uploaded_contacts_with_jayben_accs!
        .where((contact) => contact["include_to_all_contacts_except"] == true)
        .toList();

    notifyListeners();
  }

  // gets the selected only_share_with contacts
  void getSelectedOnlyShareWith() {
    selected_only_share_with = my_uploaded_contacts_with_jayben_accs!
        .where((contact) => contact["include_to_only_share_with"] == true)
        .toList();

    notifyListeners();
  }

  // adds and removes contacts from all contacts except
  Future<void> toggleSelectedAllContactsExcept(Map contact_map) async {
    if (!selected_all_contacts_execpt!.contains(contact_map)) {
      selected_all_contacts_execpt!.add(contact_map);
    } else {
      selected_all_contacts_execpt!
          .removeWhere((element) => element == contact_map);
    }

    notifyListeners();

    await supabase.from("contact_records").update({
      "include_to_all_contacts_except":
          selected_all_contacts_execpt!.contains(contact_map),
    }).eq("contact_id", contact_map["contact_id"]);
  }

  // adds and removes contacts from only share with
  Future<void> toggleSelectedOnlyShareWith(Map contact_map) async {
    if (!selected_only_share_with!.contains(contact_map)) {
      selected_only_share_with!.add(contact_map);
    } else {
      selected_only_share_with!
          .removeWhere((element) => element == contact_map);
    }

    notifyListeners();

    await supabase.from("contact_records").update({
      "include_to_only_share_with":
          selected_only_share_with!.contains(contact_map),
    }).eq("contact_id", contact_map["contact_id"]);
  }

  // ================ contacts functions

  // loads the locally stored contacts
  void loadLocallyStoredContacts() {
    my_uploaded_contacts_without_jayben_accounts =
        box("contacts_without_jayben_accounts");

    my_uploaded_contacts_with_jayben_accs =
        box("contacts_without_jayben_accounts");
  }

  // gets a list of the user's uploaded contacts
  Future<void> getUploadedContacts() async {
    loadLocallyStoredContacts();

    selected_all_contacts_execpt = null;
    selected_only_share_with = null;

    // gets all the user's uploaded contacts
    List<dynamic> results = await supabase
        .from("contact_records")
        .select()
        .eq("uploaders_user_id", box("user_id"));

    if (results.isNotEmpty) {
      // gets a list of contacts that have jayben accounts
      my_uploaded_contacts_with_jayben_accs = results
          .where((contact) => contact["is_jayben_user"] == true)
          .toList();

      // gets a list of contacts that don't have jayben accounts
      my_uploaded_contacts_without_jayben_accounts = results
          .where((contact) => contact["is_jayben_user"] == false)
          .toList();

      // Sorting the list of maps based on the 'contacts_display_name' key
      my_uploaded_contacts_without_jayben_accounts!.sort((a, b) {
        if (a['contacts_display_name'] != null &&
            b['contacts_display_name'] != null) {
          return (a['contacts_display_name'] as String)
              .compareTo(b['contacts_display_name'] as String);
        } else {
          return 0;
        }
      });

      // Sorting the list of maps based on the 'contacts_display_name' key
      my_uploaded_contacts_with_jayben_accs!.sort((a, b) {
        if (a['contacts_display_name'] != null &&
            b['contacts_display_name'] != null) {
          return (a['contacts_display_name'] as String)
              .compareTo(b['contacts_display_name'] as String);
        } else {
          return 0;
        }
      });

      boxPut(
          "ContactsWithJaybenAccounts", my_uploaded_contacts_with_jayben_accs);

      boxPut("contacts_without_jayben_accounts",
          my_uploaded_contacts_without_jayben_accounts);

      getSelectedAllContactsExcept();

      getSelectedOnlyShareWith();
    } else {
      my_uploaded_contacts_without_jayben_accounts = [];
      my_uploaded_contacts_with_jayben_accs = [];
    }

    notifyListeners();
  }

  // Get all contacts on device
  Future<void> getContactsFromPhone() async {
    if (box("contacts") != null) {
      my_phone_contacts = box("contacts");
    }

    try {
      await Permission.contacts.request();

      if (await Permission.contacts.request().isGranted) {
        // gets all the contacts from the device
        my_phone_contacts = await FastContacts.getAllContacts();

        // sends the contacts to server for processing
        await uploadContactsToServer(convertContactsToJson(my_phone_contacts)!);
      }
    } on Exception catch (_) {
      my_phone_contacts = box("contacts");
    }

    notifyListeners();
  }

  // converts the contacts of type Contact to json and returns the list of jsons
  List<Map<dynamic, dynamic>>? convertContactsToJson(
      List<dynamic>? raw_contacts) {
    if (raw_contacts == null) return null;

    // converts each Contact contact to a Map<dynamic, dynamic>
    List<Map<dynamic, dynamic>> contacts_converted_to_json = [];

    // converts each contact of type Contact to json
    for (Contact contact in raw_contacts) {
      if (contact.phones!.isNotEmpty && contact.phones != null) {
        contacts_converted_to_json.add(contact.toMap());
      }
    }

    return contacts_converted_to_json;
  }

  // uploads the contacts to supabase
  Future<void> uploadContactsToServer(
      List<Map<dynamic, dynamic>> raw_contacts) async {
    // gets the public supabase keys document
    // DocumentSnapshot supabase_keys = await _fire
    //     .collection("Admin")
    //     .doc("Legal")
    //     .collection("Supabase")
    //     .doc("keys")
    //     .get();

    // await http.post(
    //   Uri.parse(
    //       "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions"),
    //   headers: {
    //     "Authorization": "Bearer ${supabase_keys.get("anon_key")}",
    //     "Content-type": "application/json",
    //   },
    //   body: json.encode({
    //     "phone_number_to_verify_if_jayben_user": null,
    //     "request_type": "initiate_contacts_upload",
    //     "type_of_operation": "upload",
    //     "raw_contacts": raw_contacts,
    //     "user_id": box("user_id"),
    //   }),
    // );
  }
}

// converted to RLS
class VideoProviderFunctions extends ChangeNotifier {
  int videoPosition = 0;
  bool isLoading = false;
  bool vidIsPlaying = false;
  bool showActionButtons = true;

  // =========== returners

  bool returnIsLoading() => isLoading;
  bool returnVidIsPlaying() => vidIsPlaying;
  int returnVideoPosition() => videoPosition;
  bool returnShowActionButtons() => showActionButtons;

  // =========== getters

  void toggleisLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  // shows/hides the video player buttons
  void toggleShowActionButtons(bool state) {
    print("Tap is working boss");
    showActionButtons = state;
    notifyListeners();
  }

  // plays and pauses the video
  void playPauseVideo(VideoPlayerController? videoPlayerController) {
    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController.pause();
    } else if (!videoPlayerController.value.isPlaying) {
      videoPlayerController.play();
    }

    notifyListeners();
  }

  // allows user to change video position
  void changeVideoPosition(
      Duration newPosition, VideoPlayerController? vidController) {
    vidController!.seekTo(newPosition);
    notifyListeners();
  }

  // updates the video"s progress position
  void videoProgressListener(VideoPlayerController? vidController) {
    videoPosition = vidController!.value.position.inSeconds;
    notifyListeners();
  }
}

class MessageProviderFunctions extends ChangeNotifier {
  VideoPlayerController? videoPlayerController;
  Stream<List<dynamic>>? chatroom_row_stream;
  List<dynamic> messages_to_highlight = [];
  Stream<List<dynamic>>? messages_stream;
  List<dynamic> temporary_messages = [];
  List<String> mutedChatrooms = [];
  double mediaUploadProgress = 0;
  String tempMessageStorage = "";
  List<dynamic>? all_chatrooms;
  bool showMessageTemp = false;
  final picker = ImagePicker();
  bool showReplyBody = false;
  bool isLoading = false;
  XFile? pickedFile;

  // =========== returners

  bool returnIsLoading() => isLoading;
  bool returnIsReplyState() => showReplyBody;
  List<dynamic>? returnAllChatrooms() => all_chatrooms;
  List<String> returnMutedChatrooms() => mutedChatrooms;
  bool returnShowTempMessageyState() => showMessageTemp;
  List<Stream<List<dynamic>>?> returnMessagesStream() =>
      [messages_stream, chatroom_row_stream];
  File returnSelectedMediaFile() => File(pickedFile!.path);
  double returnMediaUploadProgress() => mediaUploadProgress;
  List<dynamic> returnTemporaryMessages() => temporary_messages;
  List<dynamic> returnMessagesToHighlight() => messages_to_highlight;
  List returnTempMessageVars() => [showMessageTemp, tempMessageStorage];
  VideoPlayerController? returnVideoPlayerController() => videoPlayerController;

  // =========== getters

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  // disposes any existing file data
  void nullifySelectedFile() {
    pickedFile = null;
    // notifyListeners();
  }

  void addRemoveToMessagesToHighlight(String message_id) {
    if (!messages_to_highlight.contains(message_id)) {
      messages_to_highlight.add(message_id);
    } else {
      messages_to_highlight.removeWhere((id) => id == message_id);
    }

    notifyListeners();
  }

  // Function to find the index of a message by its ID
  int getMessageIndexById(String messageId, messages) {
    return messages.indexWhere((message) => message['message_id'] == messageId);
  }

  // Function to scroll to a specific message by its ID
  void scrollToMessage(
      String messageId, messages, ScrollController scrollController) {
    int messageIndex = getMessageIndexById(messageId, messages);
    if (messageIndex != -1) {
      scrollController.animateTo(
        messageIndex * 80.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }

    addRemoveToMessagesToHighlight(messageId);

    Future.delayed(const Duration(milliseconds: 500),
        () => addRemoveToMessagesToHighlight(messageId));
  }

  // gets a stream of the chatrooms
  Future<void> getChatrooms() async {
    List<dynamic> results = [];

    List<dynamic> results_1 = await supabase
        .from("chatrooms")
        .select()
        .eq("is_active", true)
        .eq("first_member_user_id", box("user_id"))
        .order("created_at", ascending: false);

    List<dynamic> results_2 = await supabase
        .from("chatrooms")
        .select()
        .eq("is_active", true)
        .eq("second_member_user_id", box("user_id"))
        .order("created_at", ascending: false);

    results.addAll([...results_1, ...results_2]);

    all_chatrooms = results;

    notifyListeners();
  }

  // 1). Gets the chatroom's messages
  // 2). Gets the chatroom's row as a stream
  void getMessagesStream(String chatroom_id) {
    // 1).
    messages_stream = supabase
        .from("chatroom_messages")
        .stream(primaryKey: ["message_id"])
        .eq("chatroom_id", chatroom_id)
        .order("created_at", ascending: false);

    // 2).
    chatroom_row_stream = supabase
        .from("chatrooms")
        .stream(primaryKey: ["chatroom_id"]).eq("chatroom_id", chatroom_id);

    boxPut("show_temp_msg", false);
  }

  void getTemporaryMessages(String chatroom) {}

  void addTemporaryMessageBubble(Map temp_msg_map) {
    if (!temporary_messages.contains(temp_msg_map)) {
      temporary_messages.add(temp_msg_map);
      notifyListeners();
    }
  }

  // removes a temporary message from the list of chats
  void removeTemporaryMessageBubble(String temporary_message_id) {
    temporary_messages.removeWhere(
        (element) => element["temporary_message_id"] == temporary_message_id);
    notifyListeners();
  }

  // 1), Calls an api to send the message
  // 2). Gets member notification token and sends notifications
  Future<void> sendMessage(Map messageInfo) async {
    boxPut("show_temp_msg", true);
    tempMessageStorage = messageInfo["message_controller"].text;
    messageInfo["message_controller"].text = "";
    showMessageTemp = true;
    showReplyBody = false;
    notifyListeners();

    String temporary_message_id = id.v4();
    // String

    print(
        "The number of temp messages BEFORE is ${messageInfo["chatroom_id"]}");

    // shows a temporary message
    addTemporaryMessageBubble({
      "reply_message_details": {
        "reply_message_first_name": messageInfo["reply_message_first_name"],
        "reply_message_last_name": messageInfo["reply_message_last_name"],
        "reply_message_type": messageInfo["reply_message_type"],
        "reply_message_uid": messageInfo["reply_message_uid"],
        "reply_message_id": messageInfo["reply_message_id"],
        "reply_message_thumbnail_url":
            messageInfo["reply_message_thumbnail_url"],
        "reply_message": messageInfo["reply_message"],
        "reply_caption": messageInfo["reply_caption"],
      },
      "other_person_user_id": messageInfo["other_person_user_id"],
      "message_details": {
        "message_extension": messageInfo["message_extension"],
        "message_type": messageInfo["message_type"],
        "caption": messageInfo["caption"],
        "message": tempMessageStorage,
        "thumbnail_url": null,
        "aspect_ratio": null,
        "media_url": null,
      },
      "profile_image_url": box("profile_image_url"),
      "temporary_message_id": temporary_message_id,
      "message_type": messageInfo["message_type"],
      "chatroom_id": messageInfo["chatroom_id"],
      "last_message": tempMessageStorage,
      "first_name": box("first_name"),
      "last_name": box("last_name"),
      "user_id": box("user_id"),
    });

    print("The number of temp messages AFTER is ${temporary_messages.length}");

    // Sends the messgae to the chatroom
    try {
      await supabase.functions.invoke('send_chatroom_message_v1', body: {
        "reply_message_details": {
          "reply_message_first_name": messageInfo["reply_message_first_name"],
          "reply_message_last_name": messageInfo["reply_message_last_name"],
          "reply_message_type": messageInfo["reply_message_type"],
          "reply_message_uid": messageInfo["reply_message_uid"],
          "reply_message_id": messageInfo["reply_message_id"],
          "reply_message_thumbnail_url":
              messageInfo["reply_message_thumbnail_url"],
          "reply_message": tempMessageStorage,
          "reply_caption": messageInfo["reply_caption"],
        },
        "other_person_user_id": messageInfo["other_person_user_id"],
        "message_details": {
          "message_extension": messageInfo["message_extension"],
          "message_type": messageInfo["message_type"],
          "caption": tempMessageStorage,
          "thumbnail_url": null,
          "aspect_ratio": null,
          "media_url": null,
        },
        "profile_image_url": box("profile_image_url"),
        "message_type": messageInfo["message_type"],
        "last_message": tempMessageStorage,
        "first_name": box("first_name"),
        "last_name": box("last_name"),
        "user_id": box("user_id"),
      });
    } on FunctionException catch (e) {
      print("There was an error boss: $e");
    }

    // plays sent message sound
    // await playSound('sent-message.wav');

    // shows a temporary message
    removeTemporaryMessageBubble(temporary_message_id);
  }

  // sends a message that has a photo or video
  Future<void> sendMediaMessage(Map messageInfo) async {
    boxPut("show_temp_msg", true);
    tempMessageStorage = messageInfo["caption_controller"].text;
    messageInfo["caption_controller"].text = "";
    showMessageTemp = true;
    showReplyBody = false;
    notifyListeners();

    // uploads the media files to firebase
    // then returns a media url and thumbnail url
    // element 0 is the media url & element 1 is the thumbnail url
    List<String>? urls =
        await uploadMediasAndGetUrls(messageInfo["message_type"]);

    // Sends the messgae to the chatroom
    await supabase.functions.invoke('send_chatroom_message_v1', body: {
      "reply_message_details": {
        "reply_message_thumbnail_url": box("reply_sent_by_thumbnail_url") ?? '',
        "reply_message_first_name": box("reply_sent_by_first_name") ?? '',
        "reply_message_last_name": box("reply_sent_by_last_name") ?? '',
        "reply_message_id": messageInfo["reply_message_id"],
        "reply_message_type": box("reply_message_type") ?? '',
        "reply_message_uid": box("reply_sent_by_uid") ?? '',
        "reply_message": box("reply_message") ?? '',
        "reply_caption": box("reply_caption") ?? '',
      },
      "other_person_user_id": messageInfo["other_person_user_id"],
      "message_details": {
        "message_extension": messageInfo["message_extension"],
        "message_type": messageInfo["message_type"],
        "aspect_ratio": messageInfo["aspect_ratio"],
        "caption": tempMessageStorage,
        "thumbnail_url": urls[1],
        "media_url": urls[0],
        "message": urls[1],
      },
      "message_type": messageInfo["message_type"],
      "profile_image_url": box("profile_image_url"),
      "last_message": tempMessageStorage,
      "first_name": box("first_name"),
      "last_name": box("last_name"),
      "user_id": box("user_id"),
    });
  }

  // controls the video state when creating a post
  // when user exits app (pauses video) and resumes (plays video)
  void playPauseVideo(BuildContext context, AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (videoPlayerController == null) return;

        break;

      case AppLifecycleState.inactive:
        if (videoPlayerController == null) return;
        videoPlayerController!.pause();
        break;

      case AppLifecycleState.paused:
        if (videoPlayerController == null) return;
        videoPlayerController!.pause();
        break;

      case AppLifecycleState.detached:
        if (videoPlayerController == null) return;
        videoPlayerController!.pause();
        break;
    }
  }

  // initializes the video in create media message page
  void initializeVideo(File mediaFile) async {
    videoPlayerController = VideoPlayerController.file(mediaFile)
      ..initialize().then((_) {
        notifyListeners();
      })
      ..setLooping(true);

    isLoading = false;
  }

  // opens gallery for user to pick video or photo
  // then routes the user to the create post page
  void getMedia(BuildContext context, Map groupInfo) async {
    if (groupInfo['media_type'] == "Photo") {
      pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (pickedFile != null) {
        double? aspectRatio = 0.0;

        // gets the aspect ratio of the image selected
        aspectRatio = await computeAspectRatio(File(pickedFile!.path));

        changePage(
          context,
          CreateMediaMessagePage(
            mediaType: "Photo",
            groupInfo: groupInfo,
            aspectRatio: aspectRatio,
            mediaFile: File(pickedFile!.path),
          ),
        );
      }
      return;
    }

    pickedFile = await picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(minutes: 180));

    if (pickedFile != null) {
      double aspectRatio = 0.0;

      // creates a thumbnail file from the seleted video
      // then returns the path of the photo locally
      var thumbnailPath = await getThumbnailPath(File(pickedFile!.path).path);

      // gets the aspect ratio of the thumbnail
      aspectRatio = await computeAspectRatio(File(thumbnailPath));

      changePage(
        context,
        CreateMediaMessagePage(
          mediaType: "Video",
          groupInfo: groupInfo,
          aspectRatio: aspectRatio,
          mediaFile: File(pickedFile!.path),
        ),
      );
    }
  }

  // this removes the temporary message bubble in chats
  // the temp bubble shows a preview of the message being sent
  // then later disappears when the message has been sent success
  void removeTemporaryMessage() {
    showMessageTemp = false;
    tempMessageStorage = "";
    boxDelete("reply_message");
    boxDelete("reply_caption");
    boxDelete("reply_messageID");
    boxDelete("reply_sent_by_uid");
    boxPut("show_temp_msg", false);
    boxDelete("reply_message_type");
    boxDelete("reply_sent_by_last_name");
    boxDelete("reply_sent_by_first_name");
    boxDelete("reply_sent_by_thumbnail_url");

    notifyListeners();
  }

  // Stores the reply message info locally
  void setReplyValue(Map messageInfo) {
    // dismisses keybaord
    hideKeyboard();

    // shows the reply widget
    showReplyBody = true;

    // stores the reply details locally
    boxPut("reply_sent_by_uid", messageInfo["user_id"]);
    boxPut("reply_message_id", messageInfo["message_id"]);
    boxPut("reply_message", messageInfo["message_details"]["message"]);
    boxPut("reply_caption", messageInfo["message_details"]["caption"]);
    boxPut("reply_sent_by_thumbnail_url",
        messageInfo["message_details"]["message"]);
    boxPut(
        "reply_sent_by_last_name", messageInfo["sender_details"]["first_name"]);
    boxPut(
        "reply_sent_by_first_name", messageInfo["sender_details"]["last_name"]);
    boxPut(
        "reply_message_type", messageInfo["message_details"]["message_type"]);
    notifyListeners();
  }

  // clears the reply message info stored locally
  void removeReplyWidget() {
    showReplyBody = false;
    boxDelete("reply_message");
    boxDelete("reply_caption");
    boxDelete("reply_sent_by_uid");
    boxDelete("reply_message_type");
    boxDelete("reply_sent_by_last_name");
    boxDelete("reply_sent_by_first_name");
    boxDelete("reply_sent_by_thumbnail_url");

    notifyListeners();
  }

  // 1). Uploads the media files to supabase and gets a media url
  // 2). Uploads the video thumbnail file and gets a thumbnail url
  // 3). Returns a List<String> containing the mediaUrl & thumbnail url
  Future<List<String>> uploadMediasAndGetUrls(String mediaType) async {
    String thumbnailUrl = "";
    String mediaUrl = "";

    // 1).
    // mediaUrl = await uploadFileToFirebase(
    //     mediaType == "Video" ? "group-chat-videos" : "group-chat-photos",
    //     basename(pickedFile!.path),
    //     File(pickedFile!.path));

    // // 2).
    // if (mediaType == "Video") {
    //   var thumbnailPath = await getThumbnailPath(pickedFile!.path);

    //   thumbnailUrl = await uploadFileToSupabase("home-feed-videos-thumbnails",
    //       basename(thumbnailPath), File(thumbnailPath));
    // }

    // // assings the media url to the thumbnail url
    // if (mediaType == "Photo") {
    //   thumbnailUrl = mediaUrl;
    // }

    // 3).
    return [mediaUrl, thumbnailUrl];
  }
}

// converted to RLS
class AttachProviderFunctions extends ChangeNotifier {
  VideoPlayerController? video_player_controller;
  bool video_is_initialized = false;
  final picker = ImagePicker();
  File? picked_video_thumbnail;
  num upload_progress = 0.0;
  double aspect_ratio = 0.0;
  bool is_loading = false;
  File? selected_media;
  File? picked_photo;

  // ================== getters

  bool returnIsLoading() => is_loading;
  double returnAspectRatio() => aspect_ratio;
  File? returnSelectedMedia() => selected_media;
  num returnUploadProgress() => upload_progress;
  File? returnThumbnailFile() => picked_video_thumbnail;
  bool returnVideoIsInitialized() => video_is_initialized;
  VideoPlayerController? returnVideoPlayerController() =>
      video_player_controller;

  // ================== setters

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  // initializes the video in create post page
  void initializeVideo(File mediaFile) async {
    video_player_controller = VideoPlayerController.file(mediaFile)
      ..initialize().then((_) {
        notifyListeners();
      })
      ..setLooping(true);

    is_loading = false;
  }

  // 1). opens galley for user to pick a video
  // 2). Creates a thumbnail and gets its path
  // 3). Computes the thumbnail"s aspect ratio
  // 4). Routes user to the upload sermon page
  Future<void> getMediaP2P(BuildContext context, Map transaction_info) async {
    if (transaction_info["media_type"] == "photo") {
      XFile? picked_file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

      if (picked_file == null) return;

      double? aspect_ratio = 0.0;

      selected_media = File(picked_file.path);

      // gets the aspect ratio of the image selected
      aspect_ratio = await computeAspectRatio(selected_media!);

      // routes user to the
      changePage(
        context,
        AttachMediaPage(transaction_info: {
          "media_type": transaction_info["media_type"],
          "aspect_ratio": aspect_ratio,
          ...transaction_info
        }),
      );

      return;
    }

    // 1).
    XFile? picked_video = await picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(minutes: 30));

    if (picked_video == null) return;

    selected_media = File(picked_video.path);

    // 2).
    // creates a thumbnail file from the seleted video
    // then returns the path of the photo locally
    String thumbnail_path = await getThumbnailPath(selected_media!.path);

    picked_video_thumbnail = File(thumbnail_path);

    // 3). gets the aspect ratio of the thumbnail
    aspect_ratio = await computeAspectRatio(picked_video_thumbnail!);

    // routes user to the
    changePage(
      context,
      AttachMediaPage(transaction_info: {
        "aspect_ratio": aspect_ratio,
        "media_type": transaction_info["media_type"],
        ...transaction_info
      }),
    );
  }

  // uploads media files to firebase
  // then creates a supabase document for the post
  Future<void> addCashToSavingsWithMedia(
    BuildContext context,
    Map transfer_info,
  ) async {
    // uploads the media files to firebase
    // then returns a media url and thumbnail url
    List<String>? urls = await uploadMedia(transfer_info["media_type"]);

    Map<String, dynamic> res =
        await callGeneralFunction("add_money_to_shared_nas_account", {
      "post_is_public": box("default_transaction_visibility") == "Public",
      "media_details": [
        {
          "aspect_ratio": transfer_info['aspect_ratio'],
          "media_type": transfer_info['media_type'],
          "media_caption": transfer_info['comment'],
          "post_type": transfer_info['media_type'],
          "thumbnail_url": urls![1],
          "media_url": urls[0],
        }
      ],
      "account_id": transfer_info["transfer_info"]["accountID"],
      "amount": transfer_info["transfer_info"]["amount"],
      "comment": transfer_info['comment'],
    });

    if (res["data"].data.status == 'success') {
      // tells user post has successfully been created
      showSnackBar(context, "Post has been created successfully",
          color: Colors.grey[700]!);

      // routes user back to home page
      changePage(context, const HomePage(), type: "pr");

      if (!video_is_initialized) return;

      // dispose the vid player controller
      video_player_controller!.dispose();
    } else {
      // tells user post has successfully been created
      showSnackBar(context, "An error occured, please try again later.",
          color: Colors.grey[700]!);
    }
  }

  // uploads media files to firebase
  // then creates a supabase document for the post
  Future<bool> sendP2PWithMedia(BuildContext context, Map postInfo) async {
    // uploads the media files to firebase
    // then returns a media url and thumbnail url
    List<String>? urls = await uploadMedia(postInfo["media_type"]);

    Map<String, dynamic> res = await callGeneralFunction("send_money_p2p", {
      "post_is_public": box("default_transaction_visibility") == "Public",
      "receiver_user_id": postInfo["payment_info"]["receiver_map"]["user_id"],
      "amount": postInfo["payment_info"]["amount"],
      "media_details": [
        {
          "aspect_ratio": postInfo['aspect_ratio'],
          "media_type": postInfo['media_type'],
          "media_caption": postInfo['comment'],
          "post_type": postInfo['media_type'],
          "thumbnail_url": urls![1],
          "media_url": urls[0],
        }
      ],
      "comment": postInfo['comment'],
    });

    bool is_sent = res["data"].data.status == "success";

    if (!is_sent) {
      showSnackBar(context, "Transfer failed. Please try again.",
          color: Colors.red[700]!);

      return false;
    }

    // tells user post has successfully been created
    showSnackBar(context, "Transfer successfully", color: Colors.grey[700]!);

    // routes user back to home page
    changePage(context, const HomePage(), type: "pr");

    if (!video_is_initialized) return false;

    // dispose the vid player controller
    video_player_controller!.dispose();
    return true;
  }

  // uploads the file and returns a list of the urls
  Future<List<String>?> uploadMedia(String media_type) async {
    String? thumbnailUrl = "";
    String? mediaUrl = "";

    // uploads the photo or the video files
    mediaUrl = await uploadFileAndGetUrl({
      "destination": media_type == "photo" ? "FeedPhotos" : "FeedVideos",
      "file": File(selected_media!.path),
    });

    // only if a video, uploads the thumbnail
    if (media_type == "video") {
      // gets the thumbnail file's url
      String thumbnailPath = await getThumbnailPath(selected_media!.path);

      // uploads the thumbnail file
      thumbnailUrl = await uploadFileAndGetUrl({
        "destination": "FeedVideoThumbnails",
        "file": File(thumbnailPath),
      });
    }

    return [mediaUrl!, thumbnailUrl!];
  }

  // 1). Uploads the media files to supabase and gets a media url
  // 2). Uploads the video thumbnail file and gets a thumbnail url
  // 3). Returns a List<String> containing the mediaUrl & thumbnail url
  Future<String?> uploadFileAndGetUrl(Map upload_info) async {
    //this gets the filename excluding the path
    final imageName = basename(upload_info["file"]!.path);

    //this defines where the image is stored on the server
    final destination = '${upload_info["destination"]}/$imageName';

    //task to upload the image
    UploadTask? task = uploadImageToFirebase(destination, upload_info["file"]!);

    if (task == null) return null;

    // logs the photo's upload progress
    task.snapshotEvents.listen((event) {
      upload_progress =
          event.bytesTransferred.toDouble() / event.totalBytes.toDouble() * 100;

      print("upload progress is $upload_progress");

      notifyListeners();
    }).onError((error) {
      print("there was an error boss $error");
    });

    //returns a snapshot when upload is complete
    final snapshot = await task.whenComplete(() {});

    //gets the image url
    String file_url = await snapshot.ref.getDownloadURL();

    // 3).
    return file_url;
  }
}

class AdminProviderFunctions extends ChangeNotifier {
  double total_amount_saved_in_personal_nas_accs_today_so_far = 0;
  double total_amount_of_user_money_in_our_possession = 0;
  int number_of_transactions_processed_today_so_far = 0;
  double total_amount_in_active_shared_nas_accounts = 0;
  int number_of_transfers_to_personal_nas_accounts = 0;
  int number_of_active_funded_shared_nas_accounts = 0;
  int total_number_of_transactions_processed_ever = 0;
  int number_of_monthly_active_users_today_so_far = 0;
  int number_of_daily_active_users_today_so_far = 0;
  double total_amount_in_personal_nas_accounts = 0;
  double total_amount_withdrawn_today_so_far = 0;
  int number_of_active_personal_nas_accounts = 0;
  String current_withdrawal_receiver_number = "";
  // QuerySnapshot? pending_transactions_firebase;
  int number_of_new_users_in_last_30_days = 0;
  // QuerySnapshot? all_transactions_firebase;
  // DocumentSnapshot? admin_metrics_document;
  double total_amount_ever_deposited = 0;
  int number_of_pending_withdrawals = 0;
  List<dynamic>? verification_requests;
  List<dynamic>? pending_transactions;
  int number_of_registered_users = 0;
  double total_amount_in_wallets = 0;
  List<dynamic>? all_transactions;
  int weekly_active_users = 0;
  bool is_loading = false;

  // ============ getters

  bool returnIsLoading() => is_loading;
  String returnCurrenWIthdrawalReceiverNumber() =>
      current_withdrawal_receiver_number;
  int returnWeeklyActiveUsers() => weekly_active_users;
  List<dynamic>? returnAllTransactions() => all_transactions;
  double returnTotalAmountInWallets() => total_amount_in_wallets;
  int returnNumberOfRegisteredUsers() => number_of_registered_users;
  List<dynamic>? returnPendingTransactions() => pending_transactions;
  List<dynamic>? returnVerificationRequests() => verification_requests;
  int returnNumberOfPendingWithdraws() => number_of_pending_withdrawals;
  double returnTotalAmountEverDeposited() => total_amount_ever_deposited;
  // DocumentSnapshot? returnAdminMetricsDocument() => admin_metrics_document;
  // QuerySnapshot? returnAllTransactionsFirebase() => all_transactions_firebase;
  double returnTotalAmountInActiveSharedAccounts() =>
      total_amount_in_active_shared_nas_accounts;
  int returnNumberOfActiveFundedSharedNasAccounts() =>
      number_of_active_funded_shared_nas_accounts;
  int returnNumberOfActivePersonalNasAccs() =>
      number_of_active_personal_nas_accounts;
  int returnNumberOfDailyActiveUsersTodaySoFar() =>
      number_of_daily_active_users_today_so_far;
  int returnNumberOfNewUsersInLast30Days() =>
      number_of_new_users_in_last_30_days;
  int returnNumberOfMonthlyActiveUsersTodaySoFar() =>
      number_of_monthly_active_users_today_so_far;
  int returnNumberOfTransfersToPersonalNasAccs() =>
      number_of_transfers_to_personal_nas_accounts;
  int returnTotalNumberOfTransactionsProcessedEver() =>
      total_number_of_transactions_processed_ever;
  int returnNumberOfTransactionsProcessedToday() =>
      number_of_transactions_processed_today_so_far;
  double returnTotalAmountInPersonalNasAccs() =>
      total_amount_in_personal_nas_accounts;
  double returnTotalAmountWithdrawnTodaySoFar() =>
      total_amount_withdrawn_today_so_far;
  double returnTotalAmountSavedInPersonalNasAccsTodaySoFar() =>
      total_amount_saved_in_personal_nas_accs_today_so_far;
  double returnTotalAmountOfUserMoneyInOurPossession() =>
      total_amount_of_user_money_in_our_possession;
  // QuerySnapshot? returnPendingTransactionsFirebase() =>
  //     pending_transactions_firebase;

  // ============ setters

  void resetSettings() {
    is_loading = false;
  }

  Future<void> migrateFirebaseTransactionsToSupabase() async {
    // gets all transaction starting from 03rd June 2023 til date
    // QuerySnapshot transactions = await _fire
    //     .collection("Transactions")
    //     .orderBy("DateCreated", descending: true)
    //     .endBefore([DateTime(2023, 06, 03)]).get();

    // print("There are ${transactions.docs.length} documents");

    List<Future> operations = [];

    // for each transaction
    // for (var i = 0; i < transactions.docs.length; i++) {
    //   // adds each transaction and
    //   operations
    //       .add(copyTransactionToSupabase(transactions.docs[i].data() as Map));

    //   print("Transaction ${i + 1} has been added to list of operations");
    // }

    print("Now running all the operations all at once sir");

    // runs all the api calls all at the same time
    await Future.wait(operations);

    print("DOOOOONE running all the operations all at once sir");
  }

  Future<void> copyTransactionToSupabase(Map user_data) async {
    // gets the transaction owner's document
    // DocumentSnapshot transaction_owner_doc =
    //     await _fire.collection("Users").doc(user_data["UserID"]).get();

    String tranx_type = user_data["TransactionType"];
    String sent_received = user_data["SentReceived"];
    String method = user_data["Method"];

    if (tranx_type == "Withdrawal") {
      // when user is moving money from Jayben wallet to their bank account/mobile money account

      // double amount =
      //     double.parse(transaction_owner_doc.get("Balance").toString()) -
      //         double.parse(user_data["Amount"].toString());

      await callSupabaseAPI({
        "request_type": "Withdrawal Transaction: To Bank, Mobile money",
        "data": {
          "is_public": false,
          "country": "Zambia",
          "number_of_views": 0,
          "number_of_likes": 0,
          "number_of_replies": 0,
          "currency_symbol": "K",
          "deposit_details": null,
          "user_is_verified": false,
          "created_at": user_data["DateCreated"].toDate().toIso8601String(),
          "amount": user_data["Amount"],
          "status": user_data["Status"],
          "p2p_sender_details": null,
          "method": user_data["Method"],
          "user_id": user_data["UserID"],
          "comment": user_data["Comment"],
          "p2p_recipient_details": null,
          "currency": user_data["Currency"],
          "savings_account_details": null,
          "full_names": user_data["FullNames"],
          "withdrawal_details": {
            "bank_branch": "",
            "bank_address": "",
            "bank_sort_code": "",
            "bank_swift_code": "",
            "bank_country": "Zambia",
            "bank_routing_number": "",
            "bank_name": user_data["WithdrawInfo"]["BankName"],
            "bank_account_holder_name": user_data["FullNames"],
            "phone_number": user_data["WithdrawInfo"]["PhoneNumber"],
            "final_withdraw_amount": user_data["WithdrawInfo"]["AmountPlusfee"],
            "picked_withdraw_method": user_data["WithdrawInfo"]
                ["PaymentMethod"],
            "bank_account_number": user_data["WithdrawInfo"]
                ["BankAccountNumber"],
            "withdraw_amount_plus_fee": user_data["WithdrawInfo"]
                ["AmountPlusfee"],
            "withdraw_amount_minus_fee": user_data["WithdrawInfo"]
                ["AmountBeforeFee"],
          },
          "attended_to": user_data["AttendedTo"],
          "description": user_data["PhoneNumber"],
          "sent_received": user_data["SentReceived"],
          "transaction_id": user_data["TransactionID"],
          "transaction_type": user_data["TransactionType"],
          "transaction_fee_details": {
            "transaction_international_bank_tranfer_fee":
                user_data["WithdrawInfo"]["IntlBankTransferFee"],
            "transaction_local_bank_tranfer_fee": user_data["WithdrawInfo"]
                ["LocalBankTransferFee"],
            "transaction_total_fee_percentage": user_data["WithdrawInfo"]
                ["agent_payments_withdraw_fee_percent"],
            "transaction_fee_amount": user_data["WithdrawInfo"]["TotalFee"],
            "transaction_total_fee_currency": user_data["Currency"],
            "transcation_bank_transfer_fee_currency": "USD",
          },
          "wallet_balance_details": {
            // "wallet_balance_before_transaction": amount,
            // "wallet_balance_after_transaction":
            //     transaction_owner_doc.get("Balance"),
            "wallet_balances_difference": user_data["Amount"],
          },
        },
      }, "Withdrawal - from jayben wallet to bank or mobile money");
    } else if (tranx_type == "Savings Transfer") {
      // when user is moving money from Jayben wallet to a no access savings account

      double savings_account_before_transation = double.parse(
          user_data["SavingsAccount"]["AccountBalanceBeforeDeposit"]
              .toString());

      double savings_account_after_transaction =
          double.parse(savings_account_before_transation.toString()) +
              double.parse(user_data["Amount"].toString());

      // gets the savings account document
      // var savings_account_document = await _fire
      //     .collection("Saving Accounts")
      //     .doc(user_data["SavingsAccount"]["AccountID"])
      //     .get();

      // double amount =
      //     double.parse(transaction_owner_doc.get("Balance").toString()) -
      //         double.parse(user_data["Amount"].toString());

      await callSupabaseAPI({
        "request_type":
            "Savings Transfer Transaction: To No access savings account",
        "data": {
          "is_public": true,
          "country": "Zambia",
          "number_of_views": 0,
          "number_of_likes": 0,
          "number_of_replies": 0,
          "currency_symbol": "K",
          "deposit_details": null,
          "user_is_verified": false,
          "created_at": user_data["DateCreated"].toDate().toIso8601String(),
          "amount": user_data["Amount"],
          "status": user_data["Status"],
          "withdrawal_details": null,
          "method": user_data["Method"],
          "p2p_sender_details": null,
          "user_id": user_data["UserID"],
          "comment": user_data["Comment"],
          "p2p_recipient_details": null,
          "currency": user_data["Currency"],
          "transaction_fee_details": null,
          "full_names": user_data["FullNames"],
          "attended_to": user_data["AttendedTo"],
          "description": user_data["PhoneNumber"],
          "sent_received": user_data["SentReceived"],
          "transaction_id": user_data["TransactionID"],
          "transaction_type": user_data["TransactionType"],
          "savings_account_details": {
            "savings_account_id": user_data["SavingsAccount"]["AccountID"],
            "savings_account_name": user_data["SavingsAccount"]["AccountName"],
            "savings_account_type": user_data["SavingsAccount"]["AccountType"],
            // "savings_account_days_left":
            //     savings_account_document.get("DaysLeft"),
            "savings_account_balance_after_transaction":
                savings_account_after_transaction,
            "savings_account_balance_before_transaction":
                savings_account_before_transation,
          },
          "wallet_balance_details": {
            // "wallet_balance_before_transaction": amount,
            // "wallet_balance_after_transaction":
            //     transaction_owner_doc.get("Balance"),
            "wallet_balances_difference": user_data["Amount"],
          },
        },
      }, "Savings transfer - from jayben wallet to NAS account");
    } else if (tranx_type == "Transfer") {
      // when moving money from one Jayben Wallet to another Jayben Wallet

      if (sent_received == "Received") {
        // gets the sender's user document
        // var sender_doc = await _fire
        //     .collection("Users")
        //     .doc(user_data["sender"]["UserID"])
        //     .get();

        // double amount =
        //     double.parse(transaction_owner_doc.get("Balance").toString()) -
        //         double.parse(user_data["Amount"].toString());

        // double sender_amount =
        //     double.parse(sender_doc.get("Balance").toString()) +
        //         double.parse(user_data["Amount"].toString());

        // creates the receiver's transaction row in supabase
        await callSupabaseAPI({
          "request_type": "Transfer Transaction: Sender",
          "data": {
            "is_public": true,
            "country": "Zambia",
            "number_of_views": 0,
            "number_of_likes": 0,
            "number_of_replies": 0,
            "currency_symbol": "K",
            "deposit_details": null,
            "user_is_verified": false,
            "created_at": user_data["DateCreated"].toDate().toIso8601String(),
            "amount": user_data["Amount"],
            "status": user_data["Status"],
            "withdrawal_details": null,
            "method": user_data["Method"],
            "user_id": user_data["UserID"],
            "comment": user_data["Comment"],
            "p2p_recipient_details": null,
            "currency": user_data["Currency"],
            "savings_account_details": null,
            "transaction_fee_details": null,
            "full_names": user_data["FullNames"],
            "attended_to": user_data["AttendedTo"],
            "description": user_data["PhoneNumber"],
            "sent_received": user_data["SentReceived"],
            "transaction_id": user_data["TransactionID"],
            "transaction_type": user_data["TransactionType"],
            "p2p_sender_details": {
              "user_id": user_data["sender"]["UserID"],
              "full_names": user_data["sender"]["FullNames"],
              "phone_number": user_data["sender"]["PhoneNumber"],
              // "senders_wallet_balance_after_transaction":
              //     sender_doc.get("Balance"),
              // "senders_wallet_balance_before_transaction": sender_amount,
            },
            "wallet_balance_details": {
              // "wallet_balance_before_transaction": amount,
              // "wallet_balance_after_transaction":
              //     transaction_owner_doc.get("Balance"),
              "wallet_balances_difference": user_data["Amount"],
            },
          },
        }, "Transfer - jayben wallet to jayben wallet");
      } else {
        // gets the receiver's user document
        // var receiver_doc = await _fire
        //     .collection("Users")
        //     .doc(user_data["sender"]["UserID"])
        //     .get();

        // double amount = double.parse(receiver_doc.get("Balance").toString()) +
        //     double.parse(user_data["Amount"].toString());

        await callSupabaseAPI({
          "request_type": "Transfer Transaction: Receiver",
          "data": {
            "is_public": true,
            "country": "Zambia",
            "number_of_views": 0,
            "number_of_likes": 0,
            "currency_symbol": "K",
            "number_of_replies": 0,
            "deposit_details": null,
            "user_is_verified": false,
            "created_at": user_data["DateCreated"].toDate().toIso8601String(),
            "amount": user_data["Amount"],
            "status": user_data["Status"],
            "withdrawal_details": null,
            "method": user_data["Method"],
            "p2p_sender_details": null,
            "user_id": user_data["UserID"],
            "comment": user_data["Comment"],
            "currency": user_data["Currency"],
            "savings_account_details": null,
            "transaction_fee_details": null,
            "full_names": user_data["FullNames"],
            "attended_to": user_data["AttendedTo"],
            "description": user_data["PhoneNumber"],
            "sent_received": user_data["SentReceived"],
            "transaction_id": user_data["TransactionID"],
            "transaction_type": user_data["TransactionType"],
            "p2p_recipient_details": {
              "user_id": user_data["receiver"]["UserID"],
              "full_names": user_data["receiver"]["FullNames"],
              "phone_number": user_data["receiver"]["PhoneNumber"],
              // "recipient_wallet_balance_after_transaction":
              //     receiver_doc.get("Balance"),
              // "recipient_wallet_balance_before_transaction": amount,
            },
            "wallet_balance_details": {
              // "wallet_balance_before_transaction": amount,
              // "wallet_balance_after_transaction":
              //     transaction_owner_doc.get("Balance"),
              "wallet_balances_difference": user_data["Amount"],
            },
          },
        }, "Transfer - jayben wallet to jayben wallet");
      }
    } else if (tranx_type == "Deposit" && method == "From No Access Savings") {
      // when money is moving from a no access savings account to a Jayben wallet

      // double amount =
      //     double.parse(transaction_owner_doc.get("Balance").toString()) -
      //         double.parse(user_data["Amount"].toString());

      await callSupabaseAPI({
        "request_type": "Deposit Transaction: No access savings account",
        "data": {
          "is_public": false,
          "country": "Zambia",
          "number_of_views": 0,
          "number_of_likes": 0,
          "number_of_replies": 0,
          "currency_symbol": "K",
          "deposit_details": null,
          "user_is_verified": false,
          "created_at": user_data["DateCreated"].toDate().toIso8601String(),
          "amount": user_data["Amount"],
          "status": user_data["Status"],
          "withdrawal_details": null,
          "method": user_data["Method"],
          "user_id": user_data["UserID"],
          "comment": user_data["Comment"],
          "p2p_recipient_details": null,
          "currency": user_data["Currency"],
          "savings_account_details": null,
          "transaction_fee_details": null,
          "full_names": user_data["FullNames"],
          "attended_to": user_data["AttendedTo"],
          "description": user_data["PhoneNumber"],
          "sent_received": user_data["SentReceived"],
          "transaction_id": user_data["TransactionID"],
          "transaction_type": user_data["TransactionType"],
          "p2p_sender_details": null,
          "wallet_balance_details": {
            // "wallet_balance_before_transaction": amount,
            // "wallet_balance_after_transaction":
            //     transaction_owner_doc.get("Balance"),
            "wallet_balances_difference": user_data["Amount"],
          },
        },
      }, "Deposit - From no access savings account");
    } else if (tranx_type == "Deposit" && method != "From No Access Savings") {
      // when money is being deposited from bank or mobile money to a Jayben wallet

      // double amount =
      // double.parse(transaction_owner_doc.get("Balance").toString()) -
      //     double.parse(user_data["Amount"].toString());

      await callSupabaseAPI({
        "request_type": "Deposit Transaction: Bank, Mobile money",
        "data": {
          "is_public": false,
          "country": "Zambia",
          "number_of_views": 0,
          "number_of_likes": 0,
          "number_of_replies": 0,
          "currency_symbol": "K",
          "user_is_verified": false,
          "created_at": user_data["DateCreated"].toDate().toIso8601String(),
          "amount": user_data["Amount"],
          "status": user_data["Status"],
          "withdrawal_details": null,
          "method": user_data["Method"],
          "p2p_sender_details": null,
          "user_id": user_data["UserID"],
          "comment": user_data["Comment"],
          "p2p_recipient_details": null,
          "currency": user_data["Currency"],
          "savings_account_details": null,
          "transaction_fee_details": null,
          "full_names": user_data["FullNames"],
          "attended_to": user_data["AttendedTo"],
          "description": user_data["PhoneNumber"],
          "sent_received": user_data["SentReceived"],
          "transaction_id": user_data["TransactionID"],
          "transaction_type": user_data["TransactionType"],
          "deposit_details": {
            "provider": user_data["Details"]["Provider"],
            "deposit_method": user_data["Details"]["DepositMethod"],
            "charge_depositer_the_deposit_fee_from_provider":
                user_data["Details"]["ChargeMe"],
          },
          "wallet_balance_details": {
            // "wallet_balance_before_transaction": amount,
            // "wallet_balance_after_transaction":
            //     transaction_owner_doc.get("Balance"),
            "wallet_balances_difference": user_data["Amount"],
          },
        },
      }, "Deposit - From bank or mobile money");
    }
  }

  Future<void> callSupabaseAPI(Map transaction_info, String useless) async {
    // gets the public supabase keys document
    // var supabase_keys = await _fire
    //     .collection("Admin")
    //     .doc("Legal")
    //     .collection("Supabase")
    //     .doc("keys")
    //     .get();

    // var res = await http.post(
    //   Uri.parse(
    //       "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/migration_functions"),
    //   headers: {
    //     "Content-type": "application/json",
    //     "Authorization": "Bearer ${supabase_keys.get("anon_key")}",
    //   },
    //   body: json.encode(transaction_info),
    // );

    // print(res.body);
  }

  // ==================== admin functions begin here going below

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  // gets all the app's transactions
  // TODO add pagination here
  Future<void> getAllTransaction() async {
    all_transactions = await supabase
        .from("transactions")
        .select()
        .order("created_at", ascending: false);

    notifyListeners();
  }

  // gets user count, wallet bal totals, num of active nas & acc bals totals
  Future<void> getCountableMetrics() async {
    DateTime now = DateTime.now();

    DateTime one_month_ago = DateTime.now().subtract(const Duration(days: 30));

    DateTime seven_days_ago = DateTime.now().subtract(const Duration(days: 7));

    DateTime today = DateTime(now.year, now.month, now.day);

    DateTime last_month =
        DateTime(one_month_ago.year, one_month_ago.month, one_month_ago.day);

    DateTime last_7_days =
        DateTime(seven_days_ago.year, seven_days_ago.month, seven_days_ago.day);

    List<dynamic> results = await Future.wait([
      supabase.from("users").select('*').count(CountOption.exact),
      supabase.from("users").select().gt("balance", 0),
      supabase
          .from("no_access_savings_accounts")
          .select('*')
          .eq("is_active", true)
          .count(CountOption.exact),
      supabase
          .from("transactions")
          .select('*')
          .eq("transaction_type", "Withdrawal")
          .eq("status", "Pending")
          .count(CountOption.exact),
      supabase
          .from("transactions")
          .select('*')
          .gte("created_at", today.toUtc().toIso8601String())
          .count(CountOption.exact),
      supabase.from("transactions").select('*').count(CountOption.exact),
      supabase
          .from("users")
          .select('*')
          .gte("last_time_online_timestamp", today.toUtc().toIso8601String())
          .count(CountOption.exact),
      supabase
          .from("users")
          .select('*')
          .gte("last_time_online_timestamp",
              last_month.toUtc().toIso8601String())
          .count(CountOption.exact),
      supabase
          .from("users")
          .select('*')
          .gte("created_at", last_month.toUtc().toIso8601String())
          .count(CountOption.exact),
      supabase
          .from("shared_no_access_savings_accounts")
          .select('*')
          .eq("is_active", true)
          .neq("balance", 0)
          .count(CountOption.exact),
      supabase
          .from("users")
          .select('*')
          .gte("last_time_online_timestamp",
              last_7_days.toUtc().toIso8601String())
          .count(CountOption.exact),
    ]);

    weekly_active_users = 0;
    total_amount_in_wallets = 0;
    total_amount_ever_deposited = 0;
    total_amount_withdrawn_today_so_far = 0;
    total_amount_in_personal_nas_accounts = 0;
    total_amount_in_active_shared_nas_accounts = 0;
    number_of_active_funded_shared_nas_accounts = 0;
    total_number_of_transactions_processed_ever = 0;
    number_of_transfers_to_personal_nas_accounts = 0;
    number_of_transactions_processed_today_so_far = 0;
    total_amount_saved_in_personal_nas_accs_today_so_far = 0;

    // sums up all the user wallet bals
    for (var i = 0; i < results[1].length; i++) {
      total_amount_in_wallets += results[1][i]["balance"];
    }

    // sums up all the active NAS acc bals
    for (var i = 0; i < results[2].data.length; i++) {
      if (results[2].data[i]["balance"] > 0) {
        total_amount_in_personal_nas_accounts += results[2].data[i]["balance"];
      }
    }

    // sums up all the withdrawals processed today so far
    for (var i = 0; i < results[4].data.length; i++) {
      if (results[4].data[i]["status"] == "Completed" &&
          results[4].data[i]["transaction_type"] == "Withdrawal") {
        total_amount_withdrawn_today_so_far += results[4].data[i]["amount"];
      }

      // sums up the amount saved in personal nas accs today so far
      if (results[4].data[i]["method"] == "No Access Savings Account" &&
          results[4].data[i]["transaction_type"] == "Savings Transfer") {
        total_amount_saved_in_personal_nas_accs_today_so_far +=
            results[4].data[i]["amount"];

        number_of_transfers_to_personal_nas_accounts++;
      }

      number_of_transactions_processed_today_so_far++;
    }

    // goes through all transactions
    for (var i = 0; i < results[5].data.length; i++) {
      if (results[5].data[i]["transaction_type"] == "Deposit") {
        if (results[5].data[i]["method"] != "From Group No Access Savings") {
          if (results[5].data[i]["method"] != "From No Access Savings") {
            if (results[5].data[i]["method"] != "Referral Commission") {
              total_amount_ever_deposited += results[5].data[i]["amount"];
            }
          }
        }
      }

      // gets up the number of transactions ever processed
      total_number_of_transactions_processed_ever++;
    }

    // gets the number of funded & active shared nas accs
    // gets the total saved in active shared nas accounts
    for (var i = 0; i < results[9].data.length; i++) {
      if (results[9].data[i]["account_id"] !=
          "5eeaaad9-cc76-4d26-a1e8-ba19a142c264") {
        total_amount_in_active_shared_nas_accounts +=
            results[9].data[i]["balance"];

        number_of_active_funded_shared_nas_accounts++;
      }
    }

    total_amount_of_user_money_in_our_possession = total_amount_in_wallets +
        total_amount_in_active_shared_nas_accounts +
        total_amount_in_personal_nas_accounts;
    number_of_monthly_active_users_today_so_far = results[7].count;
    number_of_daily_active_users_today_so_far = results[6].count;
    number_of_active_personal_nas_accounts = results[2].count;
    number_of_new_users_in_last_30_days = results[8].count;
    number_of_pending_withdrawals = results[3].count;
    number_of_registered_users = results[0].count;
    weekly_active_users = results[10].count;

    notifyListeners();
  }

  Future<void> callSupabaseDailyMetricAPI() async {
    // var supabase_keys = await _fire
    //     .collection("Admin")
    //     .doc("Legal")
    //     .collection("Supabase")
    //     .doc("keys")
    //     .get();

    // var res = await http.post(
    //   Uri.parse(
    //       "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions"),
    //   headers: {
    //     "Authorization": "Bearer ${supabase_keys.get("anon_key")}",
    //     "Content-type": "application/json",
    //   },
    //   body: json.encode({"request_type": "record_daily_metrics"}),
    // );

    // print(res.body);
  }

  // only gets the app's pending transactions
  Future<void> getPendingWithdrawals() async {
    pending_transactions = await supabase
        .from("transactions")
        .select()
        .eq("status", "Pending")
        .order("created_at", ascending: false);

    notifyListeners();
  }

  // gets the admin metrics document that stores metrics
  Future<void> getAdminMetricsDocument() async {
    // admin_metrics_document =
    //     await _fire.collection("Admin").doc("Metrics").get();

    notifyListeners();
  }

  // gets the withdraw owner's user's row
  Future<List<dynamic>> getWithdrawOwnersRow(String user_id) async {
    return await supabase.from("users").select().eq("user_id", user_id);
  }

  // gets all the withdrawals the user has made to the same line in 24 hours
  Future<int> getWithdrawalsWithSameLine(
      String user_id, String phone_number) async {
    DateTime now = DateTime.now();

    DateTime today = DateTime(now.year, now.month, now.day);

    int number_of_withdrawals_to_number_within_24_hours = 0;

    // gets the withdrawals made in last 24 hours
    List<dynamic>? withdrawals = await supabase
        .from("transactions")
        .select()
        .gte("created_at", today.toUtc().toIso8601String())
        .eq("transaction_type", "Withdrawal")
        .eq("user_id", user_id);

    for (var i = 0; i < withdrawals!.length; i++) {
      if (withdrawals[i]["status"] == "Completed" &&
          withdrawals[i]["withdrawal_details"]["phone_number"] ==
              phone_number) {
        number_of_withdrawals_to_number_within_24_hours++;
      }
    }

    return number_of_withdrawals_to_number_within_24_hours;
  }

  // marks the transaction as cancelled, completed, rejected, reversed
  Future<void> updateStatus(Map transaction_info) async {
    // marks the transaction as complete
    await supabase.from("transactions").update({
      "status": transaction_info["status"],
      "withdrawal_details": {
        "fulfilled_by_full_names": "${box("first_name")} ${box("last_name")}",
        "fulfilled_at_timestamp": DateTime.now().toIso8601String(),
        "fulfilled_by_user_id": box("user_id"),
        ...transaction_info["withdrawal_details"]
      }
    }).eq("transaction_id", transaction_info["transaction_id"]);

    // sends the user a notification
    if (transaction_info["status"] == "Completed") {
      await sendNotifications({
        "body":
            "Hello ${transaction_info["customer_map"]["first_name"]} 💰 your withdraw of ${transaction_info["currency"]} ${transaction_info["amount"]} "
                "has been processed successfully ✅",
        "notification_tokens": [
          transaction_info["customer_map"]["notification_token"]
        ],
        "title": "Withdrawal Completed 🤑",
      });
    } else {
      await sendNotifications({
        "body": "Hello ${transaction_info["customer_map"]["first_name"]}, your withdraw of ${transaction_info["currency"]} ${transaction_info["amount"]} "
            "has been ${transaction_info["status"].toLowerCase()}. Withdraw ID ${transaction_info["transaction_id"]}",
        "notification_tokens": [
          transaction_info["customer_map"]["notification_token"]
        ],
        "title": "Withdrawal ${transaction_info["status"]}",
      });
    }

    // adds the amount back to the user's balance
    if (transaction_info["status"] != "Completed") {
      // await _fire
      //     .collection("Users")
      //     .doc(transaction_info["customer_map"]["user_id"])
      //     .update({
      //   "Balance": FieldValue.increment(double.parse(
      //       transaction_info["withdrawal_details"]["withdraw_amount_plus_fee"]
      //           .toString())),
      // });
    }
  }

  // ============ Withdrawal SMS receiver functions

  // gets the current support number of the person who is doing withdrawals
  Future<String> getCurrentWithdrawalReceiverNumber() async {
    // DocumentSnapshot results = await _fire
    //     .collection("Admin")
    //     .doc("Legal")
    //     .collection("APIs")
    //     .doc("PaymentAPI")
    //     .get();

    // current_withdrawal_receiver_number =
    //     results.get("SupportLine").replaceAll("+26", "");

    notifyListeners();

    return current_withdrawal_receiver_number;
  }

  // updates the current support number of the person who is doing withdrawals
  Future<void> updateCurrentWithdrawalReceiverNumber(String number) async {
    if (number.isEmpty) return;

    // await _fire
    //     .collection("Admin")
    //     .doc("Legal")
    //     .collection("APIs")
    //     .doc("PaymentAPI")
    //     .update({"SupportLine": "+26${number.trim()}"});
  }

  // ============ verification functions

  // gets a list of the pending verification requests
  Future<void> getPendingVerificationRequests() async {
    verification_requests = await supabase
        .from("account_kyc_verification_requests")
        .select()
        .eq("status", "Pending")
        .order("created_at", ascending: false);

    notifyListeners();
  }

  // approves a pending verification request
  Future<void> approveVerificationRequestStatus(Map request_map) async {
    // 1). changes status to approved
    // 2). changes the user's account status to verified
    // 3). sends the user an approved notification
    await Future.wait([
      supabase
          .from("account_kyc_verification_requests")
          .update({"status": "Approved"}).eq(
              "verification_id", request_map["verification_id"]),
      // _fire
      //     .collection("Users")
      //     .doc(request_map["user_id"])
      //     .update({"isVerified": true}),
      sendNotifications({
        "body":
            "Your account has been approved & is now verified. Thank you for your patience!",
        "notification_tokens": [
          request_map["customer_map"]["notification_token"]
        ],
        "title": "KYC Verification Approved ✅",
      })
    ]);
  }

  // marks a pending verification request as rejected
  Future<void> rejectVerificationRequestStatus(Map request_map) async {
    // 1). changes status to approved
    // 2). changes the user's account status to verified
    // 3). sends the user an approved notification
    await Future.wait([
      supabase.from("account_kyc_verification_requests").update({
        "comment": request_map["response"]["comment"],
        "status": "Rejected",
      }).eq("verification_id", request_map["verification_id"]),
      sendNotifications({
        "body":
            "Your KYC files have been rejected due to ${request_map["response"]["comment"]}. Please make the necessary updates & try again.",
        "notification_tokens": [
          request_map["customer_map"]["notification_token"]
        ],
        "title": "KYC Verification Rejected ❌",
      })
    ]);
  }

  // updates the current verification request owner's account
  Future<void> updateRequestOwnerAccount(Map update_info) async {
    // await _fire.collection("Users").doc(update_info["user_id"]).update({
    //   "DateOfBirth": update_info["date_of_birth"],
    //   "FirstName": update_info["first_name"],
    //   "LastName": update_info["last_name"],
    // });
  }

  // ============ firebase equivalent functions for version < 1.00.38 users

  // gets all the app's transactions
  // TODO add pagination here
  Future<void> getAllTransactionFirebase() async {
    // all_transactions_firebase = await _fire
    //     .collection("Transactions")
    //     .orderBy("DateCreated", descending: true)
    //     .get();

    notifyListeners();
  }

  // only gets the app's pending transactions
  Future<void> getPendingWithdrawalsFirebase() async {
    // pending_transactions_firebase = await _fire
    //     .collection("Transactions")
    //     .where("Status", isEqualTo: "Pending")
    //     .orderBy("DateCreated", descending: true)
    //     .get();

    notifyListeners();
  }

  // marks the transaction as complete
  // Future<void> markTransactionCompleteFirebase(
  //     DocumentSnapshot transaction_info) async {
  // marks the transaction as complete
  // await _fire
  //     .collection("Transactions")
  //     .doc(transaction_info["TransactionID"])
  //     .update({"Status": "Completed"});
  // }

  // marks the transaction as rejected
  // Future<void> markTransactionRejectedFirebase(
  //     DocumentSnapshot transaction_info) async {
  //   // marks the transaction as complete
  //   await _fire
  //       .collection("Transactions")
  //       .doc(transaction_info["TransactionID"])
  //       .update({"Status": "Rejected"});

  //   // sends the user a completion sms
  //   await sendSMSAPI({
  //     "sender_id": "Jayben",
  //     "text_content":
  //         "Hello customer, your withdraw of ${transaction_info["Currency"]} ${transaction_info["Amount"]} "
  //             " has been rejected. Withdraw ID ${transaction_info["TransactionID"]}",
  //     "phone_number": transaction_info["PhoneNumber"]
  //         .replaceAll("To", "")
  //         .replaceAll("+", "")
  //         .replaceAll(" ", "")
  //   });
  // }

  // marks the transaction as reversed
  // Future<void> markTransactionReversedFirebase(
  //     DocumentSnapshot transaction_info) async {
  //   // marks the transaction as complete
  //   await _fire
  //       .collection("Transactions")
  //       .doc(transaction_info["TransactionID"])
  //       .update({"Status": "Reversed"});

  //   // sends the user a completion sms
  //   await sendSMSAPI({
  //     "sender_id": "Jayben",
  //     "text_content":
  //         "Hello customer, your withdraw of ${transaction_info["Currency"]} ${transaction_info["Amount"]} "
  //             " has been reversed. Withdraw ID ${transaction_info["TransactionID"]}",
  //     "phone_number": transaction_info["PhoneNumber"]
  //         .replaceAll("To", "")
  //         .replaceAll("+", "")
  //         .replaceAll(" ", "")
  //   });
  // }

  // ============= Migration functions below

  // Future<void> copyTransactionsAndPsteThemInSupabase() async {
  //   QuerySnapshot transactions = await _fire
  //       .collection("Transactions")
  //       .startAfter([DateTime(2023, 03, 26)])
  //       .orderBy("DateCreated", descending: false)
  //       .get();

  //   List<Map> document_maps = [];

  //   for (var i = 0; i < transactions.docs.length; i++) {
  //     if ((transactions.docs[i].data() as Map).containsKey("Details")) {
  //       document_maps.add((transactions.docs[i].data() as Map));
  //     }
  //   }

  //   // creates the transaction rows as maps in supabase
  //   await supabase.from("transactions").insert(document_maps);
  // }
}

class AgentProviderFunctions extends ChangeNotifier {
  List<dynamic>? active_orders;
  int agents_current_index = 0;
  List<dynamic>? active_agents;
  bool is_loading = false;

  // =========================

  bool returnIsLoading() => is_loading;
  List<dynamic>? returnActiveAgents() => active_agents;
  List<dynamic>? returnActiveOrders() => active_orders;
  int returnAgentsCurrentIndex() => agents_current_index;

  // =========================

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  void changeAgentsCurrentIndex(int index) {
    agents_current_index = index;
    notifyListeners();
  }

  // gets a list of all the agents
  Future<void> getActiveAgents() async {
    active_agents = await supabase
        .from("users")
        .select()
        .gt("balance", 10)
        .eq("account_type", "Agent")
        .eq("account_is_on_hold", false)
        .order("last_time_online_timestamp", ascending: false);

    notifyListeners();
  }

  // gets the user's pending orders
  Future<void> getOrders() async {
    active_orders = await supabase
        .from("transactions")
        .select()
        .eq("user_id", box("user_id"))
        .eq("status", "Pending")
        .eq("transaction_type", "Deposit")
        .order("created_at", ascending: false);

    notifyListeners();
  }

  // For agents: Marks a pending deposit as successful
  Future<void> markDepositComplete(String deposit_id) async {}

  // creates a dispute between the agent & the customer
  Future<void> createDispute(String deposit_id) async {}
}

// converted to RLS
class NfcProviderFunctions extends ChangeNotifier {
  List<dynamic>? list_of_registered_tags_transactions;
  String current_nfc_listener_state = "read";
  List<dynamic>? list_of_registered_tags;
  Timer? delete_character_timer;
  int number_of_scans_made = 0;
  bool tag_is_scanned = false;
  String pin_code_string = "";
  int current_card_index = 0;
  bool? has_tags_registered;
  bool is_loading = false;

  // ==================== getter

  bool returnIsLoading() => is_loading;
  bool returnTagIsScanned() => tag_is_scanned;
  String returnPinCodeString() => pin_code_string;
  int returnCurrentCardIndex() => current_card_index;
  bool? returnHasTagsRegistered() => has_tags_registered;
  List<dynamic>? returnListOfTags() => list_of_registered_tags;
  Timer? returnDeleteCharacterTimer() => delete_character_timer;
  String returnCurrentNfcListenerState() => current_nfc_listener_state;
  List<dynamic>? returnListOfTagTransactions() =>
      list_of_registered_tags_transactions;

  // ==================== setters

  void changeCurrentCardIndex(int index) {
    current_card_index = index;
    notifyListeners();
  }

  void resetTagIsScanned() {
    tag_is_scanned = false;
  }

  void updateCurrentNfcListenerState(String state) {
    current_nfc_listener_state = state;
  }

  void clearAllVariables() {
    current_card_index = 0;
    is_loading = false;
    notifyListeners();
  }

  void toggleIsLoading() {
    is_loading = !is_loading;
    notifyListeners();
  }

  void clearStrings() {
    current_card_index = 0;
    pin_code_string = "";
  }

  // adds characters to the current display string
  void addCharacter(String char) {
    if (char == ".") return;

    if (pin_code_string.length == 4) return;

    pin_code_string += char;

    notifyListeners();
  }

  // removes characters to the current display string
  void removeCharacter(String char) {
    if (pin_code_string.isEmpty) return;

    pin_code_string = pin_code_string.substring(0, pin_code_string.length - 1);

    notifyListeners();
  }

  // stops the deletion of the text
  void cancelDeleteCharTimer() {
    if (delete_character_timer == null) return;

    delete_character_timer!.cancel();

    notifyListeners();
  }

  // starts deleting the text character by character
  Future<void> startCharacterDeletion(String text) async {
    delete_character_timer =
        Timer.periodic(const Duration(milliseconds: 110), (_) async {
      if (text == "clear") {
        Vibrate.feedback(FeedbackType.light);

        removeCharacter(text);
      }
    });
  }

  // creates a database record of the tag being registered
  Future<bool> createTagRecord(
    BuildContext context,
    String tag_serial_number,
    String pin_code,
  ) async {
    Map<String, dynamic> res = await callGeneralFunction(
      "register_nfc_tag",
      {
        "tag_serial_number": tag_serial_number,
        "decrypted_pin_code": pin_code,
      },
    );

    return res["data"]["status"] == "success";
  }

  // checks if the user has any tags registered
  Future<void> getTags() async {
    Map<String, dynamic> res =
        await callGeneralFunction("get_my_registered_tags", {
      "get_tag_transactions_also": true,
    });

    list_of_registered_tags = res["data"]["data"]["tags"];

    if (list_of_registered_tags!.isNotEmpty) {
      list_of_registered_tags!.add(list_of_registered_tags![0]);
    }

    list_of_registered_tags_transactions = res["data"]["data"]["transactions"];

    notifyListeners();
  }

  // gets the transactions for only one tag
  Future<List<dynamic>> getSingleTagsTransactions(String tag_id) async {
    Map<String, dynamic> res =
        await callGeneralFunction("get_single_tag_transactions", {
      "tag_id": tag_id,
    });

    return res["data"]["data"];
  }

  // checks if the user has any tags registered
  Future<void> checkIfUserHasTagsRegistered() async {
    Map<String, dynamic> res = await callGeneralFunction(
      "check_if_user_has_tags_registered",
      {},
    );

    has_tags_registered = res["data"]["data"]["has_tags"];

    notifyListeners();
  }

  // checks if a tag has already been registered in the database
  Future<bool> checkIfTagExists(String tag_serial_number) async {
    Map<String, dynamic> res =
        await callGeneralFunction("check_if_tag_exists", {
      "tag_serial_number": tag_serial_number,
    });

    return res["data"]["data"]["exists"];
  }

  // writes an NFC tag
  Future<void> onNFCTagWrite(BuildContext context, NfcTag tag) async {
    Ndef? ndef = Ndef.from(tag);

    if (ndef is! Ndef) return;

    String tag_serial_number = (NfcA.from(tag)?.identifier ??
            NfcB.from(tag)?.identifier ??
            NfcF.from(tag)?.identifier ??
            NfcV.from(tag)?.identifier ??
            Uint8List(0))
        .toHexString()
        .replaceAll("0x", "")
        .replaceAll(" ", ":");

    // checks if the tag is already registered in the database
    bool tag_exists = await checkIfTagExists(tag_serial_number);

    if (tag_exists) {
      showSnackBar(
          context, "This tag is already registered. Please try another tag.");
      return;
    }

    NdefMessage text_to_write_to_tag = NdefMessage([
      NdefRecord.createText(
          "${box("user_code")}@@${box("first_name")}@@${box("last_name")}@@${"Personal Account"}"),
    ]);

    try {
      await ndef.write(text_to_write_to_tag);
    } catch (e) {
      showSnackBar(context, e.toString());
      return;
    }

    String pin_code = "1234";

    // creates a database record for the tag
    bool is_created =
        await createTagRecord(context, tag_serial_number, pin_code);

    if (!is_created) {
      showSnackBar(context, 'Failed to link card. Please try again.',
          color: Colors.green);
      return;
    }

    showSnackBar(
        context, 'Card has been linked successfully! You can now use card.',
        color: Colors.green);

    clearStrings();

    changePage(context, const HomePage(), type: "pr");

    current_nfc_listener_state = "read";
  }

  // reads an NFC tag
  Future<void> onNFCTagRead(BuildContext context, NfcTag tag) async {
    Ndef? tag_data = Ndef.from(tag);

    if (tag_data is! Ndef) return;

    final NdefRecord record = tag_data.cachedMessage!.records[0];

    final languageCodeLength = record.payload.first;

    final textBytes = record.payload.sublist(1 + languageCodeLength);

    String receivers_information = utf8.decode(textBytes);

    notifyListeners();

    if (tag_data == null) return;

    List<String> info = receivers_information.split("@@");

    // if (details[1]["user_id"] == box("user_id")) {
    //   showSnackBar(context, "You can't scan yourself. Scan another NFC Tag.",
    //       color: Colors.grey[600]!);

    //   return;
    // }

    changePage(
      context,
      TapToPayPage(
        paymentInfo: {
          "receiver_map": {
            "full_names": "${info[1]} ${info[2]}",
            "type_of_receiver_account": info[3],
            "user_code": info[0]
          },
        },
      ),
    );
  }

  // sends a payment via NFC
  Future<void> initateNFCPayment(Map paymentInfo) async {
    Map<String, dynamic> res =
        await callGeneralFunction("send_money_via_nfc_tag", {
      "transaction_details": {
        "amount_plus_transaction_fee": paymentInfo['amount_plus_transaction_fee'],
        "receivers_account_type": paymentInfo['account_type'],
        "receivers_full_names": paymentInfo['full_names'],
        "receivers_user_code": paymentInfo['user_code'],
        "payment_means": paymentInfo['payment_means'],
        "amount": paymentInfo['amount'],
      },
      "media_details": {
        "comment": paymentInfo['comment'],
        "privacy": paymentInfo['privacy']
      },
    });

    print(res["data"]["data"]);
  }
}

// ========== regular functions below

// calls the supabase general function
Future<Map<String, dynamic>> callGeneralFunction(
  String req_type,
  Map body,
) async {
  FunctionResponse res =
      await supabase.functions.invoke("general_functions", body: {
    "request_type": req_type,
    ...body,
  });

  Map<String, dynamic> data = res.data as Map<String, dynamic>;

  if (data == null) {
    return {
      "message": "failed, please try again",
      "status": "failed",
      "status_code": 400,
      "data": null
    };
  }

  return data;
}

// plays a sound from assets
Future<void> playSound(String file_name) async {
  final duration = await player.setAsset("assets/$file_name");

  await player.play();
  await player.stop();
}

// 1). Creates a thumbnail from a video file
// 2). Returns a path to the photo locally
Future<String> getThumbnailPath(String path) async {
  File? thumbnailFile =
      await VideoCompress.getFileThumbnail(path, quality: 80, position: 1);

  //removes the string "file://" from the path to prevent errors during upload
  return thumbnailFile.path.replaceAll("file://", "");
}

// 1). Computes the aspect ratio for a file
// 2). Returns the value as a double
Future<double> computeAspectRatio(File media) async {
  var decodedImage = await decodeImageFromList(media.readAsBytesSync());

  return decodedImage.width / decodedImage.height;
}

// bans all accounts using a specific version & sends a notification
Future<void> banAllVersion75Accounts() async {
  // QuerySnapshot accounts = await _fire
  //     .collection("Users")
  //     .where("CurrentBuildVersion", isEqualTo: "1.00.75")
  //     .get();

  // // print("There are ${accounts.docs.length} number of users using version 1.00.75 boss");

  // List<Future> operations = [];

  // List<Future> send_notifications = [];

  // for (var i = 0; i < accounts.docs.length; i++) {
  //   operations.add(_fire
  //       .collection("Users")
  //       .doc(accounts.docs[i].id)
  //       .update({"OnHold": true}));

  //   send_notifications.add(sendNotifications({
  //     "body":
  //         "Hi there, your app is running on an older version, kindly update your app to continue using Jayben. Please contact customer support immediately afterwards.",
  //     "title": "Crucial Update Required ⚠",
  //     "notification_tokens": [accounts.docs[i].get("NotificationToken")],
  //   }));
  // }

  // print("Now running all operations boss...");

  // // runs all the operations at once
  // await Future.wait(operations);

  // print(
  //     "Done running all operations boss & Now sending the notifications boss...");

  // // sends all the users notifications
  // await Future.wait(send_notifications);

  // print("Done sending all the users notifications boss");
}

UploadTask? uploadImageToFirebase(String destination, File image) {
  //function to upload the images... with a destination and an image to be uploaded
  try {
    final ref = FirebaseStorage.instance.ref(
        destination); //this defines the place where the images are to be stored

    return ref.putFile(
        image); //this is function to run the action of uploading the images
  } on FirebaseException catch (_) {
    return null;
  }
}

Future<void> cacheImage(String image) async {
  if (image.isEmpty) return;

  binding.addPostFrameCallback((_) async {
    BuildContext context = binding.renderViewElement as BuildContext;
    precacheImage(CachedNetworkImageProvider(image), context);
  });
  // caches an image
}

Future<void> sendUsersSMSes() async {
  // QuerySnapshot ds = await _fire
  //     .collection("Users")
  //     .where("CurrentPlatform", isEqualTo: "iOS")
  //     .get();

  // List<Future> operations = [];

  // for (var i = 0; i < ds.docs.length; i++) {
  //   print(i + 1);
  //   operations.add(http.post(
  //       Uri.parse(
  //           "https://us-central1-jayben-de41c.cloudfunctions.net/sms/api/internal/v1/sms/send/zambia"),
  //       headers: {"Content-type": "application/json"},
  //       body: json.encode({
  //         "text_content":
  //             "Urgent App Update now available. Kindly update your app to the latest version. "
  //                 "We have fixed the issue being experienced in the login page.",
  //         "phone_numbers": [ds.docs[i].get("PhoneNumber")],
  //         "sender_id": "",
  //       })));
  // }

  // print("Now sending the smses boss");

  // await Future.wait(operations);

  // print("Done trying sending the smses boss");
}

Future<void> migrateOldUserData() async {
  List<Future> operations = [];

  String new_user_id = "zRESIsWuTnSqD4Sghnoh9IJSjWs2";
  String old_user_id = "TJfxazHoJPRoeqG3Ti4QqRnWYW32";

  // ===================================================== NO ACCESS ACCOUNTS FIREBASE

  // gets the old user_id's no access accounts
  // QuerySnapshot no_access_accounts = await _fire
  //     .collection("Saving Accounts")
  //     .where("UserID", isEqualTo: old_user_id)
  //     .get();

  // // updates each no access savings account & their transactions
  // for (var i = 0; i < no_access_accounts.docs.length; i++) {
  //   operations.add(_fire
  //       .collection("Saving Accounts")
  //       .doc(no_access_accounts.docs[i].id)
  //       .update({"UserID": new_user_id}));

  //   QuerySnapshot no_access_accounts_transactions = await _fire
  //       .collection("Saving Accounts")
  //       .doc(no_access_accounts.docs[i].id)
  //       .collection("Transactions")
  //       .get();

  //   no_access_accounts_transactions.docs.forEach((doc) {
  //     operations.add(_fire
  //         .collection("Saving Accounts")
  //         .doc(no_access_accounts.docs[i].id)
  //         .collection("Transactions")
  //         .doc(doc.id)
  //         .update({"UserID": new_user_id}));
  //   });
  // }

  // print("Done working on no access accounts for firebase...");

  // // ===================================================== NO ACCESS ACCOUNTS SUPABASE

  // // gets the old user_id's no access accounts
  // List<dynamic> no_access_accounts_supabase = await supabase
  //     .from("no_access_savings_accounts")
  //     .select()
  //     .eq("user_id", old_user_id);

  // // updates each no access savings account & their transactions
  // for (var i = 0; i < no_access_accounts_supabase.length; i++) {
  //   operations.add(supabase
  //       .from("no_access_savings_accounts")
  //       .update({"user_id": new_user_id}).eq(
  //           "account_id", no_access_accounts_supabase[i]["account_id"]));

  //   List<dynamic> no_access_accounts_transactions = await supabase
  //       .from("no_access_savings_accounts_transactions")
  //       .select()
  //       .eq("savings_account_id", no_access_accounts_supabase[i]["account_id"]);

  //   no_access_accounts_transactions.forEach((doc) {
  //     operations.add(supabase
  //         .from("no_access_savings_accounts_transactions")
  //         .update({"user_id": new_user_id}).eq(
  //             "savings_account_id", doc["account_id"]));
  //   });
  // }

  // print("Done working on no access accounts for supabase...");

  // // ===================================================== TRANSACTIONS SUPABASE

  // // gets the old user_id's transactions
  // List<dynamic> transactions =
  //     await supabase.from("transactions").select().eq("user_id", old_user_id);

  // // updates each transaction
  // for (var i = 0; i < transactions.length; i++) {
  //   operations.add(supabase
  //       .from("transactions")
  //       .update({"user_id": new_user_id}).eq(
  //           "transaction_id", transactions[i]["transaction_id"]));
  // }

  // print("Done working on transactions for supabase...");

  // // ===================================================== NO ACCESS ACCOUNTS FIREBASE

  // print("now running all update operations...");

  // // runs all the operations at once
  // await Future.wait(operations);

  // print("Done running all update operations boss!");
}

Future<void> migrateUserRecords() async {
  // QuerySnapshot users = await _fire.collection("Users").get();

  // List<Future> operations = [];

  // for (var i = 0; i < users.docs.length; i++) {
  //   DocumentSnapshot doc = users.docs[i];

  //   Map userData = doc.data() as Map;

  //   operations.add(
  //     supabase.from("users").insert({
  //       "current_activity_level_completion_percentage":
  //           userData["CurrentActivityLevelCompletionPercentage"],
  //       "number_of_savings_deposits_ever_made_to_nas_accounts":
  //           userData["NumberOfSavingsDepositsEverMade"],
  //       "number_of_wallet_deposits_ever_made":
  //           userData["NumberOfWalletDepositsEverMade"],
  //       "total_amount_ever_saved_in_nas_accounts":
  //           userData["TotalAmountEverSaved"],
  //       "last_time_online_timestamp":
  //           userData["LastTimeOnline"].toDate().toIso8601String(),
  //       "daily_user_minutes_spent_in_app": userData["DailyInAppMinuteSpent"],
  //       'date_of_birth': userData["DateOfBirth"].toDate().toIso8601String(),
  //       "total_amount_ever_deposted": userData["TotalAmountEverDeposted"],
  //       'created_at': userData["DateJoined"].toDate().toIso8601String(),
  //       "nas_deposits_are_allowed": userData["CanMakeNasDeposits"],
  //       "withdrawals_are_allowed": userData["WithdrawalsAllowed"],
  //       "current_build_version": userData["CurrentBuildVersion"],
  //       "username_searchable": userData["Username_searchable"],
  //       "email_address_lowercase": userData["Email_lowercase"],
  //       "deposits_are_allowed": userData["DepositsAllowed"],
  //       "notification_token": userData["NotificationToken"],
  //       "current_os_platform": userData["CurrentPlatform"],
  //       "account_kyc_is_verified": userData["isVerified"],
  //       "black_listed_user_ids": userData["BlackListed"],
  //       "show_update_alert": userData["ShowUpdateAlert"],
  //       "currency_symbol": userData["CurrencySymbol"],
  //       "profile_image_url": userData["ProfileImage"],
  //       "activity_level": userData["ActivityLevel"],
  //       'is_currently_online': userData["isOnline"],
  //       "referral_code": userData["ReferralCode"],
  //       "account_is_on_hold": userData["OnHold"],
  //       "country_code": userData["CountryCode"],
  //       "physical_address": userData["Address"],
  //       'phone_number': userData["PhoneNumber"],
  //       "account_type": userData["AccountType"],
  //       "account_is_banned": userData["Banned"],
  //       'first_name': userData["FirstName"],
  //       "email_address": userData["Email"],
  //       'last_name': userData["LastName"],
  //       "user_code": userData["UserCode"],
  //       'username': userData["Username"],
  //       "currency": userData["Currency"],
  //       'country': userData["Country"],
  //       "balance": userData["Balance"],
  //       'user_id': userData["UserID"],
  //       "points": userData["Points"],
  //       'gender': userData["Gender"],
  //       "pin_code": userData["PIN"],
  //       'city': userData["City"],
  //     }),
  //   );
  // }

  // print("now running operations");

  // await Future.wait(operations);

  // print("DONE running operations");
}

// sends a notification to ao single person or a few people
Future<void> sendNotifications(Map notificationInfo) async {
  var res = await http.post(
    Uri.parse(
        "https://us-central1-jayben-de41c.cloudfunctions.net/notifications/v1/send/firebase"),
    headers: {
      "Content-type": "application/json",
    },
    body: json.encode(
      {
        "notification_tokens": notificationInfo["notification_tokens"],
        "title": notificationInfo["title"],
        "data": {"UserID": box("user_id")},
        "body": notificationInfo["body"],
      },
    ),
  );

  print(res.body);
}

// sends notifications to all users
Future<void> sendNotificationsAllUsers(Map notificationInfo) async {
  var res = await http.post(
    Uri.parse(
        "https://us-central1-jayben-de41c.cloudfunctions.net/notifications/v1/send/firebase/users/all/broadcast"),
    headers: {
      "Content-type": "application/json",
    },
    body: json.encode(
      {
        "title": notificationInfo["title"],
        "data": {"UserID": box("user_id")},
        "body": notificationInfo["body"],
      },
    ),
  );

  print(res.body);
}

// calls a firebase cloud function to send an sms
Future<void> sendSMSAPI(Map sms_info) async {
  var res = await http.post(
      Uri.parse(
          "https://us-central1-jayben-de41c.cloudfunctions.net/sms/api/internal/v1/sms/send/zambia"),
      headers: {"Content-type": "application/json"},
      body: json.encode({
        "phone_numbers": sms_info["phone_numbers"],
        "text_content": sms_info["text_content"],
        "sender_id": "",
      }));

  print(res.body);
}

// initializes supabase
Future<void> initSupabase() async {
  String anon_key =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";

  String supabase_url = "https://srfjzsqimfuomlmjixsu.supabase.co";

  // initializes supabase SDK
  await Supabase.initialize(anonKey: anon_key, url: supabase_url);
}

// gets user's balance and then returns it
Future<double> getUserBalance() async {
  List<dynamic> user_row =
      await supabase.from("users").select().eq("user_id", box("user_id"));

  return double.parse(user_row[0]["balance"].toString());
}

// returns the screen's height
double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

// returns the screen's width
double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

// returns a height sizedbox
Widget hGap(double? height) {
  return SizedBox(height: height);
}

// returns a width sizedbox
Widget wGap(double? width) {
  return SizedBox(width: width);
}

// shows nothing
Widget nothing() {
  return const SizedBox();
}

// Gets the value of key
// from the hive box locally
dynamic box(String key) {
  return Hive.box("user_information").get(key);
}

// Stores values using their keys in hive
dynamic boxPut(String key_name, dynamic value) {
  Hive.box("user_information").put(key_name, value);
}

// deletes box values using their keys in hive
dynamic boxDelete(String key_name) {
  Hive.box("user_information").delete(key_name);
}

dynamic boxClear() {
  Hive.box("user_information").clear();
}

dynamic boxClose() {
  Hive.box("user_information").close();
}

// Shows bottom card
Future<dynamic> showBottomCard(BuildContext context, Widget card,
    {bool is_dismissble = true, bool enable_drag = true}) async {
  return await showModalBottomSheet(
    backgroundColor: Colors.transparent,
    isDismissible: is_dismissble,
    enableDrag: enable_drag,
    context: context,
    builder: (builder) => card,
  );
}

// Shows dialogue widget
Future<dynamic> showDialogue(BuildContext context, Widget dialogue,
    {bool is_dismissble = true}) async {
  return await showDialog(
    context: context,
    barrierDismissible: is_dismissble,
    builder: (context) => dialogue,
  );
}

// shows a floating snackbar messenger in app
void showSnackBar(
  BuildContext context,
  String text, {
  TextAlign align = TextAlign.center,
  Color color = Colors.black,
  SnackBarAction? action,
  int duration = 3,
}) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: duration),
      content: Text(
        text,
        // maxLines: 1,
        textAlign: align,
        style: GoogleFonts.ubuntu(
          fontWeight: FontWeight.w300,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      action: action,
    ),
  );
}

// hides from keyboard
void hideKeyboard() {
  SystemChannels.textInput.invokeMethod("TextInput.hide");
}

// shows from keyboard
void showKeyboard() {
  SystemChannels.textInput.invokeMethod("TextInput.show");
}

// routes the user to another page
void changePage(BuildContext context, Widget page, {String type = "push"}) {
  if (type == "push") {
    Navigator.push(context, MaterialPageRoute(builder: (builder) => page));
  } else if (type == "pr") {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => page));
  }
}

// routes user to the previous page
void goBack(BuildContext context) {
  return Navigator.of(context).pop();
}
