import * as assert from "assert";
import * as puppeteer from "puppeteer";
import * as looksSame from "looks-same";
import * as fs from "fs/promises";

const html = `
<html>
<head>
    <title>These are tests.</title>
    <style>
    html, body {
        padding: 0;
        margin: 0;
    }
    </style>
</head>
<body>
    <div style="background-color: #FFFFFF; width: 600px; height: 572px; position: relative; overflow: hidden">
        <div style="background-color: #C4C4C4; position: absolute; left: 205px; top: 48px; width: 458px; height: 154px;">
        </div>
    </div>
</body>
</html>
`;

describe("elm-figma-tests", () => {
    it("has a golden Test/0", async () => {
        const browser = await puppeteer.launch();
        try {
            const page = await browser.newPage();
            await page.setViewport({
                width: 600,
                height: 572,
                deviceScaleFactor: 1,
            });
            await page.setContent(html);
            const imageBuffer = await page.screenshot({ fullPage: true });
            await fs.writeFile("test/result/Test/0.png", imageBuffer);
            const reference = await fs.readFile("test/golden/Test/0.png");
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
