describe("LexiForge App", () => {
  beforeEach(() => {
    cy.clearData();
  });

  it("should load homepage and navigate between sections", () => {
    cy.visit("/");
    cy.contains("LexiForge").should("be.visible");

    cy.contains("Public Source Texts").click();
    cy.url().should("include", "/source-texts");
    cy.contains("Public Source Texts").should("be.visible");

    cy.contains("Public Poems").click();
    cy.url().should("include", "/poems");
    cy.contains("Public Generated Poems").should("be.visible");
  });
});
