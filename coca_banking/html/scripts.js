// Functions to format numbers with gaps or commas
function addGaps(nStr) {
    nStr = nStr.toString();
    var parts = nStr.split('.');
    var integerPart = parts[0];
    var decimalPart = parts.length > 1 ? '.' + parts[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(integerPart)) {
        integerPart = integerPart.replace(rgx, '$1<span style="margin-left: 3px; margin-right: 3px;"/>$2');
    }
    return integerPart + decimalPart;
}

function addCommas(nStr) {
    nStr = nStr.toString();
    var parts = nStr.split('.');
    var integerPart = parts[0];
    var decimalPart = parts.length > 1 ? '.' + parts[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(integerPart)) {
        integerPart = integerPart.replace(rgx, '$1,<span style="margin-left: 0px; margin-right: 1px;"/>$2');
    }
    return integerPart + decimalPart;
}

// Document ready function
$(document).ready(function () {
    // Helper functions for opening and closing elements
    function closeMain() {
        $(".home").hide();
    }

    function openMain() {
        $(".home").show();
    }

    function closeAll() {
        $(".body").hide();
    }

    function openBalance() {
        $(".balance-container").show();
    }

    function openWithdraw() {
        $(".withdraw-container").show();
    }

    function openDeposit() {
        $(".deposit-container").show();
    }

    function openTransfer() {
        $(".transfer-container").show();
    }

    function openContainer() {
        $(".bank-container").show();
    }

    function closeContainer() {
        $(".bank-container").hide();
    }

    // Event listener for messages
    window.addEventListener('message', function (event) {
        var item = event.data;

        // Update HUD Balance
        if (item.ShowBank) {
            console.log(item.balance)
            $('.balance').hide();
            if (item.show !== false) {
                $('.balance').show();
            }
            $('.balance').html('<p id="balance"><img id="icon" src="bank-icon.png" alt=""/>' + addGaps(item.balance) + '</p>');
            if (item.show !== false) {
                setTimeout(function () {
                    $('.balance').fadeOut(600);
                }, 4000);
            }
        }

        if (item.ShowCash) {
            $('.cash').hide();
            if (item.show !== false) {
                $('.cash').show();
            }
            $('.cash').html('<p id="cash"><span class="green"> $ </span>' + addGaps(item.cash) + '</p>');
            if (item.show !== false) {
                setTimeout(function () {
                    $('.cash').fadeOut(600);
                }, 4000);
            }
        }

        // Trigger Add Balance Popup
        if (item.addBalance) {
            $('.transaction').show();
            var element = $('<p id="add-balance"><span class="pre">+</span><span class="green"> $ </span>' + addGaps(item.amount) + '</p>');
            $(".transaction").append(element);
            setTimeout(function () {
                $(element).fadeOut(600, function () { $(this).remove(); });
            }, 2000);
        }

        // Trigger Remove Balance Popup
        if (item.removeBalance) {
            $('.transaction').show();
            var element = $('<p id="add-balance"><span class="pre">-</span><span class="red"> $ </span>' + addGaps(item.amount) + '</p>');
            $(".transaction").append(element);
            setTimeout(function () {
                $(element).fadeOut(600, function () { $(this).remove(); });
            }, 2000);
        }

        // Trigger Add Cash Popup
        if (item.addCash) {
            $('.cashtransaction').show();
            var element = $('<p id="add-balance"><span class="pre">+</span><span class="green"> $ </span>' + addGaps(item.amount) + '</p>');
            $(".cashtransaction").append(element);
            setTimeout(function () {
                $(element).fadeOut(600, function () { $(this).remove(); });
            }, 2000);
        }

        // Trigger Remove Cash Popup
        if (item.removeCash) {
            $('.cashtransaction').show();
            var element = $('<p id="add-balance"><span class="pre">-</span><span class="red"> $ </span>' + addGaps(item.amount) + '</p>');
            $(".cashtransaction").append(element);
            setTimeout(function () {
                $(element).fadeOut(600, function () { $(this).remove(); });
            }, 2000);
        }

        // Open & Close main bank window
        if (item.openBank === true) {

            openContainer();
            openMain();
        }

        if (item.refreshheader === true) {
            let balance = item.currentBalance;
            let name = item.name;

            // Update the username and current balance elements
            $('.username').html(name);
            $('.currentBalance').html('$' + addCommas(balance));
        }

        if (item.openBank === false) {
            closeContainer();
            closeMain();
        }

        // Open sub-windows / partials
        if (item.openSection) {
            closeAll();
            switch (item.openSection) {
                case "withdraw":
                    openWithdraw();
                    break;
                case "deposit":
                    openDeposit();
                    break;
                case "transfer":
                    openTransfer();
                    break;
            }
        }
    });

    // On 'Esc' call close method
    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post('https://coca_banking/close', JSON.stringify({}));
        }
    };

    // Handle Button Presses
    $(".btnWithdraw").click(function () {
        $.post('https://coca_banking/withdraw', JSON.stringify({}));
    });
    $(".btnDeposit").click(function () {
        $.post('https://coca_banking/deposit', JSON.stringify({}));
    });
    $(".btnTransfer").click(function () {
        $.post('https://coca_banking/transfer', JSON.stringify({}));
    });
    $(".btnClose").click(function () {
        $.post('https://coca_banking/close', JSON.stringify({}));
    });
    $(".btnHome").click(function () {
        closeAll();
        openMain();
    });

    // Handle Form Submits
    $("#withdraw-form").submit(function (e) {
        e.preventDefault();
        $.post('https://coca_banking/withdrawSubmit', JSON.stringify({
            amount: $("#withdraw-form #amount").val()
        }));
        $("#withdraw-form #amount").prop('disabled', true);
        $("#withdraw-form #submit").hide();
        setTimeout(function () {
            $("#withdraw-form #amount").prop('disabled', false);
            $("#withdraw-form #submit").show();
        }, 2000);
        $("#withdraw-form #amount").val('');
    });

    $("#deposit-form").submit(function (e) {
        e.preventDefault();
        $.post('https://coca_banking/depositSubmit', JSON.stringify({
            amount: $("#deposit-form #amount").val()
        }));
        $("#deposit-form #amount").prop('disabled', true);
        $("#deposit-form #submit").hide();
        setTimeout(function () {
            $("#deposit-form #amount").prop('disabled', false);
            $("#deposit-form #submit").show();
        }, 2000);
        $("#deposit-form #amount").val('');
    });

    $("#transfer-form").submit(function (e) {
        e.preventDefault();
        $.post('https://coca_banking/transferSubmit', JSON.stringify({
            amount: $("#transfer-form #amount").val(),
            toPlayer: $("#transfer-form #toPlayer").val()
        }));
        $("#transfer-form #amount").prop('disabled', true);
        $("#transfer-form #toPlayer").prop('disabled', true);
        $("#transfer-form #submit").hide();
        setTimeout(function () {
            $("#transfer-form #amount").prop('disabled', false);
            $("#transfer-form #submit").show();
            $("#transfer-form #toPlayer").prop('disabled', false);
        }, 2000);
        $("#transfer-form #amount").val('');
        $("#transfer-form #toPlayer").val('');
    });
});
