import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

document.addEventListener('turbo:load', function () {
  var dateInputs = document.querySelectorAll('.datepicker');

  if (dateInputs.length > 0) {
    dateInputs.forEach(function (input) {
      flatpickr(input, {
        enableTime: true,
        dateFormat: "Y-m-d H:i",
      });
    });
  }
});



document.addEventListener("turbo:load", function () {
  const flashMessages = document.querySelectorAll("#flash-messages .flash-message");

  flashMessages.forEach((message) => {
    setTimeout(() => {
      message.style.opacity = "0";
      setTimeout(() => {
        message.remove();
      }, 300); // Wait for fade-out before removing
    }, 5000); // Auto-dismiss after 5 seconds
  });
});

// document.addEventListener("turbo:load", function () {
//   const dropdowns = document.querySelectorAll(".group");

//   dropdowns.forEach((dropdown) => {
//     const menu = dropdown.querySelector(".group-hover\\:block");
//     dropdown.addEventListener("mouseleave", () => {
//       setTimeout(() => {
//         if (!dropdown.matches(":hover")) {
//           menu.classList.add("hidden");
//         }
//       }, 50); // Adjust delay as needed
//     });

//     dropdown.addEventListener("mouseenter", () => {
//       menu.classList.remove("hidden");
//     });
//   });
// });

document.addEventListener("turbo:load", () => {
  const tabButtons = document.querySelectorAll(".tab-btn");
  const tabContents = document.querySelectorAll(".tab-content");

  tabButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const targetId = btn.getAttribute("data-tab");

      tabButtons.forEach((b) => b.classList.remove("active"));
      tabContents.forEach((content) => content.classList.add("hidden"));

      btn.classList.add("active");
      document.getElementById(targetId).classList.remove("hidden");
    });
  });
});

document.addEventListener("turbo:load", () => {
  flatpickr(".datepicker-date", {
    altInput: true,
    altFormat: "F j, Y", // Display format (e.g., January 1, 2023)
    dateFormat: "Y-m-d", // Submission format (e.g., 2023-01-01)
  });
});

document.addEventListener("turbo:load", function () {
  const tabs = document.querySelectorAll(".tab-btn");
  const contents = document.querySelectorAll(".tab-content");

  tabs.forEach((tab) => {
    tab.addEventListener("click", function () {
      tabs.forEach((t) => t.classList.remove("active"));
      contents.forEach((c) => c.classList.add("hidden"));

      this.classList.add("active");
      document.getElementById(this.dataset.tab).classList.remove("hidden");
    });
  });
});
