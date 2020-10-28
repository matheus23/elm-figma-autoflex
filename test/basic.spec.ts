import * as assert from "assert";
import * as puppeteer from "puppeteer";
import * as fs from "fs/promises";
import { ensureDeleted, imageDiff, imagesEqual, withPage } from "./utilities";
import bootstrap, { TestData } from "./bootstrap";


// TYPES

interface FigmaNode {
    id: string,
    name: string,
    type: string,
    children?: Array<FigmaNode>,
}


// HARDCODED TEST DATA

const html = `
<html>

<head>
    <title>Testing elm-figma-autoflex</title>
    <style>
        html, body {
            margin: 0;
            padding: 0;
        }
    </style>
</head>

<body>
    <div id="elm-root"></div>
</body>

</html>
`;


const elmInit = (figmaFile: string, nodeName: string) => `
Elm.MainTest.init({
    node: document.getElementById("elm-root"),
    flags: {
        figmaFile: JSON.parse(${JSON.stringify(figmaFile)}),
        nodeName: ${JSON.stringify(nodeName)}
    }
});
`;


// TESTS

bootstrap(async (data: TestData) => {

    describe("elm-figma-tests", () => {
        const figmaFile = JSON.parse(data.figmaFile) as { document: FigmaNode };

        if (!figmaFile.document.children
            || !figmaFile.document.children[0]
            || !figmaFile.document.children[0].children) {
            throw "Test figma file is missing data.";
        }

        const frames = figmaFile.document.children[0].children;

        frames.forEach(figmaFrame => {
            console.log(figmaFrame.name, figmaFrame.id);
            // TODO
        });

        it("has a golden Test/0", testFigmaGolden(data, "Test/0"));
    });

    run();
});


function testFigmaGolden(data: TestData, nodeName: string) {
    return async () => {
        withPage(data.browser, async page => {

            // Initialize the page

            await page.setContent(html);
            await page.setViewport({
                width: 600,
                height: 572,
                deviceScaleFactor: 1,
            });
            await page.evaluate(data.elmJs + "\n" + elmInit(data.figmaFile, nodeName));
            await page.waitForSelector("div#test");


            // Make a screenshot of the rendered content

            const imageBuffer = await page.screenshot({ fullPage: true });
            await fs.writeFile(`test/result/${nodeName}.png`, imageBuffer);
            const reference = await fs.readFile(`test/golden/${nodeName}.png`);


            // Test for screenshot equality with figma export

            try {
                await imagesEqual(imageBuffer, reference);
                await ensureDeleted(`test/failures/${nodeName}.png`);
            } catch (e) {
                const diff = await imageDiff(imageBuffer, reference);
                await fs.writeFile(`test/failures/${nodeName}.png`, diff);
                assert.fail("There is a difference in the images");
            }

        });
    }
}
