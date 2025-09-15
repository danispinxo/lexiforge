import { defineConfig } from "cypress";

export default defineConfig({
  e2e: {
    baseUrl: process.env.CYPRESS_baseUrl || "http://localhost:3001",
    supportFile: "cypress/support/e2e.js",
    specPattern: "cypress/e2e/**/*.cy.{js,jsx,ts,tsx}",
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 10000,
    experimentalStudio: true,

    setupNodeEvents(on) {
      on("before:browser:launch", (browser, launchOptions) => {
        if (browser.name === "electron") {
          launchOptions.args.push("--no-sandbox");
          launchOptions.args.push("--disable-setuid-sandbox");
          launchOptions.args.push("--disable-dev-shm-usage");
          launchOptions.args.push("--disable-gpu");
          launchOptions.args.push("--disable-software-rasterizer");
          launchOptions.args.push("--disable-background-timer-throttling");
          launchOptions.args.push("--disable-backgrounding-occluded-windows");
          launchOptions.args.push("--disable-renderer-backgrounding");
          launchOptions.args.push("--disable-features=TranslateUI");
          launchOptions.args.push("--disable-ipc-flooding-protection");
        }
        return launchOptions;
      });
    },
  },
  component: {
    devServer: {
      framework: "react",
      bundler: "vite",
    },
    supportFile: "cypress/support/component.js",
    specPattern: "src/**/*.cy.{js,jsx,ts,tsx}",
    indexHtmlFile: "cypress/support/component-index.html",
  },
});
