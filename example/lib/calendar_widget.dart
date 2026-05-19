import 'package:callendar/callendar.dart';
import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final List<BookedDateRange> _allBookings = <BookedDateRange>[
    BookedDateRange(
      range: DateTimeRange(
        start: DateTime(2026, 5, 15),
        end: DateTime(2027, 5, 20),
      ),
      bookedBy: 'William Brown',
      guestCount: 3,
      bookingId: 'RES-10542',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    ),
    // BookedDateRange(
    //   range: DateTimeRange(
    //     start: DateTime(2026, 5, 18),
    //     end: DateTime(2026, 5, 22),
    //   ),
    //   bookedBy: 'Alex Johnson',
    //   guestCount: 3,
    //   bookingId: 'RES-10542',
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    // ),
    // BookedDateRange(
    //   range: DateTimeRange(
    //     start: DateTime(2026, 6, 2),
    //     end: DateTime(2026, 6, 5),
    //   ),
    //   bookedBy: 'Taylor Smith',
    //   guestCount: 2,
    //   bookingId: 'RES-10877',
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    // ),
  ];

  List<BookedDateRange> _bookedDateRanges = const <BookedDateRange>[];
  DateTime? _loadedMonth;
  int _requestId = 0;

  Future<List<BookedDateRange>> _loadBookingsForMonth(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final DateTime monthStart = DateTime(month.year, month.month, 1);
    final DateTime monthEnd = DateTime(month.year, month.month + 1, 0);

    return _allBookings
        .where((BookedDateRange booking) {
          return !booking.range.end.isBefore(monthStart) &&
              !booking.range.start.isAfter(monthEnd);
        })
        .toList(growable: false);
  }

  Future<void> _handleMonthChange(DateTime month) async {
    final DateTime normalizedMonth = DateTime(month.year, month.month);
    if (_loadedMonth != null &&
        _loadedMonth!.year == normalizedMonth.year &&
        _loadedMonth!.month == normalizedMonth.month) {
      return;
    }

    final int currentRequest = ++_requestId;
    final List<BookedDateRange> bookings = await _loadBookingsForMonth(
      normalizedMonth,
    );

    if (!mounted || currentRequest != _requestId) {
      return;
    }

    setState(() {
      _loadedMonth = normalizedMonth;
      _bookedDateRanges = bookings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BookingCalendar(
      propertyName: 'The Palm Residence',
      nightsBookedLabel: 'Nights booked',
      numberOfGuestsLabel: 'No. of guests',
      numberOfBookingsLabel: 'No. of bookings',
      onMonthChange: _handleMonthChange,
      bookedDateRanges: _bookedDateRanges,
    );
  }
}
