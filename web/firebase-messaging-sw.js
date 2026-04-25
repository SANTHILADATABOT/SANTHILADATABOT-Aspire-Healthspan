importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDuRkpyB2ePf-U91ld4zTXzmJUvSlY1CiQ",
  authDomain: "aspirenew-5085f.firebaseapp.com",
  projectId: "aspirenew-5085f",
  storageBucket: "aspirenew-5085f.appspot.com",
  messagingSenderId: "989276102678",
  appId: "1:989276102678:web:857645553a645b2364d537",
  measurementId: "G-D3VW2P8SEC"
});

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});


