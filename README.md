# pomachat

pomachat, developed as my final course project, is a chat app built using Flutter, Firebase, and WebRTC.

## Features
- Send messages, images and files.
- Make video calls using the power of [WebRTC](https://webrtc.org/).
- Create and delete groups.
- Customize a group's image, description and name.
- Customize your username, bio and profile picture.
- Invite other users to be your friends or to join your group.
- Remove friends.
- Remove other members if you are the group admin.

## Setup

- **Step 1**: Clone the repository:

  ```bash
  git clone https://github.com/anotherlusitano/pomachat.git
  ```

- **Step 2**: [Follow this guide until step 2](https://firebase.google.com/docs/flutter/setup?platform=ios).

  - PS: Don't forget to update the Firestore rules.
    ```
    service cloud.firestore {
      match /databases/{database}/documents {
        match /{document=**} {
          allow read, write: if true;
        }
      }
    }
    ```

- **Step 3**: Run the app and have fun :)
  ```bash
  flutter run
  ```
