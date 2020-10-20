import fetch from "node-fetch";
import * as fs from "fs/promises";
import * as dotenv from "dotenv";

dotenv.config();

const { FIGMA_TOKEN } = process.env;

if (FIGMA_TOKEN == null) {
    throw "Missing environment parameter: FIGMA_TOKEN\nFind out how to get your API token here: https://www.figma.com/developers/api#access-tokens";
}

fetchFigma(FIGMA_TOKEN);


async function fetchFigma(apiKey: string) {
    const figmaJson = await fetch("https://api.figma.com/v1/files/k7bHLlSMVnTWzClpRHLx6a", {
        headers: {
            "X-Figma-Token": apiKey,
        },
    });

    const json = JSON.parse(figmaJson.body.read().toString());
    const pretty = JSON.stringify(json, null, 4);
    await fs.writeFile("test/elm-figma-autoflex-test.json", pretty);
}
