// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class InviteContactTile extends StatelessWidget {
  const InviteContactTile({super.key, required this.contact});

  final dynamic contact;

  @override
  Widget build(BuildContext context) {
    return contact.phones!.isEmpty || contact.displayName!.isEmpty
        ? nothing()
        : ListTile(
            title: Text(
              contact.displayName!,
              style: googleStyle(
                weight: FontWeight.w400,
                color: Colors.black,
                size: 18,
              ),
            ),
            subtitle: Text(
              contact.phones!.first.value!,
              style: googleStyle(
                weight: FontWeight.w300,
                color: Colors.black54,
                size: 15,
              ),
            ),
            trailing: inviteButton(context, contact.phones!.first.value!),
          );
  }

  Widget inviteButton(BuildContext context, String phone_number) {
    return GestureDetector(
      onTap: () async =>
          context.read<ReferralProviderFunctions>().addFriend(phone_number),
      child: const SizedBox(
        child: Text(
          "ADD FRIEND",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
