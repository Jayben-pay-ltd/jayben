import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Home/elements/admin/elements/update_withdrawal_sms_receiver.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/admin/elements/broadcast_notifications.dart';

class AdminDashboardCard extends StatelessWidget {
  const AdminDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width(context),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: Platform.isIOS ? 40 : 25,
            right: 30,
            left: 30,
            top: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => changePage(
                    context, const UpdateWithdrawalSmsReceiverPage()),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.sms,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Withdrawal SMS Receiver",
                            style: GoogleFonts.ubuntu(
                              color: const Color(0xFF616161),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          hGap(2),
                          Text(
                            "Change who receives withdrawal SMSes",
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              hGap(20),
              GestureDetector(
                onTap: () => changePage(context, const SendNotificationPage()),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Broadcast Notification",
                            style: GoogleFonts.ubuntu(
                              color: const Color(0xFF616161),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          hGap(2),
                          Text(
                            "Send Notifications To All Users",
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
