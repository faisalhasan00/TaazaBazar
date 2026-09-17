importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyB9ipt0e_NW6jW8JH6yzA_jDDygnGSgPpU",
  authDomain: "taazabazar-cd20d.firebaseapp.com",
  projectId: "taazabazar-cd20d",
  storageBucket: "taazabazar-cd20d.firebasestorage.app",
  messagingSenderId: "752330450569",
  appId: "1:752330450569:web:126015a7aaea3ae4054858"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification?.title || 'TaazaBazar Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
