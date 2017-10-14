// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

let channel = socket.channel("metrics:lobby", {})

channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

// Instanzio tutte le variabili che mi servono
let url_btn = $('#url_btn');
let url = $('#url');
let login_btn = $('#login-btn');
let name = $('#exampleInputEmail1');
let password = $('#exampleInputPassword1');
let defaultUrl = "https://github.com/italia/anpr";

// Funzione che richiede tramite socket varie informazioni al server
var channelsPush = function() {
    var tmpUrl = defaultUrl;

    if(url.val())
    tmpUrl = url.val();

    var data = {
        url: tmpUrl,
        name: name.val(),
        password: password.val()
    };

    console.log("PUSH INIT", tmpUrl);
    console.log("PUSH DATA", data);

    channel.push("stato", data);
    channel.push("info", data);
    channel.push("resptime", data);
    channel.push("closetime", data);
    channel.push("lista", data);

    $("#chartjs-7b").hide();
    $("#chartjs-gff").hide();
    $("#chartjs-0b").hide();
    $("#chartjs-4b").hide();

    $("#loading-7b").show();
    $("#loading-gff").show();
    $("#loading-0b").show();
    $("#loading-4b").show();

    console.log("PUSH FINISH");
};

// Fai un push ad inizio pagina
channelsPush();

// Intercetta eventi di cambio url repository
url.on('keypress', event => {
    if(event.keyCode == 13) {
        channelsPush();
    }
});
url_btn.on('click', event => {
    channelsPush();
    url.val('');
});
window.setDescr = function(el) {
    console.log('ELEMENT', el);
};

/**
* Questa funzione intercetta i dati che servono per i grafici e li imposta
*/
channel.on("resptime", pl => {
    console.log("resptime", pl);

    var onlyOpen = [];
    var tmp1 = {};
    var tmp2 = 1;
    var tmp3 = 0;
    var totTime = 0;
    var rangeOpen = [];

    for(var i in pl.resp) {
        tmp1 = pl.resp[i];

        if(tmp1.time) {
            tmp3 = Math.round(tmp1.time / 60);

            if(tmp3) {
                onlyOpen.push(tmp3);
                rangeOpen.push("SEGNALAZIONE " + tmp2++);
            }
        }

        totTime += Math.round(tmp1.time / 60);
    }

    var nMedia = 0;
    nMedia = Math.round(totTime / pl.resp.length);

    var aMedia = [];
    for(var b in onlyOpen) {
        aMedia.push(nMedia);
    }

    $('#loading-0b').hide();
    $('#chartjs-0b').show();

    if(window.CHART1)
        window.CHART1.destroy();

    window.CHART1 = new Chart(document.getElementById("chartjs-0b"), {
        type: 'bar',
        data: {
            labels: rangeOpen,
            datasets: [{
                label: "Tempo medio risposta (min)",
                data: aMedia,
                fill: false,
                borderColor: "rgb(255, 99, 132)",
                lineTension: 0.1,
                type: 'line'
            }, {
                label: "Tempo risposta (min)",
                data: onlyOpen,
                fill: false,
                backgroundColor: "rgb(54, 162, 235)",
                lineTension: 0.1
            }]
        },
        options: {  }
    });
});

channel.on("authentication", function(user) {
    console.log('CHANNEL GET PUSH:', user);
});

channel.on("closetime", pl => {
    console.log('closetime', pl);

    var onlyClose = [];
    var tmp1 = {};
    var tmp2 = 1;
    var tmp3 = 0;
    var totTime = 0;
    var rangeClose = [];

    for(var i in pl.close) {
        tmp1 = pl.close[i];

        tmp3 = Math.round(tmp1.time / 60);

        if(tmp3) {
            onlyClose.push(tmp3);
            rangeClose.push("SEGNALAZIONE " + tmp2++);
        }

        totTime += Math.round(tmp1.time / 60);
    }

    var nMedia = 0;
    nMedia = Math.round(totTime / pl.close.length);

    var aMedia = [];
    for(var b in onlyClose) {
        aMedia.push(nMedia);
    }

    $('#loading-gff').hide();
    $('#chartjs-gff').show();

    if(window.CHART2)
        window.CHART2.destroy();

    window.CHART2 = new Chart(document.getElementById("chartjs-gff"), {
        type: 'bar',
        data: {
            labels: rangeClose,
            datasets: [{
                label: "Tempo medio risposta (min)",
                data: aMedia,
                fill: false,
                borderColor: "rgb(255, 99, 132)",
                lineTension: 0.1,
                type: 'line'
            }, {
                label: "Tempo risposta (min)",
                data: onlyClose,
                fill: false,
                backgroundColor: "rgb(54, 162, 235)",
                lineTension: 0.1
            }]
        },
        options: {}
    });
});

channel.on("info", pl => {
    console.log('CHANNEL GET PUSH: INFO', pl);

    $('#loading-7b').hide();
    $('#chartjs-7b').show();

    if(window.CHART3)
        window.CHART3.destroy();

    window.CHART3 = new Chart(document.getElementById("chartjs-7b"), {
        type: "doughnut",
        data: {
            labels: ["Chiuse senza commenti", "Senza commenti", "Senza etichette"],
            datasets: [{
                label: "Issues",
                data: [pl.close_no_comments, pl.no_commentate, pl.no_labele],
                backgroundColor: ["rgb(54, 162, 235)", "rgb(255, 99, 132)", "rgb(255,255,0)"]
            }]
        }
    });
});


/**
* Questa funzione intercetta i dati che servono per i grafici e li imposta
*/
channel.on("stato", pl => {
    console.log('STATO', pl);

    $('body').bootstrapMaterialDesign();
    $('.collapse').collapse();
    $('#chartjs-4b').show();
    $('#loading-4b').hide();

    if(window.CHART4)
        window.CHART4.destroy();

    window.CHART4 = new Chart(document.getElementById("chartjs-4b"), {
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
    var table = $('#tableContent');
    var issue = {};
    var html = '';
    var btn = {};
    var stringDate = '';
    var YYYY = '';
    var MM = '';
    var DD = '';
    var DATE = '';

    btn.icon = function(icon) {
        var html = '';

        html  = '<i class="'+icon+'" >';
        html += "</i>";

        return html;
    };

    if(pl.issues.length) {
        table.empty();
    }

    for(var is in pl.issues) {
        issue = pl.issues[is];

        if(issue.state === 'open') {
            html  = "<tr>";
            html += "<td style='text-align:left'>" + issue.title + "</td>";

            html += "<td data-toggle='tooltip' title='Stato: aperto'>";
            html +=  btn.icon('ion-checkmark-round') + "</td>";
            //
            // if(issue.body.length > 200) {
            //     issue.body = issue.body.slice(0, 200) + '...';
            // }

            //html += "<td data-toggle=\"modal\" data-target=\"#modalIssueGithub\" data-descr=\""+issue.descr+"\" onclick='window.setDescr(this)'>";
            //html +=  btn.icon('ion-document-text') + "</td>";

            YYYY = moment(issue.created_at).year();
            MM = moment(issue.created_at).month();
            DD = moment(issue.created_at).day();
            DATE = DD +'/'+ MM +'/'+ YYYY;

            stringDate = "Creato il: " + DATE;

            YYYY = moment(issue.updated_at).year();
            MM = moment(issue.updated_at).month();
            DD = moment(issue.updated_at).day();
            DATE = DD +'/'+ MM +'/'+ YYYY;

            stringDate += "\nModificato il: " + DATE;

            html += "<td data-toggle='tooltip' title='"+stringDate+"'>" + btn.icon('ion-calendar') + "</td>";

            stringDate = "Visualizza su GitHub.com";
            html += "<td data-toggle='tooltip' title='"+stringDate+"'>";
            html += "<a href='" +issue.url+ "' target='_blank'>" + btn.icon('ion-social-github') + "</a></td>";

            html += "</tr>";

            table.append(html);
        }

        $('[data-toggle="tooltip"]').tooltip();
    }

    console.log('LISTA', pl);
});

export default socket


$(document).ready(function() {
    $(document).bootstrapMaterialDesign();
    $('.collapse').collapse();
});
