# ReceiptRanger

A Flutter-based mobile app designed to streamline the process of scanning, recording, and managing receipts (recepisses) for daily striking tasks at the office. With integrated QR code scanning and text recognition, it simplifies handling 100+ receipts per day in under 15 minutes.

## Features
- **Batch Scanning**: Scan QR codes to extract receipt numbers using the camera, with OCR to detect dates.
- **Manual Input**: Enter receipt numbers and dates manually with a numeric keypad and date picker for flexibility.
- **Date Grouping**: Organize receipts by date for easy striking on paper sheets.
- **Progress Tracking**: Tap to highlight receipts (one at a time) with indexed numbering to track strike progress.
- **Data Management**: Clear all data with a confirmation dialog, ideal for daily resets.
- **User-Friendly**: Dark theme, progress indicators during processing, and fallback options for bad document states.

## Usage
- **Scan Mode**: Open the app, tap the camera icon, and point at receipts to scan QR codes and extract dates.
- **Manual Mode**: Use the "+" button to input numbers and dates manually.
- **Strike Progress**: Tap a receipt to highlight it, tap again to unhighlight, and proceed in order.
- **Data Wipe**: Use the delete icon to clear all data when done.

## Built With
- **Flutter**: Cross-platform framework
- **camera**: For live camera feed
- **google_mlkit_barcode_scanning**: QR code detection
- **google_mlkit_text_recognition**: OCR for date extraction
- **hive**: Local data persistence
- **intl**: Date formatting

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments
- Inspired by the need to optimize daily receipt striking at my work place.
- Thanks to the Flutter and ML Kit communities for robust tools!
