$(document).ready(function() {  
    window.addEventListener('message', function(event) {
        var data = event.data;

        if (data.toggle === true) {
            if (data.vel === undefined) {
                $(".vel").html('000');
            } else if (data.vel <= 9) {
                $(".vel").html('00' + data.vel);
            } else if (data.vel >= 10 && data.vel <= 99) {
                $(".vel").html('0' + data.vel);
            } else if (data.vel >= 100) {
                $(".vel").html(data.vel);
            }

            $('#fuel').html(' ' + data.fuel + '%');
            $('.kmh').html(data.type);
            
            if (data.fuel > 30) {
                $('#icon').css('color', 'green');
            } else {
                $('#icon').css('color', 'red');
            }

            $('.carhud-container').fadeIn(500);

            if (data.fuel < data.config) {
                $('.fuel').fadeIn(500);
            } else {
                $('.fuel').fadeOut(500);
            }

            // Handle seatbelt state separately
            if (data.seatbeltOn === false) {
                $('.seatbelt-container').fadeIn(500);
                $('.seatbelt-container').css('opacity', '0.75');
            } else {
                $('.seatbelt-container').fadeOut(500);
                $('.seatbelt-container').css('opacity', '0');
            }
        } else {
            $('.carhud-container').fadeOut(500);
            $('.seatbelt-container').fadeOut(500);
            $('.seatbelt-container').css('opacity', '0');
        }
    });
});
