importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyCeoO3BACxhCcm8Sq2oGkZR2uRbca6VHRE",
    authDomain: "vocabhub-34c7f.firebaseapp.com",
    projectId: "vocabhub-34c7f",
    storageBucket: "vocabhub-34c7f.appspot.com",
    messagingSenderId: "726058956773",
    appId: "1:726058956773:web:7fcbf23d2ea0e1c246610c",
    measurementId: "G-PX6FK67F2P",
    databaseURL: 'https://vocabhub-34c7f-default-rtdb..us-central1.firebasedatabase.app',
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
    console.log("onBackgroundMessage", m);
});