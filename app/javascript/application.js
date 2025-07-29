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
      plugins: [
        FullCalendar.globalPlugins[7], // dayGridPlugin
        FullCalendar.globalPlugins[6], // interactionPlugin
      ],
      initialView: "dayGridMonth",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,dayGridWeek,dayGridDay",
      },
      events: "/api/events", // Your API endpoint

      editable: true,
      selectable: true,
      eventDisplay: "block",
      dayMaxEventRows: true,

      // General styling
      eventColor: "#E34717", // fallback color
      eventTextColor: "#ffffff",

      eventClick: function (info) {
        window.location.href = info.event.url;
      },

      eventDidMount: function (info) {
        const el = info.el;
        el.style.backgroundColor = info.event.extendedProps.color || "#E34717"; // brand.DEFAULT fallback
        el.style.border = "none";
        el.style.borderRadius = "0.5rem";
        el.style.padding = "4px 6px";
        el.style.fontSize = "0.75rem";
        el.style.fontWeight = "600";
        el.classList.add(
          "hover:scale-[1.02]",
          "hover:shadow-md",
          "transition-all",
          "duration-150",
          "ease-in-out"
        );
      },

      dayCellDidMount: function (info) {
        info.el.classList.add("hover:bg-neutral-100", "transition-colors", "duration-200");
      },

      dateClick: function (info) {
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