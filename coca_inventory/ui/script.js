// $(function () {
//   let playerInventory = Array(30).fill({});
//   let otherInventory = Array(80).fill({});
//   let amount = 1;
//   let inventoryMaxSpace = undefined;
//   let olddropCoords = undefined;
//   let stashName = undefined;
//   let dropid = undefined;
//   let otherInventoryName = undefined;

//   $("#amount-button").on("input", function () {
//     const inputVal = $(this).val();
//     if (inputVal == 0 || inputVal == "0") {
//       inputVal = 1;
//     }
//     amount = Math.floor(parseInt(inputVal));
//   });

//   // Calculate total weight of an inventory
//   function calculateTotalWeight(inventory) {
//     return inventory.reduce((total, item) => {
//       if (item.count && item.weight) {
//         return total + item.count * item.weight;
//       }
//       return total;
//     }, 0);
//   }

//   // Render inventories
//   function renderInventory(inventory, container, isPlayer) {
//     container.empty();
//     let totalWeight = 0;

//     inventory.forEach((data, index) => {
//       // Handle undefined values with default values
//       const price = data.price !== undefined ? data.price : "";
//       const count = data.count !== undefined ? data.count : 0;
//       const weight = data.weight !== undefined ? data.weight : 0;
//       totalWeight += weight * count;
//       const imgname = data.imgname !== undefined ? data.imgname : "";
//       const label = data.label !== undefined ? data.label : "";
//       const box = $(`
//         <div class="box" data-index="${index}">
//             ${
//               isPlayer && index < 5
//                 ? `<div class="hotkey">${index + 1}</div>`
//                 : ""
//             }
//             <div class="box-info-upper">
//                 <div class="box-info-upper-left">${
//                   !isPlayer && otherInventoryName == "store" && price
//                     ? `$ ${price}`
//                     : ""
//                 }</div>
//                 <div class="box-info-upper-right">${
//                   count != 0
//                     ? `${count} (${(weight * count).toFixed(2)})`
//                     : `0(0.00)`
//                 }</div>
//             </div>
//             ${
//               imgname &&
//               `<img class="box-img-container" src="images/items/${imgname}" />`
//             }
//             <div class="box-info-lower">${label}</div> <!-- Use item label from config -->
//         </div>
//     `);
//       container.append(box);
//     });
//     if (isPlayer)
//       $(".player-inventory-weight").text(`${totalWeight.toFixed(2)}/60.00`);
//     if (!isPlayer)
//       $(".other-inventory-weight").text(
//         `${totalWeight.toFixed(2)}/${inventoryMaxSpace + ".00"}`
//       );
//     initializeDragAndDrop();
//   }

//   renderInventory(playerInventory, $("#player-inventory-boxes"), true);
//   renderInventory(otherInventory, $("#other-inventory-boxes"), false);

//   // Initialize drag-and-drop
//   function initializeDragAndDrop() {
//     $(".box").draggable({
//       revert: "invalid",
//       helper: "clone",
//       start: function (event, ui) {
//         ui.helper.data("origin", $(this).parent().attr("id"));
//         ui.helper.data("index", $(this).data("index"));
//         ui.helper.data("amount", amount);
//       },
//       stop: function (event, ui) {
//         $(".invalid-drag").removeClass("invalid-drag");
//       },
//     });

//     $(".box").droppable({
//       accept: ".box",
//       drop: function (event, ui) {
//         if (
//           olddropCoords !== undefined &&
//           $(this).parent().attr("id") !== "player-inventory-boxes"
//         ) {
//           return;
//         }

//         if (
//           otherInventoryName == "store" &&
//           $(this).parent().attr("id") !== "player-inventory-boxes"
//         ) {
//           return;
//         }

//         const fromInventory =
//           ui.helper.data("origin") === "player-inventory-boxes"
//             ? playerInventory
//             : otherInventory;
//         const toInventory =
//           $(this).parent().attr("id") === "player-inventory-boxes"
//             ? playerInventory
//             : otherInventory;

//         const fromIndex = ui.helper.data("index");
//         const toIndex = $(this).data("index");

//         // Check if the item being dragged exists
//         if (fromInventory[fromIndex].name) {
//           // Calculate the amount to drag, considering the specified amount and available count
//           let amountToDrag = ui.helper.data("amount");
//           amountToDrag = Math.min(amountToDrag, fromInventory[fromIndex].count);

//           // Calculate new weight
//           let newWeight = calculateTotalWeight(toInventory);
//           let itemWeight = fromInventory[fromIndex].weight * amountToDrag;

//           if ($(this).parent().attr("id") === "player-inventory-boxes") {
//             if (newWeight + itemWeight > 60.0) {
//               return;
//             }
//           } else {
//             if (newWeight + itemWeight > inventoryMaxSpace) {
//               return;
//             }
//           }

//           // Check if the item can stack and if the target slot already has the same item
//           const canStack =
//             fromInventory[fromIndex].name === toInventory[toIndex].name &&
//             fromInventory[fromIndex].canStack;

//           if (canStack) {
//             // Increase the count of the target item
//             toInventory[toIndex].count += amountToDrag;
//             // Decrease the count of the source item
//             fromInventory[fromIndex].count -= amountToDrag;

//             if (fromInventory[fromIndex].count == 0) {
//               fromInventory[fromIndex] = { name: "", count: 0 };
//             }
//           } else if (
//             toInventory[toIndex].name == undefined ||
//             toInventory[toIndex].name == null ||
//             toInventory[toIndex].name == ""
//           ) {
//             // Move the entire item if the target slot is empty
//             toInventory[toIndex] = { ...fromInventory[fromIndex] };
//             toInventory[toIndex].count = amountToDrag;
//             // Decrease the count of the source item
//             fromInventory[fromIndex].count -= amountToDrag;

//             if (fromInventory[fromIndex].count == 0) {
//               fromInventory[fromIndex] = { name: "", count: 0 };
//             }
//           } else {
//             // Swap items between inventories if the target slot contains a different item
//             [fromInventory[fromIndex], toInventory[toIndex]] = [
//               toInventory[toIndex],
//               fromInventory[fromIndex],
//             ];
//           }

//           if (otherInventoryName == "store") {
//             const draggedItem = toInventory[toIndex];

//             // Ensure draggedItem is defined before proceeding
//             if (!draggedItem || draggedItem.price === undefined) {
//               console.error("Dragged item is undefined or lacks a price.");
//               return;
//             }

//             $.post(
//               "https://coca_inventory/checkCash",
//               JSON.stringify(draggedItem.price * amountToDrag),
//               function (response) {
//                 if (!response.success) {
//                   // If not enough cash, revert the item move
//                   if (canStack) {
//                     fromInventory[fromIndex].count += amountToDrag;
//                     toInventory[toIndex].count -= amountToDrag;
//                     if (toInventory[toIndex].count == 0) {
//                       toInventory[toIndex] = { name: "", count: 0 };
//                     }
//                   } else {
//                     [fromInventory[fromIndex], toInventory[toIndex]] = [
//                       toInventory[toIndex],
//                       fromInventory[fromIndex],
//                     ];
//                   }
//                 } else {
//                   renderInventory(
//                     playerInventory,
//                     $("#player-inventory-boxes"),
//                     true
//                   );
//                   renderInventory(
//                     otherInventory,
//                     $("#other-inventory-boxes"),
//                     false
//                   );
//                 }
//               }
//             );
//             return;
//           }

//           // Re-render inventories
//           renderInventory(playerInventory, $("#player-inventory-boxes"), true);
//           renderInventory(otherInventory, $("#other-inventory-boxes"), false);
//         }
//       },
//     });

//     // Highlight invalid drags over amount-button
//     $("#use-button").droppable({
//       accept: ".box",
//       over: function (event, ui) {
//         if (ui.helper.data("origin") !== "player-inventory-boxes") {
//           ui.helper.addClass("invalid-drag");
//         }
//       },
//       out: function (event, ui) {
//         if (ui.helper.hasClass("invalid-drag")) {
//           ui.helper.removeClass("invalid-drag");
//         }
//       },
//       drop: function (event, ui) {
//         if (ui.helper.data("origin") !== "player-inventory-boxes") {
//           ui.helper.removeClass("invalid-drag");
//           return false; // Ignore drops from other inventories
//         }

//         const fromInventory = playerInventory;
//         const fromIndex = ui.helper.data("index");

//         if (fromInventory[fromIndex].name) {
//           handleItemUse(fromInventory, fromIndex);
//         }
//       },
//     });
//   }

$(function () {
  let playerInventory = Array(30).fill({});
  let otherInventory = Array(80).fill({});
  let amount = 1;
  let inventoryMaxSpace = undefined;
  let olddropCoords = undefined;
  let stashName = undefined;
  let dropid = undefined;
  let otherInventoryName = undefined;

  $("#amount-button").on("input", function () {
    const inputVal = $(this).val();
    if (inputVal == 0 || inputVal == "0") {
      inputVal = 1;
    }
    amount = Math.floor(parseInt(inputVal));
  });

  // Calculate total weight of an inventory
  function calculateTotalWeight(inventory) {
    return inventory.reduce((total, item) => {
      if (item.count && item.weight) {
        return total + item.count * item.weight;
      }
      return total;
    }, 0);
  }

  // Render inventories
  function renderInventory(inventory, container, isPlayer) {
    container.empty();
    let totalWeight = 0;

    inventory.forEach((data, index) => {
      // Handle undefined values with default values
      const price = data.price !== undefined ? data.price : "";
      const count = data.count !== undefined ? data.count : 0;
      const weight = data.weight !== undefined ? data.weight : 0;
      totalWeight += weight * count;
      const imgname = data.imgname !== undefined ? data.imgname : "";
      const label = data.label !== undefined ? data.label : "";
      const box = $(`
                <div class="box" data-index="${index}">
                    ${
                      isPlayer && index < 5
                        ? `<div class="hotkey">${index + 1}</div>`
                        : ""
                    }
                    <div class="box-info-upper">
                        <div class="box-info-upper-left">${
                          !isPlayer && otherInventoryName == "store" && price
                            ? `$ ${price}`
                            : ""
                        }</div>
                        <div class="box-info-upper-right">${
                          count != 0
                            ? `${count} (${(weight * count).toFixed(2)})`
                            : `0(0.00)`
                        }</div>
                    </div>
                    ${
                      imgname &&
                      `<img class="box-img-container" src="images/items/${imgname}" />`
                    }
                    <div class="box-info-lower">${label}</div> <!-- Use item label from config -->
                </div>
            `);
      container.append(box);
    });
    if (isPlayer)
      $(".player-inventory-weight").text(`${totalWeight.toFixed(2)}/60.00`);
    if (!isPlayer)
      $(".other-inventory-weight").text(
        `${totalWeight.toFixed(2)}/${inventoryMaxSpace + ".00"}`
      );
    initializeDragAndDrop();
  }

  renderInventory(playerInventory, $("#player-inventory-boxes"), true);
  renderInventory(otherInventory, $("#other-inventory-boxes"), false);

  // Initialize drag-and-drop
  function initializeDragAndDrop() {
    $(".box").draggable({
      revert: "invalid",
      helper: "clone",
      start: function (event, ui) {
        ui.helper.data("origin", $(this).parent().attr("id"));
        ui.helper.data("index", $(this).data("index"));
        ui.helper.data("amount", amount);
      },
      stop: function (event, ui) {
        $(".invalid-drag").removeClass("invalid-drag");
      },
    });

    $(".box").droppable({
      accept: ".box",
      drop: function (event, ui) {
        if (
          olddropCoords !== undefined &&
          $(this).parent().attr("id") !== "player-inventory-boxes"
        ) {
          highlightInvalidDrag(
            ui.helper.data("origin"),
            ui.helper.data("index")
          );
          return;
        }

        if (
          otherInventoryName == "store" &&
          $(this).parent().attr("id") !== "player-inventory-boxes"
        ) {
          highlightInvalidDrag(
            ui.helper.data("origin"),
            ui.helper.data("index")
          );
          return;
        }

        const fromInventory =
          ui.helper.data("origin") === "player-inventory-boxes"
            ? playerInventory
            : otherInventory;
        const toInventory =
          $(this).parent().attr("id") === "player-inventory-boxes"
            ? playerInventory
            : otherInventory;

        const fromIndex = ui.helper.data("index");
        const toIndex = $(this).data("index");

        // Check if the item being dragged exists
        if (fromInventory[fromIndex].name) {
          // Calculate the amount to drag, considering the specified amount and available count
          let amountToDrag = ui.helper.data("amount");
          amountToDrag = Math.min(amountToDrag, fromInventory[fromIndex].count);

          // Calculate new weight
          let newWeight = calculateTotalWeight(toInventory);
          let itemWeight = fromInventory[fromIndex].weight * amountToDrag;

          if ($(this).parent().attr("id") === "player-inventory-boxes") {
            if (newWeight + itemWeight > 60.0) {
              highlightInvalidDrag(
                ui.helper.data("origin"),
                ui.helper.data("index")
              );
              return;
            }
          } else {
            if (newWeight + itemWeight > inventoryMaxSpace) {
              highlightInvalidDrag(
                ui.helper.data("origin"),
                ui.helper.data("index")
              );
              return;
            }
          }

          // Check if the item can stack and if the target slot already has the same item
          const canStack =
            fromInventory[fromIndex].name === toInventory[toIndex].name &&
            fromInventory[fromIndex].canStack;

          if (canStack) {
            // Increase the count of the target item
            toInventory[toIndex].count += amountToDrag;
            // Decrease the count of the source item
            fromInventory[fromIndex].count -= amountToDrag;

            if (fromInventory[fromIndex].count == 0) {
              fromInventory[fromIndex] = { name: "", count: 0 };
            }
          } else if (
            toInventory[toIndex].name == undefined ||
            toInventory[toIndex].name == null ||
            toInventory[toIndex].name == ""
          ) {
            // Move the entire item if the target slot is empty
            toInventory[toIndex] = { ...fromInventory[fromIndex] };
            toInventory[toIndex].count = amountToDrag;
            // Decrease the count of the source item
            fromInventory[fromIndex].count -= amountToDrag;

            if (fromInventory[fromIndex].count == 0) {
              fromInventory[fromIndex] = { name: "", count: 0 };
            }
          } else {
            // Swap items between inventories if the target slot contains a different item
            [fromInventory[fromIndex], toInventory[toIndex]] = [
              toInventory[toIndex],
              fromInventory[fromIndex],
            ];
          }

          if (otherInventoryName == "store") {
            const draggedItem = toInventory[toIndex];

            // Ensure draggedItem is defined before proceeding
            if (!draggedItem || draggedItem.price === undefined) {
              console.error("Dragged item is undefined or lacks a price.");
              return;
            }

            $.post(
              "https://coca_inventory/checkCash",
              JSON.stringify(draggedItem.price * amountToDrag),
              function (response) {
                if (!response.success) {
                  // If not enough cash, revert the item move
                  if (canStack) {
                    fromInventory[fromIndex].count += amountToDrag;
                    toInventory[toIndex].count -= amountToDrag;
                    if (toInventory[toIndex].count == 0) {
                      toInventory[toIndex] = { name: "", count: 0 };
                    }
                  } else {
                    [fromInventory[fromIndex], toInventory[toIndex]] = [
                      toInventory[toIndex],
                      fromInventory[fromIndex],
                    ];
                  }
                  highlightInvalidDrag(
                    ui.helper.data("origin"),
                    ui.helper.data("index")
                  );
                } else {
                  renderInventory(
                    playerInventory,
                    $("#player-inventory-boxes"),
                    true
                  );
                  renderInventory(
                    otherInventory,
                    $("#other-inventory-boxes"),
                    false
                  );
                }
              }
            );
            return;
          }

          // Re-render inventories
          renderInventory(playerInventory, $("#player-inventory-boxes"), true);
          renderInventory(otherInventory, $("#other-inventory-boxes"), false);
        }
      },
    });

    // Highlight invalid drags over amount-button
    $("#use-button").droppable({
      accept: ".box",
      over: function (event, ui) {
        if (ui.helper.data("origin") !== "player-inventory-boxes") {
          ui.helper.addClass("invalid-drag");
        }
      },
      out: function (event, ui) {
        if (ui.helper.hasClass("invalid-drag")) {
          ui.helper.removeClass("invalid-drag");
        }
      },
      drop: function (event, ui) {
        if (ui.helper.data("origin") !== "player-inventory-boxes") {
          ui.helper.removeClass("invalid-drag");
          return false; // Ignore drops from other inventories
        }

        const fromInventory = playerInventory;
        const fromIndex = ui.helper.data("index");

        if (fromInventory[fromIndex].name) {
          handleItemUse(fromInventory, fromIndex);
        }
      },
    });

    // Function to highlight the item being dragged if it was invalid
    // Function to highlight the item being dragged if it was invalid
    function highlightInvalidDrag(origin, index) {
      let containerSelector;

      // Determine which inventory container to highlight based on the origin
      if (origin === "player-inventory-boxes") {
        containerSelector = "#player-inventory-boxes";
      } else if (origin === "other-inventory-boxes") {
        containerSelector = "#other-inventory-boxes";
      } else {
        return;
      }

      // Find the box to highlight based on the index and container selector
      const boxToHighlight = $(
        `${containerSelector} .box[data-index="${index}"]`
      );
      if (boxToHighlight.length) {
        boxToHighlight.addClass("highlight-red");

        // Remove the class after the animation ends
        boxToHighlight[0].addEventListener(
          "animationend",
          function () {
            boxToHighlight.removeClass("highlight-red");
          },
          { once: true }
        );
      }
    }
  }

  function handleItemUse(inventory, index) {
    const item = inventory[index];

    if (item.name) {
      $.post(
        "https://coca_inventory/ui-useItem",
        JSON.stringify({
          name: item.name,
          index: index,
          inventory: inventory,
        })
      );

      $.post("https://coca_inventory/ui-closeInventory", JSON.stringify({}));
    }
  }

  initializeDragAndDrop();

  // Search functionality
  $("#search-button").on("input", function () {
    const searchString = $(this).val().toLowerCase(); // Convert search string to lowercase for case-insensitive comparison

    // Remove previous highlights
    $(".box").removeClass("highlight");

    // Highlight slots matching the search string
    if (searchString.trim() !== "") {
      // Check if search string is not empty
      $(".box").each(function () {
        const itemName = $(this).find(".box-info-lower").text().toLowerCase();
        if (itemName.includes(searchString)) {
          $(this).addClass("highlight");
        }
      });
    }
  });

  // UPDATE PLAYER INVENTORY
  function updateInventoryUI(inventory) {
    playerInventory = inventory;
    renderInventory(playerInventory, $("#player-inventory-boxes"), true);
  }

  window.addEventListener("message", function (event) {
    let data = event.data;
    if (data.type === "updatePlayerInventory") {
      updateInventoryUI(data.inventory);
    }
  });

  // UPDATE OTHER INVENTORY
  function updateOtherInventoryUI(inventorydata) {
    // pass data {"inventory": {inventorydata}, "coords":{x,y,z}, "stashname" : name}
    dropid = inventorydata.id;
    otherInventory = inventorydata.inventory;
    stashName = inventorydata.stashname;
    if (dropid != undefined) {
      // coords are used for drops only not for stash
      olddropCoords = inventorydata.coords;
    }

    renderInventory(otherInventory, $("#other-inventory-boxes"), false);
  }

  window.addEventListener("message", function (event) {
    let data = event.data;

    if (data.type === "updateOtherInventory") {
      updateOtherInventoryUI(data.inventorydata);
    }
  });

  // OPEN and CLOSE INVENTORY
  window.addEventListener("message", function (event) {
    if (event.data.type === "toggleInventory") {
      if (event.data.display) {
        otherInventoryName = event.data.inventoryName;

        inventoryMaxSpace = event.data.inventoryMaxSpace;
        $(".other-inventory-name").text(otherInventoryName); // Set the inventory name

        renderInventory(playerInventory, $("#player-inventory-boxes"), true);
        renderInventory(otherInventory, $("#other-inventory-boxes"), false);

        $(".inventory-container").show();
      } else {
        $(".inventory-container").hide();

        $.post(
          "https://coca_inventory/UI-PlayerInventoy",
          JSON.stringify(playerInventory)
        ); // SET PLAYER INVENTORY

        if (otherInventoryName == "drop") {
          // SET DROP INVENTORY
          if (dropid) {
            $.post(
              "https://coca_inventory/UI-UpdateDroppedInventory", //ui-droppeditemmove
              JSON.stringify({
                id: dropid,
                inventory: otherInventory,
                coords: olddropCoords,
              })
            );
            dropid = undefined;
          } else {
            let isEmpty = true;
            for (let i = 0; i < otherInventory.length; i++) {
              if (
                otherInventory[i].name != undefined &&
                otherInventory[i].name != ""
              ) {
                isEmpty = false;
              }
            }

            if (isEmpty) return;
            $.post(
              "https://coca_inventory/UI-NewDropInventory",
              JSON.stringify(otherInventory)
            );
          }
        } else if (otherInventoryName == "stash") {
          // SET STASH INVENTORY
          $.post(
            "https://coca_inventory/UI-UpdateStash",
            JSON.stringify({ inventory: otherInventory, stashname: stashName })
          );
          stashName = undefined;
        } else if (otherInventoryName == "glovebox") {
          console.log(otherInventory);
          $.post(
            "https://coca_inventory/UI-Glovebox",
            JSON.stringify(otherInventory)
          );
        } else if (otherInventoryName == "trunk") {
          $.post(
            "https://coca_inventory/UI-Trunk",
            JSON.stringify(otherInventory)
          );
        }

        otherInventory = Array(80).fill({});
        inventoryMaxSpace = undefined;
        olddropCoords = undefined;
        stashName = undefined;
        dropid = undefined;
        otherInventoryName = undefined;
        amount = 1;
      }
    }
  });

  $(document).on("keydown", function (e) {
    if (e.keyCode === 9) {
      //TAB
      e.preventDefault();
      $.post("https://coca_inventory/ui-closeInventory", JSON.stringify({}));
    }
  });

  $(document).on("keydown", function (e) {
    if (e.keyCode === 27) {
      //ESC
      $.post("https://coca_inventory/ui-closeInventory", JSON.stringify({}));
    }
  });

  $("#close-button").click(function () {
    $.post("https://coca_inventory/ui-closeInventory", JSON.stringify({}));
  });

  $(".inventory-container").hide();

  window.addEventListener("message", function (event) {
    let data = event.data;

    if (data.type === "print") {
      console.log(data.data);
    }
  });
});
