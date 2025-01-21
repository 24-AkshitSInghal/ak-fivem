window.addEventListener('message', function(event) {
    let data = event.data;

    switch (data.type) {
        case 'show':
            this.document.getElementById("control-panel").style.display = 'inline-block';
        break;
        case 'hide':
            this.document.getElementById("control-panel").style.display = 'none';
        break;
    }
});

document.onkeyup = function(data) {
    if(data.which == 27) { // ESC or I
        axios.post(`https://ak-controlui/hide`, {
            action: 'hide',
        });
    }
}

// Car Functions:
toggleEngine = function() {
    axios.post(`https://ak-controlui/toggleEngine`, {
        action: 'toggle',
    });
}

toggleFrontHood = function() {
    axios.post(`https://ak-controlui/toggleFrontHood`, {
        action: 'toggle',
    });
}

toggleTrunk = function() {
    axios.post(`https://ak-controlui/toggleTrunk`, {
        action: 'toggle',
    });
}

toggleHeadlights = function() {
    axios.post(`https://ak-controlui/toggleHeadlights`, {
        action: 'toggle',
    });
}

openDoor = function(index) {
    axios.post(`https://ak-controlui/openDoor`, {
        action: 'open',
        doorIndex: index,
    });
}

openWindow = function(index) {
    axios.post(`https://ak-controlui/openWindow`, {
        action: 'open',
        windowIndex: index,
    });
}

sitAtSeat = function(index) {
    axios.post(`https://ak-controlui/sitAtSeat`, {
        action: 'sit',
        seatIndex: index,
    });
}

 document.addEventListener("keydown", function(event) {
            if (event.key === "Tab") {
                event.preventDefault();
                 axios.post(`https://ak-controlui/hide`, {
                    action: 'hide',
                });
            }
});