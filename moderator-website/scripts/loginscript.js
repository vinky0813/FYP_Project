document.getElementById("loginForm").addEventListener("submit", function(event) {
    console.log("Script loaded");

    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;


    if (password.length < 6) {
        alert('Password must be at least 6 characters long.');
        event.preventDefault();
        return;
    }

    // login api here

    console.log("redirecting");

    window.location.href = "homepage.html";
    event.preventDefault();
});

