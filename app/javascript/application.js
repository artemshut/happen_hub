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

import Calendar from 'tui-calendar';

document.addEventListener('turbo:load', () => {
  const calendarEl = document.getElementById('calendar');

  if (calendarEl) {
    const calendar = new Calendar(calendarEl, {
      defaultView: 'month', // Options: day, week, month
      taskView: true,       // Show the task view
      scheduleView: true,   // Show the schedule view
      useDetailPopup: true, // Show a popup when clicking events
    });

    // Example schedules
    calendar.createSchedules([
      {
        id: '1',
        calendarId: '1',
        title: 'Meeting',
        category: 'time',
        dueDateClass: '',
        start: '2025-01-20T10:00:00',
        end: '2025-01-20T12:00:00',
      },
    ]);
  }
});
