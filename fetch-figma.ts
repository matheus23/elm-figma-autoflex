import fetch from "node-fetch";
import * as fs from "fs/promises";
import { config } from "dotenv";

config();

const { FIGMA_TOKEN } = process.env;

async function fetchFigma(apiKey: string) {
    const figmaJson = await fetch("https://api.figma.com/v1/files/k7bHLlSMVnTWzClpRHLx6a", {
        headers: {
            "X-Figma-Token": apiKey,
        },
    });
    
    await fs.writeFile("test/elm-figma-autoflex-test.json", figmaJson.body.read());
}

fetchFigma(FIGMA_TOKEN);
