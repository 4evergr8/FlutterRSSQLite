const bridge = require('flutter-bridge');

console.log("Node.js started");

bridge.on('run', async (message) => {

  let payload;

  try {
    payload = JSON.parse(message);
  } catch (e) {
    bridge.send('error', 'JSON解析失败: ' + e.toString());
    return;
  }

  const code = payload.code || "";
  const input = payload.input || "";

  const ctx = {
    input,
    fetch,
    console,
    result: null
  };

  try {
    await new Function('ctx', `
      return (async () => {
        with (ctx) {
          ${code}
        }
      })();
    `)(ctx);

    bridge.send('ok', ctx.result ?? "");

  } catch (e) {
    bridge.send('error', e.toString());
  }
});