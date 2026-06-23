const bridge = require('flutter-bridge');

bridge.send('ok', 'started');

bridge.on('run', (msg) => {
  try {
    const fn = new Function('return (' + msg + ')');
    const result = fn();

    if (typeof result === 'function') {
      const out = result();

      if (out && typeof out.then === 'function') {
        out
          .then(r => bridge.send('ok', String(r)))
          .catch(e => bridge.send('error', String(e)));
      } else {
        bridge.send('ok', String(out));
      }
    } else {
      bridge.send('ok', String(result));
    }
  } catch (e) {
    bridge.send('error', String(e));
  }
});


