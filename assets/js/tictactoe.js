import { Socket } from "phoenix";
import * as d3 from "d3";

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.onError(err => { console.log(err) });

socket.connect()

let channel = socket.channel("room:" + window.gameId, {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) });

channel.on("event_joined", msg => { console.log(msg); redrawBoard(msg.board) });
channel.on("start", msg => console.log(msg));
channel.on("quit", msg => console.log(msg));
channel.on("draw", msg => redrawBoard(msg.board));

document.getElementById("start").onclick = event => {
  channel.push("start");
};

document.getElementById("quit").onclick = event => {
  channel.push("quit");
};

let board = ['', '', '', '', '', '', '', '', ''];

const enter = d3.select("#tic-tac-toe-svg")
  .selectAll("rect")
  .data(board)
  .enter();
enter.insert("rect", ":first-child")
  .attr('x', (_, i) => 33 * (i % 3))
  .attr('y', (_, i) => 33 * y(i))
  .attr('width', 33)
  .attr('height', 33)
  .on('click', (d, i) => channel.push("draw", { "position": i + 1 }));
enter.append("g");

function redrawBoard(board) {
  const winningPositions = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];
  const winningIndices = winningPositions.find(indices => {
    const marks = indices.map(i => board[i]).filter(mark => mark != " ");
    if (marks.length != 3) {
      return false;
    }
    return new Set(marks).size === 1;
  });
  const winningIndicesSet = winningIndices === null ? new Set() : new Set(winningIndices);

  d3.select("#tic-tac-toe-svg")
    .selectAll("g")
    .data(board)
    // preserves index (filters changes index)
    .select(function (d) { return d == 'x' ? this : null })
    .html((d, i) => `
      <line class="${winningIndicesSet.has(i) ? "winning" : ""}" x1="${33 * (i % 3) + 11}" x2="${33 * (i % 3) + 22}" y1="${33 * y(i) + 11}" y2="${33 * y(i) + 22}"></line>
      <line class="${winningIndicesSet.has(i) ? "winning" : ""}" x1="${33 * (i % 3) + 11}" x2="${33 * (i % 3) + 22}" y1="${33 * y(i) + 22}" y2="${33 * y(i) + 11}"></line>
    `);

  d3.select("#tic-tac-toe-svg")
    .selectAll("g")
    .data(board)
    // preserves index (filters changes index)
    .select(function (d) { return d == 'o' ? this : null })
    .html((d, i) => `
        <circle class="${winningIndicesSet.has(i) ? "winning" : ""}" cx="${33 * (i % 3) + 15}" cy="${33 * y(i) + 15}" r="${Math.sqrt(2) * 33 / 6}"></circle>
    `);
}

function y(i) {
  if (i < 3) {
    return 0;
  } else if (i < 6) {
    return 1;
  } else {
    return 2;
  }
}

export default socket
