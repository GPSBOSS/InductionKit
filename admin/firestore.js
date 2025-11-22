// Firebase SDK imports
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";

import {
    getAuth,
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
    onAuthStateChanged,
    signOut
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";

import {
    getFirestore,
    collection,
    addDoc,
    getDocs,
    getDoc,
    setDoc,
    updateDoc,
    deleteDoc,
    doc
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore.js";

// Firebase config
const firebaseConfig = {
    apiKey: "AIzaSyCdAkNvZ3JkM-GmWBKf9eZ1p0LwZmj7rOE",
    authDomain: "project1-b718c.firebaseapp.com",
    projectId: "project1-b718c",
    storageBucket: "project1-b718c.firebasestorage.app",
    messagingSenderId: "933667639572",
    appId: "1:933667639572:web:afcd53aafe2e3f1405b201",
    measurementId: "G-E9YYKMPD3J"
};

// Initialize app
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// EXPOSE EVERYTHING GLOBALLY
window.db = db;
window.auth = auth;

window.collection = collection;
window.addDoc = addDoc;
window.getDocs = getDocs;
window.getDoc = getDoc;
window.setDoc = setDoc;
window.updateDoc = updateDoc;
window.deleteDoc = deleteDoc;
window.doc = doc;

window.signInWithEmailAndPassword = signInWithEmailAndPassword;
window.createUserWithEmailAndPassword = createUserWithEmailAndPassword;
window.onAuthStateChanged = onAuthStateChanged;
window.signOut = signOut;
