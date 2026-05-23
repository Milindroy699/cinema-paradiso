const { WebSocketServer } = require('ws');

const PORT = 8765;
const wss = new WebSocketServer({ port: PORT });
let currentSlide = 1;
const clients = new Set();

wss.on('connection', ws => {
  clients.add(ws);
  ws.send(JSON.stringify({ slide: currentSlide }));

  ws.on('message', data => {
    try {
      const { slide } = JSON.parse(data);
      if (typeof slide === 'number') {
        currentSlide = slide;
        for (const c of clients) {
          if (c !== ws && c.readyState === 1) c.send(JSON.stringify({ slide }));
        }
      }
    } catch (_) {}
  });

  ws.on('close', () => clients.delete(ws));
  ws.on('error', () => clients.delete(ws));
});

console.log(`\n✓ Sync server running on port ${PORT}`);
console.log(`\nNow run in a second terminal:`);
console.log(`  cloudflared tunnel --url http://localhost:${PORT}`);
console.log(`\nThen share viewer URL with audience:`);
console.log(`  https://milindroy699.github.io/cinema-paradiso/?ws=wss://YOUR-URL.trycloudflare.com`);
console.log(`\nYour controller URL:`);
console.log(`  https://milindroy699.github.io/cinema-paradiso/?remote=ctrl1&ws=wss://YOUR-URL.trycloudflare.com\n`);
