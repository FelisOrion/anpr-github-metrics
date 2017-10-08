// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("metrics:lobby", {})
let url = $('#url');

url.on('keypress', event => {
  if (event.keyCode == 13) {
    console.log("push");
    channel.push("stato", { url: url.val() });
    channel.push("lista", { url: url.val() });
  }
});

let url_btn = $('#url_btn');

url_btn.on('click', event => {
    console.log("push");
    channel.push("stato", { url: url.val() });
    channel.push("lista", { url: url.val() });
    channel.push("resptime", { url: url.val() });
    channel.push("closetime", { url: url.val() });
    channel.push("info", {url: url.val() });
    url.val('');
});


/**
 * Questa funzione intercetta i dati che servono per i grafici e li imposta
 */
channel.on("resptime", pl => {
    console.log("resptime", pl);
    var onlyOpen = [];
    var tmp1 = {};
    var tmp2 = 1;
    var totTime = 0;
    var rangeOpen = [];

    for(var i in pl.list) {
      tmp1 = pl.list[i];

      if(tmp1.time) {
        onlyOpen.push(tmp1.time);
        rangeOpen.push("IS " + tmp2++);
      };

      totTime += tmp1.time;
    };

    media = totTime / pl.list.length;

    new Chart(document.getElementById("chartjs-0b"), {
      type: 'line',
      data: {
        labels: rangeOpen,
        datasets: [{
            label: "Issues tempo risposta",
            data: onlyOpen,
            fill: false,
            borderColor: "rgb(54, 162, 235)",
            lineTension: 0.1
        }, {
            label: "Media tempo risposta",
            data: [media],
            fill: false,
            lineTension: 0.1
        }]
      },
      options: {}
    });
});
channel.on("closetime", pl => {
  console.log(pl);
});

channel.on("info", pl => {
  console.log(pl);
});


/**
 * Questa funzione intercetta i dati che servono per i grafici e li imposta
 */
channel.on("stato", pl => {
  console.log('STATO', pl);

  new Chart(document.getElementById("chartjs-4b"), {
      type: "doughnut",
      data: {
          labels: ["Aperte", "Chiuse"],
          datasets: [{
              label: "Issues",
              data: [pl.aperte, pl.chiuse],
              backgroundColor: ["rgb(54, 162, 235)", "rgb(255, 99, 132)"]
          }]
      }
  });
});

/**
 * Questa funzione intercetta la lista e visualizza la lista di issues
 */
channel.on("lista", pl => {
  console.log('LISTA', pl);
});

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })


export default socket
