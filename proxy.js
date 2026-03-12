const http = require('http');
const https = require('https');

const OPENROUTER_KEY = process.env.OPENROUTER_API_KEY;
if (!OPENROUTER_KEY) {
  console.error('❌ OPENROUTER_API_KEY environment variable is not set.');
  console.error('   Copy .env.example to .env and fill in your key, then:');
  console.error('   source .env && node proxy.js');
  process.exit(1);
}

const PORT = parseInt(process.env.PORT || '3456', 10);

console.log('🚀 Starting Claude Code Router...');
console.log(`📍 Port: ${PORT}`);
console.log(`🎯 Target: OpenRouter`);

const server = http.createServer((clientReq, clientRes) => {
  const startTime = Date.now();
  const requestId = Math.random().toString(36).substr(2, 9);

  console.log(`[${new Date().toISOString()}] ${requestId} → ${clientReq.method} ${clientReq.url}`);

  // Remove /v1 prefix since OpenRouter base URL already includes /api/v1
  const path = clientReq.url.startsWith('/v1/') ? clientReq.url.substring(3) : clientReq.url;
  const targetUrl = 'https://openrouter.ai/api/v1' + path;

  const proxyReq = https.request(targetUrl, {
    method: clientReq.method,
    headers: {
      'Authorization': `Bearer ${OPENROUTER_KEY}`,
      'Content-Type': clientReq.headers['content-type'] || 'application/json',
      'Accept': clientReq.headers['accept'] || 'application/json',
      'User-Agent': 'claude-code-router/1.0',
      'HTTP-Referer': `http://localhost:${PORT}`,
      'X-Title': 'Claude-Code-Router'
    }
  });

  proxyReq.on('response', (proxyRes) => {
    clientRes.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(clientRes);

    const duration = Date.now() - startTime;
    console.log(`[${new Date().toISOString()}] ${requestId} ← ${proxyRes.statusCode} (${duration}ms)`);
  });

  proxyReq.on('error', (err) => {
    console.error(`[${new Date().toISOString()}] ${requestId} ✗ ERROR: ${err.message}`);
    clientRes.writeHead(500, { 'Content-Type': 'application/json' });
    clientRes.end(JSON.stringify({
      error: {
        type: 'api_error',
        message: `Proxy error: ${err.message}`
      }
    }));
  });

  clientReq.pipe(proxyReq);
});

server.listen(PORT, '127.0.0.1', () => {
  console.log('');
  console.log(`✅ Claude Code Router listening on http://127.0.0.1:${PORT}`);
  console.log('');
  console.log('🔧 To use with Claude Code, set these environment variables:');
  console.log('');
  console.log('   export ANTHROPIC_API_KEY="any-string-is-ok"');
  console.log(`   export ANTHROPIC_BASE_URL="http://127.0.0.1:${PORT}"`);
  console.log('');
  console.log('   Then run: claude');
  console.log('');
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is already in use!`);
    process.exit(1);
  } else {
    console.error('❌ Server error:', err);
    process.exit(1);
  }
});

process.on('SIGINT', () => {
  console.log('\n\n🛑 Shutting down gracefully...');
  server.close(() => {
    console.log('✅ Server stopped');
    process.exit(0);
  });
});
