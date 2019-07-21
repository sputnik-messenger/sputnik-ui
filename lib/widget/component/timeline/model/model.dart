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

import 'package:built_collection/built_collection.dart';
import 'package:sputnik_app_state/sputnik_app_state.dart';
import 'package:tuple/tuple.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';

abstract class TimelineEntry {
  final String id;

  TimelineEntry(this.id);

  int get length => 1;
  bool isFollowing = false;
  bool hasFollower = false;

  entryAtIndex(int index) => this;
}

class GroupEntry extends TimelineEntry {
  bool isExpanded = false;
  bool isExpandable = true;
  List<TimelineEntry> expandedEntries;

  GroupEntry(String id, Iterable<TimelineEntry> entries) : super(id) {
    expandedEntries = entries.toList();
  }

  @override
  int get length => isExpanded ? expandedEntries.length : 1;

  @override
  TimelineEntry entryAtIndex(int index) => isExpanded ? expandedEntries[index] : this;
}

class EventEntry extends TimelineEntry {
  final TimelineEventState event;

  EventEntry(String id, this.event) : super(id);
}

class DateSection extends TimelineEntry {
  final DateTime dateTime;

  DateSection(String id, this.dateTime) : super(id);
}

class TimelineModel {
  final String userId;
  final String roomId;
  final indexMap = Map<int, Tuple2<int, int>>();
  final List<TimelineEntry> entries;
  final Map<String, UserSummary> members;
  final BuiltMap<String, BuiltMap<String, BuiltList<RoomEvent>>> reactions;
  final RoomEvent latestRoomEvent;

  TimelineModel(
    this.userId,
    this.roomId,
    this.entries,
    this.members,
    this.reactions,
    this.latestRoomEvent,
  ) {
    updateIndexMap();
  }

  updateIndexMap({Set<String> expand}) {
    int length = 0;
    indexMap.clear();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (expand != null && entry is GroupEntry && expand.contains(entry.id)) {
        entry.isExpanded = true;
      }
      for (int j = 0; j < entry.length; j++) {
        indexMap[length] = Tuple2(i, j);
        length += 1;
      }
    }
  }

  int get length => entries.isEmpty ? 0 : entries.map((e) => e.length).reduce((a, b) => a + b);

  String displayNameFor(String userId) {
    return '${members[userId]?.displayName?.value ?? userId}';
  }

  TimelineEntry entryAtIndex(int index) {
    final mappedIndex = indexMap[index];
    var entry = entries[mappedIndex.item1];
    return entry.entryAtIndex(mappedIndex.item2);
  }
}
