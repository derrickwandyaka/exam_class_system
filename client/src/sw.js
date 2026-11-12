import { cleanupOutdatedCaches, precacheAndRoute } from 'workbox-precaching';

precacheAndRoute(self.__WB_MANIFEST);
cleanupOutdatedCaches();

self.addEventListener('push', (event) => {
  let payload = {};
  try {
    payload = event.data ? event.data.json() : {};
  } catch {
    payload = { body: event.data?.text() || '' };
  }

  const title = typeof payload.title === 'string' && payload.title.trim()
    ? payload.title
    : 'University Portal';
  const options = {
    body: typeof payload.body === 'string' ? payload.body : '',
    icon: '/icon.svg',
    badge: '/icon.svg',
    data: {
      url: typeof payload.data?.url === 'string' ? payload.data.url : '/'
    }
  };
  if (typeof payload.tag === 'string') options.tag = payload.tag;
  if (typeof payload.requireInteraction === 'boolean') {
    options.requireInteraction = payload.requireInteraction;
  }

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const target = new URL(event.notification.data?.url || '/', self.location.origin);
  if (target.origin !== self.location.origin) target.href = self.location.origin;

  event.waitUntil((async () => {
    const windows = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    const existing = windows.find((client) => new URL(client.url).origin === self.location.origin);
    if (existing) {
      await existing.navigate(target.href);
      return existing.focus();
    }
    return self.clients.openWindow(target.href);
  })());
});
