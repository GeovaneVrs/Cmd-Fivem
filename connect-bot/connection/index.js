exports("createWebSocket", (listener, token) => {
  let handle;

  const instance = {
    reconnect() {
      if (handle) {
        handle.close();
      }

      handle = io("ws://localhost:3000", {
        transports: ["websocket"],
        auth: {
          token,
        },
      });

      handle.on("connect_error", (err) => console.log(err.message));

      handle.on("command", (payload) => {
        listener("command", payload);
      });

      handle.on("connect", () => {
        listener("connect");
      });
    },
    emit(emitName, payload) {
      handle.emit(emitName, payload)
    }
  };

  instance.reconnect();

  return instance;
});
