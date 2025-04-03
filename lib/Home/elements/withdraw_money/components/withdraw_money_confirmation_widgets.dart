// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utilities/provider_functions.dart';

Widget pricePreviewWidget(BuildContext context, Map body_info) {
  return Container(
    width: width(context),
    alignment: Alignment.center,
    child: Container(
      alignment: Alignment.center,
      width: width(context) * 0.88,
      decoration: pricePreviewDeco(),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("Processing Time",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
              const Spacer(),
              Text("May take upto 24 hours",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.grey[500]),
          ),
          Row(
            children: [
              Text("Withdraw Amount",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
              const Spacer(),
              Text("${body_info["currency_symbol"]}${body_info["price"]}",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500))
            ],
          ),
          hGap(15),
          Row(
            children: [
              Text(
                  body_info["charge_scheme"] != "per person"
                      ? "Booking Quantity"
                      : "Number of People Attending",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
              const Spacer(),
              Text(
                  body_info["booking_quantity_controller"].text.isEmpty
                      ? "- - -"
                      : "${body_info["booking_quantity_controller"].text}",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500))
            ],
          ),
          hGap(15),
          Row(
            children: [
              Text(
                  body_info["booking_quantity_controller"].text.isEmpty
                      ? "${body_info["currency_symbol"]}${body_info["price"]} x - - -"
                      : "${body_info["currency_symbol"]}${body_info["price"]} x ${body_info["booking_quantity_controller"].text}",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
              const Spacer(),
              Text(
                  body_info["booking_quantity_controller"].text.isEmpty
                      ? "- - -"
                      : "${body_info["currency_symbol"]}${double.parse(body_info["price"].toString()) * double.parse(body_info["booking_quantity_controller"].text)}",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500))
            ],
          ),
          hGap(15),
          Row(
            children: [
              Text("Service Fee",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
              const Spacer(),
              Text(
                  body_info["service_fee_amount"] == 0.0
                      ? "- - -"
                      : "${body_info["currency_symbol"]}${body_info["service_fee_amount"]}",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.grey[500]),
          ),
          Row(
            children: [
              Text("Booking total",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
              const Spacer(),
              Text(
                  "${body_info["currency_symbol"]} ${body_info["booking_total_plus_service_fee"]}",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500))
            ],
          ),
        ],
      ),
    ),
  );
}

// ================ styling widgets

Decoration pricePreviewDeco() {
  return BoxDecoration(
      color: Colors.grey[200], borderRadius: BorderRadius.circular(30));
}
