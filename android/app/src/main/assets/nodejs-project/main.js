bridge.on('run', async ({ code, input }) => {

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

    bridge.send('ok', ctx.result);

  } catch (e) {
    bridge.send('error', e.toString());
  }
});