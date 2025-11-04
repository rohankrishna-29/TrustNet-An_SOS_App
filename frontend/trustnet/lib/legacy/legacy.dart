//legacy notification 
// Initialize services AFTER getting userId
        //final contactsService = TrustedContactsService();
        //final notificationService = NotificationService(contactsService);
        
        //await contactsService.subscribeToTrustedContacts(userId!);
        //await notificationService.initialize();


//Request mic permission
/*  Future<void> _requestMicPermission() async {
  final status = await Permission.microphone.status;
  if (!status.isGranted) {
    final result = await Permission.microphone.request();
    if (!result.isGranted) {
      debugPrint("Microphone permission denied.");
    }
  }
}*/       