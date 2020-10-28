import * as puppeteer from "puppeteer";
import * as fs from "fs/promises";
import { compileElm } from "./utilities";

export interface TestData {
    elmJs: string,
    figmaFile: string,
    browser: puppeteer.Browser,
};

const puppeteerOptions = {
    dumpio: true
};

export default async function bootstrap(run: (data: TestData) => Promise<void>) {
    const elmJs = await compileElm("src/MainTest.elm");
    const figmaFile = await fs.readFile("test/elm-figma-autoflex-test.json", { encoding: "utf-8" });
    const browser = await puppeteer.launch(puppeteerOptions);
    try {
        await run({ elmJs, figmaFile, browser });
    } finally {
        await browser.close();
    }
}
