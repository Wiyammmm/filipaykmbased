// ignore_for_file: unused_import

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue;

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

///Test printing
class PrintServices {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<bool> sample() async {
    try {
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          bluetooth.printCustom("TEST", 1, 1);
          bluetooth.printCustom("TEST", 1, 1);
          bluetooth.printCustom("TEST", 1, 1);
          bluetooth.printCustom("TEST", 1, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.printNewLine();
        }
      });
      return true;
    } catch (e) {
      print('error print: $e');
      return false;
    }
  }

  Future<bool> printTicket(
      String discount, String amount, String totalAmount) async {
    try {
      String formatDateNow() {
        final now = DateTime.now();
        final formattedDate = DateFormat("MMM dd, yyyy HH:mm:ss").format(now);
        return formattedDate;
      }

      final formattedDate = formatDateNow();

      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          // bluetooth.printNewLine();

          bluetooth.printCustom(breakString("TEST COOPERATIVE NAME", 24), 1, 1);

          bluetooth.printCustom("Contact Us: +639123456789", 1, 1);

          bluetooth.printCustom("POWERED BY: FILIPAY", 1, 1);
          bluetooth.printCustom("PASSENGER RECEIPT", 1, 1);

          bluetooth.printCustom("Ticket#:   000001", 1, 1);

          bluetooth.printLeftRight("MOP:", "QR", 1);

          bluetooth.printLeftRight("PASS TYPE:", "REGULAR", 1);

          bluetooth.printLeftRight("JEEP NO:", "101", 1);
          bluetooth.printCustom("DATE: $formattedDate", 1, 1);

          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);

          bluetooth.printLeftRight("Discount:", "$discount", 1);
          bluetooth.printLeftRight("Amount:", "$amount", 1);

          bluetooth.printCustom("TOTAL AMOUNT", 2, 1);
          bluetooth.printCustom("$totalAmount", 2, 1);
          bluetooth.printNewLine();
          bluetooth.printCustom("PASSENGER'S COPY", 1, 1);
          bluetooth.printCustom("- - - - - - - - - - - - - - -", 1, 1);
          bluetooth.printCustom("NOT AN OFFICIAL RECEIPT", 1, 1);

          bluetooth.printNewLine();
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  String breakString(String input, int maxLength) {
    List<String> words = input.split(' ');

    String firstLine = '';
    String secondLine = '';

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if ((firstLine.length + 1 + word.length) <= maxLength) {
        // Add the word to the first line
        firstLine += (firstLine == "" ? '' : ' ') + word;
      } else if (secondLine == "") {
        // If the second line is empty, add the word to it
        secondLine += word;
      } else {
        // Truncate the word if it exceeds the maxLength
        int remainingSpace = maxLength - secondLine.length - 1;
        secondLine += ' ' +
            (word.length > remainingSpace
                ? word.substring(0, remainingSpace) + '..'
                : word);
        break;
      }
    }
    // Return the concatenated lines
    if (secondLine.trim() == "") {
      return "$firstLine";
    } else {
      return '$firstLine\n$secondLine';
    }
  }
}
