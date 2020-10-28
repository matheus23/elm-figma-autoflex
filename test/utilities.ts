import * as puppeteer from "puppeteer";
import * as looksSame from "looks-same";
import * as fs from "fs/promises";
import * as process from "child_process";


export async function compileElm(path: string): Promise<string> {
    process.execSync(`elm make ${path} --output=dist/elm.js`);
    return await fs.readFile("dist/elm.js", { encoding: "utf-8" });
}


export function imageDiff(image0: Buffer, image1: Buffer): Promise<Buffer> {
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


export function imagesEqual(imageBuffer: Buffer, path: Buffer): Promise<void> {
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


export async function ensureDeleted(path: string) {
    try {
        await fs.unlink(path);
    } catch (e) { }
}


export async function withPage<A>(browser: puppeteer.Browser, func: (page: puppeteer.Page) => Promise<A>): Promise<A> {
    const page = await browser.newPage();
    try {
        return await func(page);
    } finally {
        await page.close();
    }
}
