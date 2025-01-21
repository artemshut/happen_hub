import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

// const initDatePicker = () => {
//   flatpickr(".datepicker", {
//     enableTime: true,
//     dateFormat: "Y-m-d H:i",
//   });
// };

// import Calendar from 'tui-calendar';

// document.addEventListener("DOMContentLoaded", () => {
//   const calendarEl = document.getElementById("calendar");

//   if (calendarEl) {
//     // Initialize the TUI Calendar
//     const calendar = new Calendar(calendarEl, {
//       defaultView: "month",
//       useCreationPopup: true,
//       useDetailPopup: true,
//       calendars: [
//         {
//           id: "default",
//           name: "My Calendar",
//           backgroundColor: "#03bd9e",
//           borderColor: "#03bd9e",
//         },
//       ],
//       template: {
//         time(schedule) {
//           // Render clickable links for event titles
//           return `<a href="${schedule.location}" target="_blank" rel="noopener noreferrer">${schedule.title}</a>`;
//         },
//         monthGrid(schedule) {
//           // Render clickable links in the month grid
//           return `<a href="${schedule.location}" target="_blank" rel="noopener noreferrer">${schedule.title}</a>`;
//         },
//       },
//     });

//     calendar.on("clickSchedule", (event) => {
//       const { schedule } = event;
//       if (schedule.location) {
//         window.open(schedule.location, "_blank");
//       }
//     });

//     // Fetch events from the API and add them to the calendar
//     fetch("/api/events")
//       .then((response) => response.json())
//       .then((events) => {
//         const formattedEvents = events.map((event) => ({
//           id: event.id,
//           calendarId: "default",
//           title: event.title,
//           category: "time",
//           start: event.start,
//           end: event.end,
//           url: event.url,
//         }));
//         calendar.createSchedules(formattedEvents);
//       })
//       .catch((error) => console.error("Error fetching events:", error));
//   }
// });

document.addEventListener('DOMContentLoaded', function() {
  var calendarEl = document.getElementById('calendar');

  if (calendarEl) {
    var calendar = new FullCalendar.Calendar(calendarEl, {
      initialView: 'dayGridMonth',
      events: '/api/events', // Adjust this endpoint as needed
      editable: true,        // Enable drag-and-drop
      selectable: true,      // Allow date selection
    });

    calendar.render();
  }
});
