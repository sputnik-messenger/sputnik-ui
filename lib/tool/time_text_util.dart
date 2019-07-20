// Copyright (C) 2019 Mohammed El Batya
//
// This file is part of sputnik_ui.
//
// sputnik_ui is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


import 'package:intl/intl.dart';

class TimeTextUtil {
  static final weekday = DateFormat('EEEE');

  static String textOr(
    DateTime time,
    DateFormat format, {
    DateFormat todayFormat,
    DateFormat yesterdayFormat,
    DateFormat lastWeekDayFormat,
    DateFormat thisMonthFormat,
    DateFormat thisYearFormat,
  }) {
    String text;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final isToday = time.isAtSameMomentAs(midnight) || time.isAfter(midnight);
    if (isToday) {
      text = todayFormat != null ? todayFormat.format(time) : 'Today';
    } else {
      final yesterdayMidnight = midnight.subtract(const Duration(days: 1));
      if (time.isAtSameMomentAs(yesterdayMidnight) || time.isAfter(yesterdayMidnight)) {
        text = yesterdayFormat != null ? yesterdayFormat.format(time) : 'Yesterday';
      } else {
        final lastWeekMidnight = midnight.subtract(const Duration(days: 7));
        if (time.isAtSameMomentAs(lastWeekMidnight) || time.isAfter(lastWeekMidnight)) {
          text = lastWeekDayFormat != null ? lastWeekDayFormat.format(time) : weekday.format(time);
        } else if (thisMonthFormat != null && now.month == time.month) {
          text = thisMonthFormat.format(time);
        } else if (thisYearFormat != null && now.year == time.year) {
          text = thisYearFormat.format(time);
        }
      }
    }

    if (text == null) {
      text = format.format(time);
    }
    return text;
  }
}
