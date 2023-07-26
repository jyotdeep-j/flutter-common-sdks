
class GoogleMeet {

//Generate google meet link
Future<void> generateMeetingLink() async {
   //validation for start & end time 
    if (endTimeInEpoch - startTimeInEpoch > 0) {
      //validate empty/no space between title
      if (_validateTitle(currentTitle) == null) {
        //insert event into calender
        await calendarClient
            .insert(
                title: currentTitle ?? "",
                description: currentDesc ?? '',
                location: '',
                attendeeEmailList: [],
                shouldNotifyAttendees: false,
                hasConferenceSupport: true,
                startTime:
                    DateTime.fromMillisecondsSinceEpoch(startTimeInEpoch),
                endTime: DateTime.fromMillisecondsSinceEpoch(endTimeInEpoch))
            .then((eventData) async {
          String eventId = eventData!['id'] ?? "";
          //here is the google meet link
          String eventLink = eventData['link'] ?? "";
          //add data into google meet
          GoogleMeetEventInfo eventInfo = GoogleMeetEventInfo(
            id: eventId,
            name: currentTitle ?? "",
            description: currentDesc ?? '',
            location: "",
            link: eventLink,
            attendeeEmails: [],
            shouldNotifyAttendees: false,
            hasConferencingSupport: true,
            startTimeInEpoch: startTimeInEpoch,
            endTimeInEpoch: endTimeInEpoch,
          );        
        }).catchError(
          (e) {
            AppToast.showMessage(context, e.toString());
          },
        );
      }
    } else {
      AppToast.showMessage(
          context, 'Invalid time! Please use a proper start and end time');
    }
  }  

// Modify google meet event
  void modifyEvent(){
      calendarClient.modify(title: _validateTitle(currentTitle),
             description: currentDesc ?? '',
             location: currentLocation??"",
             attendeeEmailList: attendeeEmails,
             shouldNotifyAttendees: shouldNofityAttendees,
             hasConferenceSupport: hasConferenceSupport,
             startTime: DateTime.fromMillisecondsSinceEpoch(startTimeInEpoch),
             endTime: DateTime.fromMillisecondsSinceEpoch(endTimeInEpoch)
            );
  }

//Delete google meet event
  void deleteEvent(){
    await calendarClient.delete(eventId!, true)
  }


//Validate meeting title
  String? _validateTitle(String value) {
    if (value.isNotEmpty) {
      value = value.trim();
      if (value.isEmpty) {
        return 'Title can\'t be empty';
      }
    } else {
      return 'Title can\'t be empty';
    }

    return null;
  }

}
