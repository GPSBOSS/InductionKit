import "./firestore.js";
import {
    onAuthStateChanged,
    signOut
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";
import {
    getDoc,
    doc
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore.js";

onAuthStateChanged(auth, async (user) => {

    if (!user) {
        window.location.href = "login.html";
        return;
    }

    const adminRef = doc(db, "admins", user.uid);
    const adminSnap = await getDoc(adminRef);

    if (!adminSnap.exists()) {
        await signOut(auth);
        window.location.href = "login.html";
        return;
    }

    // Show superadmin menu item
    const data = adminSnap.data();
    if (data.role === "superadmin") {
        const link = document.getElementById("createAdminLink");
        if (link) link.style.display = "block";
    }
});

window.logout = async () => {
    await signOut(auth);
    window.location.href = "login.html";
};
