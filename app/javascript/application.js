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

document.addEventListener("turbo:load", () => {
  const calendarEl = document.getElementById("calendar");

  if (calendarEl) {
    const calendar = new FullCalendar.Calendar(calendarEl, {
      plugins: [FullCalendar.globalPlugins[7], FullCalendar.globalPlugins[6]],
      initialView: "dayGridMonth",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,dayGridWeek,dayGridDay",
      },
      events: "/api/events", // Replace with your API endpoint
      editable: true,
      selectable: true,
      eventColor: "#f56565", // Default event color (red-ish)
      eventTextColor: "#ffffff", // White text for events
      eventClick: function (info) {
        window.location.href = info.event.url; // Redirect to the event's page
      },
      eventDidMount: function (info) {
        // Add custom tooltip or style
        info.el.style.borderRadius = "8px"; // Rounded corners for events
        info.el.style.padding = "2px 5px"; // Smaller padding
        info.el.style.border = "0px"; // No border
        info.el.style.fontSize = "0.75rem"; // Smaller text
        info.el.style.fontWeight = "600"; // Bold text for events
        info.el.style.backgroundColor = info.event.extendedProps.color;
      },
      dayCellDidMount: function (info) {
        // Hover effect for day cells
        info.el.classList.add("hover:bg-gray-100", "transition");
      },
      dateClick: function (info) {
        // Redirect to create an event
        window.location.href = `/events/new?start_date=${info.dateStr}`;
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

document.addEventListener("turbo:load", () => {
  const tabButtons = document.querySelectorAll(".tab-btn");
  const tabContents = document.querySelectorAll(".tab-content");

  tabButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const targetId = btn.getAttribute("data-tab");

      // Deactivate all tabs
      tabButtons.forEach((b) => b.classList.remove("active"));
      tabContents.forEach((content) => content.classList.add("hidden"));

      // Activate the selected tab
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
