# elm-figma-autoflex
> Fetch figma frames via the Figma API and render them as responsive HTML

At least that was the plan. It doesn't work!

But I'm sure it *can* be made to work for many cases and might be super powerful in combination with e.g. elm-pages.
The idea being that Figma becomes a sort of CMS for pages that need a particular design freedom.

## Setup

If you want to run this for yourself you likely need to adjust some hardcoded things that were specific to the Figma files I was testing this with.
Other than that, you'll also need a `.env` file with your Figma access token like this:

```ini
FIGMA_TOKEN=<your-figma-token>
```
