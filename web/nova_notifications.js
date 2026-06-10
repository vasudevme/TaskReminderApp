/**
 * Nova Tasks – Web Push Notification Helper
 * Injected by index.html before the Flutter app starts.
 * Flutter calls window.showNovaPushNotification(title, body) 
 * from the notification service.
 */
(function () {
  // Request permission as soon as user interacts with the page
  function requestPermissionOnInteraction() {
    if (Notification.permission === 'default') {
      document.addEventListener('click', function onFirstClick() {
        Notification.requestPermission();
        document.removeEventListener('click', onFirstClick);
      }, { once: true });
    }
  }

  if ('Notification' in window) {
    requestPermissionOnInteraction();
  }

  // Global function called by Flutter's notification service
  window.showNovaPushNotification = function (title, body) {
    if (!('Notification' in window)) {
      console.warn('[Nova] Browser does not support notifications.');
      return;
    }
    if (Notification.permission === 'granted') {
      new Notification(title, {
        body: body,
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
        tag: 'nova-task-reminder',
      });
    } else if (Notification.permission === 'default') {
      Notification.requestPermission().then(function (permission) {
        if (permission === 'granted') {
          new Notification(title, {
            body: body,
            icon: '/icons/Icon-192.png',
            tag: 'nova-task-reminder',
          });
        }
      });
    }
  };
})();
