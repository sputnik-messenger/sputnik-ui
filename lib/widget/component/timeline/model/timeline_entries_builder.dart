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

import 'package:sputnik_app_state/sputnik_app_state.dart';

import 'model.dart';

class TimelineEntriesBuilder {
  final _followTimeSpan = const Duration(minutes: 5).inMilliseconds;
  final _timelineEntries = List<TimelineEntry>();
  final _groupedEvents = List<EventEntry>();

  final dates = Set<int>();

  List<TimelineEntry> timelineEntriesFrom(Iterable<TimelineEventState> events) {
    final sorted = events.toList()..sort((a, b) => a.event.origin_server_ts.compareTo(b.event.origin_server_ts));

    for (final event in sorted) {
      _addDateHeaderIfNew(event);
      if (event.event.isStateEvent) {
        _groupedEvents.add(EventEntry(event.event.event_id, event));
      } else {
        _closeGroup();
        _timelineEntries.add(EventEntry(event.event.event_id, event));
      }
    }
    _closeGroup();
    _setFollowFlags();

    return _timelineEntries.reversed.toList();
  }

  _setFollowFlags() {
    for (int i = 0; i < _timelineEntries.length; i++) {
      final entry = _timelineEntries[i];
      final earlier = i > 0 ? _timelineEntries[i - 1] : null;
      final later = i < _timelineEntries.length - 1 ? _timelineEntries[i + 1] : null;

      if (entry is EventEntry &&
          earlier is EventEntry &&
          timeDiff(entry, earlier) < _followTimeSpan &&
          sameSender(entry, earlier) &&
          !entry.event.event.isStateEvent &&
          !earlier.event.event.isStateEvent) {
        entry.isFollowing = true;
      }

      if (entry is EventEntry &&
          later is EventEntry &&
          timeDiff(entry, later) < _followTimeSpan &&
          sameSender(entry, later) &&
          !entry.event.event.isStateEvent &&
          !later.event.event.isStateEvent) {
        entry.hasFollower = true;
      }
    }
  }

  void _addDateHeaderIfNew(TimelineEventState event) {
    final ts = event.event.origin_server_ts;
    final midnight = _midnightFor(ts);
    if (dates.add(midnight.millisecondsSinceEpoch)) {
      _closeGroup();
      _timelineEntries.add(
        DateSection(ts.toString(), midnight),
      );
    }
  }

  _closeGroup() {
    if (_groupedEvents.isNotEmpty) {
      _timelineEntries
          .add(GroupEntry(_groupedEvents.map((e) => e.event.event.event_id.hashCode).reduce((a, b) => (a + b)).toString(), _groupedEvents.reversed));
      _groupedEvents.clear();
    }
  }

  static bool sameSender(EventEntry a, EventEntry b) {
    return a.event.event.sender == b.event.event.sender;
  }

  static int timeDiff(EventEntry a, EventEntry b) {
    return (a.event.event.origin_server_ts - b.event.event.origin_server_ts).abs();
  }

  static DateTime _midnightFor(int timestamp) {
    final ts = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime(ts.year, ts.month, ts.day);
  }
}
