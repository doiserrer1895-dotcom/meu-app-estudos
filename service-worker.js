// SERVICE WORKER: mantém arquivos essenciais disponíveis offline e atualiza o cache quando a versão muda.
const CACHE_NAME = "meu-app-estudos-shell-v38";
const BASE = "/meu-app-estudos/";
const SHELL = [BASE, BASE + "index.html", BASE + "questoes.html", BASE + "nutricao.html", BASE + "constancia.html", BASE + "comunidade.html", BASE + "manifest.webmanifest", BASE + "icons/icon.svg", BASE + "assets/nutricao-card-square.svg"];
// Instala os arquivos essenciais de forma resiliente e ativa a nova versão do cache.
self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then(async (cache) => {\n    // Um arquivo opcional com falha não deve impedir a atualização do app inteiro.\n    await Promise.allSettled(SHELL.map(async (url) => {\n      try { const response = await fetch(url, { cache: "reload" }); if (response.ok) await cache.put(url, response); } catch (_) {}\n    }));\n  }).then(() => self.skipWaiting()));
});
// Remove caches antigos, preservando o banco de questões e assumindo controle imediato.
self.addEventListener("activate", (event) => {
  event.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== CACHE_NAME && key !== "eear-question-bank-cache-v1").map((key) => caches.delete(key)))).then(() => self.clients.claim()));
});
// Navegações buscam a versão publicada sem cache HTTP; em falha de rede, usam a cópia local.
self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET" || new URL(request.url).origin !== self.location.origin) return;
  if (request.mode === "navigate") {
    event.respondWith(fetch(request, { cache: "no-store" }).then((response) => {
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
