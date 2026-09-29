importScripts(
  'https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js'
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: 'AIzaSyANaaT56PKlyapihSEClrjCU8EMFRfKT6Q',
  authDomain:  'carecircle-755eb.firebaseapp.com',
  projectId:  'carecircle-755eb',
  storageBucket:  'carecircle-755eb.firebasestorage.app',
  messagingSenderId:  '616798473724',
  appId: '1:616798473724:web:38da09f91d9a584b077679',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log(
    '[firebase-messaging-sw.js] Background message:',
    payload
  );

  const notificationTitle =
    payload.notification?.title || 'CareCircle';

  const notificationOptions = {
    body:
        payload.notification?.body ||
        'You have a new CareCircle notification.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
  };

  self.registration.showNotification(
    notificationTitle,
    notificationOptions,
  );
});