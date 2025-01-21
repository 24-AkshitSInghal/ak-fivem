let characterData = null;

document.addEventListener("DOMContentLoaded", function () {
  const createCharacterButtons = document.querySelectorAll("#create-character");

  createCharacterButtons.forEach((button) => {
    const boxId = button.parentElement.id;
    const firstNameInput = document.querySelector(`#${boxId} #first-name`);
    const lastNameInput = document.querySelector(`#${boxId} #last-name`);
    const dobInput = document.querySelector(`#${boxId} #dob`);
    const backstoryInput = document.querySelector(`#${boxId} #backstory`);

    const inputs = [firstNameInput, lastNameInput, dobInput, backstoryInput];

    function checkInputs() {
      const allFilled = inputs.every((input) => input.value.trim() !== "");
      button.disabled = !allFilled;
      button.style.backgroundColor = allFilled ? "#4CAF50" : "rgb(54, 65, 54)";
    }

    inputs.forEach((input) => {
      input.addEventListener("input", checkInputs);
    });

    checkInputs();

    button.addEventListener("click", function () {
      const firstName = firstNameInput.value.trim();
      const lastName = lastNameInput.value.trim();
      const dob = dobInput.value.trim();
      const backstory = backstoryInput.value.trim();

      sendDataToServer(firstName, lastName, dob, backstory);
    });
  });

  function sendDataToServer(firstName, lastName, dob, backstory) {
    const data = {
      name: `${firstName} ${lastName}`,
      dob: dob,
      backstory: backstory,
    };
    console.log(dob);
    fetch("https://coca_spawnmanager/newCharacter", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    });
  }

  const deleteCharacterButtonsOne = document.querySelector(
    "#delete-character-1"
  );
  const deleteCharacterButtonsTwo = document.querySelector(
    "#delete-character-2"
  );

  let countdownTimerOne;

deleteCharacterButtonsOne.addEventListener("click", function () {
  // Check if the countdown is already running
  if (countdownTimerOne) {
    // If countdown is running, cancel it
    clearInterval(countdownTimerOne);
    countdownTimerOne = null;
    this.textContent = "Delete";
    return

  } else {
    if (characterData && characterData.length >= 1) {

      // Set initial countdown value
      let countdown = 10;

      // Update button text with initial countdown value
      this.textContent = countdown;

      // Start countdown timer
      countdownTimerOne = setInterval(() => {
        countdown--;
        if (countdown >= 0) {
          this.textContent = countdown;
        } else {
          // If countdown reaches zero, clear the interval, enable the button, and call the API
          clearInterval(countdownTimerOne);
          countdownTimerOne = null;
          this.textContent = "Delete";
          this.disabled = false;
          fetch("https://coca_spawnmanager/deleteCharacter", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify(characterData[0]),
          });
        }
      }, 1000);
    }
  }
});


   let countdownTimerTwo;

deleteCharacterButtonsTwo.addEventListener("click", function () {
  // Check if the countdown is already running
  if (countdownTimerTwo) {
    // If countdown is running, cancel it
    clearInterval(countdownTimerTwo);
    countdownTimerTwo = null;
    this.textContent = "Delete";
    return

  } else {
    if (characterData && characterData.length >= 2) {

      // Set initial countdown value
      let countdown = 10;

      // Update button text with initial countdown value
      this.textContent = countdown;

      // Start countdown timer
      countdownTimerTwo = setInterval(() => {
        countdown--;
        if (countdown >= 0) {
          this.textContent = countdown;
        } else {
          // If countdown reaches zero, clear the interval, enable the button, and call the API
          clearInterval(countdownTimerTwo);
          countdownTimerTwo = null;
          this.textContent = "Delete";
          this.disabled = false;
          fetch("https://coca_spawnmanager/deleteCharacter", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify(characterData[1]),
          });
        }
      }, 1000);
    }
  }
});

  const chooseCharacterButtonsOne = document.querySelector(
    "#choose-character-1"
  );
  const chooseCharacterButtonsTwo = document.querySelector(
    "#choose-character-2"
  );

  chooseCharacterButtonsOne.addEventListener("click", function () {
    console.log(characterData[0]);
    fetch("https://coca_spawnmanager/setMainCharacter", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(characterData[0]),
    });
  });

  chooseCharacterButtonsTwo.addEventListener("click", function () {
    if (characterData && characterData.length >= 2) {
      fetch("https://coca_spawnmanager/setMainCharacter", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(characterData[1]),
      });
    }
  });

  window.addEventListener("message", (e) => {
    if (e.data.type === "ui") {
      let status = e.data.status;
      if (status) {
        document.body.style.display = "block";
      } else {
        document.body.style.display = "none";
      }
    } else if (e.data.type === "refresh") {
      console.log(e.data.characters);
      const characterCount = e.data.characters.length;
      characterData = e.data.characters;
      console.log(characterCount);
      if (characterCount === 1) {
        document.getElementById("box-1").style.display = "none";
        document.getElementById("box-2").style.display = "block";
        document.getElementById("box-3").style.display = "block";
        document.getElementById("box-4").style.display = "none";
      } else if (characterCount === 2) {
        document.getElementById("box-1").style.display = "none";
        document.getElementById("box-2").style.display = "block";
        document.getElementById("box-3").style.display = "none";
        document.getElementById("box-4").style.display = "block";
      } else {
        document.getElementById("box-1").style.display = "block";
        document.getElementById("box-2").style.display = "none";
        document.getElementById("box-3").style.display = "block";
        document.getElementById("box-4").style.display = "none";
      }

      characterData.forEach((character, index) => {
        const boxId = index == 0 ? `box-2` : "box-4";
        const box = document.getElementById(boxId);
        if (box) {
          box.style.display = "block";
          box.querySelector("#data-name").innerText = character.name;
          box.querySelector("#data-dob").innerText = character.dob;
          box.querySelector("#data-backstory").innerText = character.backstory;
        }
      });
    } else if (e.data.type === "setspawns") {
      console.log("helo");
      const allSpawns = e.data.spawns;
      const spawnContainer = document.querySelector(".spawn-container");
      const selectionContainer = document.querySelector(".selection-container");
      const mainHeading = document.querySelector("#main-heading");

      // Hide selection container and show spawn container
      selectionContainer.style.display = "none";
      spawnContainer.style.display = "flex";
      mainHeading.innerText = "Select Spawn Location";

      // Populate spawn locations
      allSpawns.forEach((spawn) => {
        const spawnDiv = document.createElement("div");
        spawnDiv.classList.add("spawn-location");
        spawnDiv.innerText = spawn.label;
        spawnDiv.addEventListener("click", () => {
          fetch("https://coca_spawnmanager/teleportMainCharacter", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify(spawn),
          });
        });
        spawnContainer.appendChild(spawnDiv);
      });
    }
  });
});
