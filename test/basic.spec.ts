import * as assert from "assert";
import * as puppeteer from "puppeteer";
import * as looksSame from "looks-same";
import * as fs from "fs/promises";
import * as process from "child_process";


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


const elmInit = (figmaFile: string) => `
Elm.MainTest.init({
    node: document.getElementById("elm-root"),
    flags: ${JSON.stringify(figmaFile)}
});
`;


describe("elm-figma-tests", () => {
    it("has a golden Test/0", async () => {
        const elmJs = await compileElm("src/MainTest.elm");
        const figmaFile = await fs.readFile("test/elm-figma-autoflex-test.json", { encoding: "utf-8" });
        const browser = await puppeteer.launch();
        try {
            const page = await browser.newPage();
            
            // Initialize the page
            await page.setContent(html);
            await page.setViewport({
                width: 600,
                height: 572,
                deviceScaleFactor: 1,
            });
            await page.evaluate(elmJs + "\n" + elmInit(figmaFile));
            await page.waitForSelector("div#test");

            // Make a screenshot of the rendered content
            const imageBuffer = await page.screenshot({ fullPage: true });
            await fs.writeFile("test/result/Test/0.png", imageBuffer);
            const reference = await fs.readFile("test/golden/Test/0.png");
            
            // Test for screenshot equality with figma export
            try {
                await imagesEqual(imageBuffer, reference);
                await ensureDeleted("test/failures/Test/0.png");
            } catch (e) {
                const diff = await imageDiff(imageBuffer, reference);
                await fs.writeFile("test/failures/Test/0.png", diff);
                assert.fail("There is a difference in the images");
            }
        } finally {
            await browser.close();
        }
    });
});


function imageDiff(image0: Buffer, image1: Buffer): Promise<Buffer> {
    return new Promise((resolve, reject) => {
        looksSame.createDiff({
            current: image0,
            reference: image1,
            strict: true,
            highlightColor: "#FF00FF",
        }, (error, buffer) => {
            if (error) {
                reject(error);
            }
            resolve(buffer);
        });
    });
}


function imagesEqual(imageBuffer: Buffer, path: Buffer): Promise<void> {
    return new Promise((resolve, reject) => {
        looksSame(imageBuffer, path, (error, { equal }) => {
            if (equal) {
                resolve();
            } else {
                reject(error);
            }
        });
    });
}


async function ensureDeleted(path: string) {
    try {
        await fs.unlink(path);
    } catch(e) {}
}

async function compileElm(path: string): Promise<string> {
    process.execSync(`elm make ${path} --output=dist/elm.js`);
    return await fs.readFile("dist/elm.js", { encoding: "utf-8" });
}
