import { Socket } from "phoenix";

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.onError(err => { console.log(err) });

socket.connect()

let channel = socket.channel("room:cartographers:" + window.gameId, {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) });

channel.on("event_joined", msg => { console.log(msg);});
channel.on("start", msg => console.log(msg));
channel.on("quit", msg => console.log(msg));
channel.on("act", msg => console.log(msg));

window.ch = channel;