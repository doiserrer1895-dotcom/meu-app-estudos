// SERVICE WORKER: mantém arquivos essenciais disponíveis offline e atualiza o cache quando a versão muda.
const CACHE_NAME = "meu-app-estudos-shell-v22";
const BASE = "/meu-app-estudos/";
const SHELL = [BASE, BASE + "index.html", BASE + "nutricao.html", BASE + "constancia.html", BASE + "comunidade.html", BASE + "manifest.webmanifest", BASE + "icons/icon.svg", BASE + "assets/nutricao-card-square.svg"];
// Instala o pacote básico do aplicativo e ativa a nova versão do cache.
self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(SHELL)).then(() => self.skipWaiting()));
});
// Remove caches antigos para evitar que telas desatualizadas continuem sendo servidas.
self.addEventListener("activate", (event) => {
  event.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key)))).then(() => self.clients.claim()));
});
// Navegações tentam buscar a versão publicada; em falha de rede, usam a cópia em cache.
self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET" || new URL(request.url).origin !== self.location.origin) return;
  if (request.mode === "navigate") {
    event.respondWith(fetch(request).then((response) => {
      if (response.ok) { const copy = response.clone(); caches.open(CACHE_NAME).then((cache) => cache.put(request, copy)); }
      return response;
    }).catch(() => caches.match(request).then((cached) => cached || caches.match(BASE))));
  } else {
    event.respondWith(caches.match(request).then((cached) => cached || fetch(request).then((response) => {
      if (response.ok) { const copy = response.clone(); caches.open(CACHE_NAME).then((cache) => cache.put(request, copy)); }
      return response;
    })));
  }
});
