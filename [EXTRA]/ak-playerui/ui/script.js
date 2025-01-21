$(document).ready(function() {
    var previousHealth = 100;

    window.addEventListener('message', function(event) {
        var data = event.data;
        var currentHealth = data.health;

        if (data.toggle == true) {
            $('.hud-container').css('opacity', '1');
            $('#health').css('width', data.health + '%');
            $('#armour').css('width', data.armour + '%');
            $('#hunger').css('width', data.hunger + '%');
            $('#thirst').css('width', data.thirst + '%');
        } else if (data.toggle == false) {
            $('.hud-container').css('opacity', '0');
        }

        if (data.action == 'inveh') {
            $('#hunger-hud').css('bottom', '9.3vw');
            $('#thirst-hud').css('bottom', '9.3vw');
        } else if (data.action == 'notinveh') {
            $('#hunger-hud').css('bottom', '0vw');
            $('#thirst-hud').css('bottom', '0vw');
        }

        // Highlight health in red if it decreases
        if (currentHealth < previousHealth) {
            $('#health').addClass('highlight-red');
            setTimeout(function() {
                $('#health').removeClass('highlight-red');
            }, 500); // Adjust the duration of the highlight as needed
        }

        if (currentHealth > previousHealth) {
            $('#health').addClass('highlight-green');
            setTimeout(function() {
                $('#health').removeClass('highlight-green');
            }, 200); // Adjust the duration of the highlight as needed
        }

        previousHealth = currentHealth;

        if (data.health && data.config.health && data.health < data.config.health) {
            fadeHUD('In', 'health');
        } else {
            fadeHUD('Out', 'health');
        }
        if (data.armour && data.config.armour && data.armour > data.config.armour) {
            fadeHUD('In', 'armour');
        } else {
            fadeHUD('Out', 'armour');
        }
        if (data.hunger && data.config.hunger && data.hunger < data.config.hunger) {
            fadeHUD('In', 'hunger');
        } else {
            fadeHUD('Out', 'hunger');
        }
        if (data.thirst && data.config.thirst && data.thirst < data.config.thirst) {
            fadeHUD('In', 'thirst');
        } else {
            fadeHUD('Out', 'thirst');
        }
        
        if (data.stress && data.config.stress && data.stress > data.config.stress) {
            $(`#stress-hud`).css("opacity", "1");
        } else {
             $(`#stress-hud`).css("opacity", "0");
        }

        // @functions

        function fadeHUD(type, hud) {
            if (type == 'Out') {
                $(`#${hud}-hud`).css("opacity", "0.4");
            } else if (type == 'In') {
                $(`#${hud}-hud`).css("opacity", "1");
            }
        }
    });
});
