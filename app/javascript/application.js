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


document.addEventListener('turbo:load', function() {
  var calendarEl = document.getElementById('calendar');

  if (calendarEl) {
    var calendar = new FullCalendar.Calendar(calendarEl, {
      plugins: [FullCalendar.globalPlugins[7], FullCalendar.globalPlugins[6]],
      initialView: 'dayGridMonth',
      events: '/api/events', // Adjust this endpoint as needed
      editable: true,        // Enable drag-and-drop
      selectable: true,      // Allow date selection
      eventDidMount: (info) => {
        info.el.style.backgroundColor = info.event.extendedProps.color;
      },
      eventClick: function(info) {
        window.location.href = info.event.url;
      },
      dateClick: function (info) {
        // Redirect to the New Event form, passing the clicked date as a parameter
        const date = info.dateStr; // e.g., "2025-01-20"
        window.location.href = `/events/new?date=${date}`;
      },
    });

    calendar.render();
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

document.addEventListener("turbo:load", function () {
  const dropdowns = document.querySelectorAll(".group");

  dropdowns.forEach((dropdown) => {
    const menu = dropdown.querySelector(".group-hover\\:block");
    dropdown.addEventListener("mouseleave", () => {
      setTimeout(() => {
        if (!dropdown.matches(":hover")) {
          menu.classList.add("hidden");
        }
      }, 50); // Adjust delay as needed
    });

    dropdown.addEventListener("mouseenter", () => {
      menu.classList.remove("hidden");
    });
  });
});
