window.addEventListener('message', (e) => {
    const coords = JSON.stringify(e.data)
    const coordsObject = JSON.parse(coords);

    if (coordsObject.type == 'coords'){
        document.getElementById('pos-head').textContent = `heading: ${coordsObject.heading.toFixed(3)}` ;
        document.getElementById('pos-x').textContent = `x: ${coordsObject.x.toFixed(3)}`;
        document.getElementById('pos-y').textContent = `y: ${coordsObject.y.toFixed(3)}`;
        document.getElementById('pos-z').textContent = `z: ${coordsObject.z.toFixed(3)}`;
    }
})

window.addEventListener('message', (e) => {
    const data = e.data; // Use e.data directly, no need to stringify
    const state = data.state;
    if (data.type === 'toggle') {
        if (state) {
            document.getElementById('location-window').style.opacity = 1; // Set opacity to 100%
        } else {
            document.getElementById('location-window').style.opacity = 0; // Set opacity to 0%
        }
    }
});