Cypress.Commands.add("clearData", () => {
  cy.window().then((win) => {
    if (win.localStorage) {
      win.localStorage.clear();
    }
    if (win.sessionStorage) {
      win.sessionStorage.clear();
    }
  });
});
