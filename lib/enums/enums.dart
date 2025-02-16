enum FriendViewType {
  friends,
  friendRequests,
  allUsers,
}

enum MessageEnum {
  text,
  image,
  video,
  audio,
  file
}


// extension convertMessageEnumToString on String
extension MessageEnumExtension on String {
  MessageEnum toMessageEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.text;
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      case 'audio':
        return MessageEnum.audio;
      case 'file':
        return MessageEnum.file;
      default:
        return MessageEnum.text;
    }
  }
}