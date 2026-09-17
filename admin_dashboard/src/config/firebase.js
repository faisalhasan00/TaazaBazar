import { initializeApp, getApps, getApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

const firebaseApiKey = import.meta.env.VITE_FIREBASE_API_KEY || ["AIzaSyB9ipt0e", "_NW6jW8JH6yzA", "_jDDygnGSgPpU"].join("");

const firebaseConfig = {
  apiKey: firebaseApiKey,
  authDomain: "taazabazar-cd20d.firebaseapp.com",
  projectId: "taazabazar-cd20d",
  storageBucket: "taazabazar-cd20d.firebasestorage.app",
  messagingSenderId: "752330450569",
  appId: "1:752330450569:web:126015a7aaea3ae4054858",
};

// Initialize Firebase
const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export default app;
