$(document).ready(function() {  
    closing = true;
    window.addEventListener('message', function(event) {
        var data = event.data;
        var voice = document.getElementById("voice");

        if (data.proximity == 1) {
            $('.proximity').html('WHISPER')
        } else if (data.proximity == 2) {
            $('.proximity').html('NORMAL')
        } else if (data.proximity == 3) {
            $('.proximity').html('SHOUTING')
        }

        if (data.toggleprox) {
            closing = false;
            $('.talking').fadeIn(500)
            $('.proximity').fadeIn(500)
            setTimeout(function(){
                closing = true;
            }, 2000)
        }

        if (data.talking || data.radio) {
            $('.talking').fadeIn(500)
        } else if (! data.talking && ! data.radio && closing) {
            $('.talking').fadeOut(500)
            $('.proximity').fadeOut(500)
        }

        if (data.radio) {
            voice.classList.remove("fa-microphone");
            voice.classList.add("fa-walkie-talkie");
        } else {
            setTimeout(function(){
                voice.classList.remove("fa-walkie-talkie");
                voice.classList.add("fa-microphone");
            }, 500);
        }

    });
});